//
//  MainViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 10/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "MainViewController.h"
#import "MySingleton.h"
#import "ShareViewController.h"
#import "MainViewCollectionHeader.h"
#import "MainViewCollectionCell.h"

const int MAX_NUMBER_OF_NOTE = 100;
const int OFFSET_FOR_RESET_SCROLLVIEW = 50;

@interface MainViewController ()

@end

@implementation MainViewController

//Storyboard declared objects
@synthesize backgroundView;
@synthesize addBtn;
@synthesize refreshBtn;
@synthesize logoutBtn;
@synthesize collectionBtn;

@synthesize poc;
@synthesize currentClickedRect;
@synthesize menu;

@synthesize myCollView;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //collectionView
    myCollView.delegate = self;
    myCollView.dataSource = self;
    
    //For Location
    //declare location manager
    geocoder = [[CLGeocoder alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    
    
    //FOR IOS 8 or later
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        NSLog(@"IOS8.0 or later init");
        [locationManager requestWhenInUseAuthorization];
    }
    
    //[locationManager startMonitoringSignificantLocationChanges];
    [locationManager startUpdatingLocation];
    
    
    // Do any additional setup after loading the view.
    noteControlBtnArray = [[NSMutableArray alloc] init];
    
    //get singleton
    MySingleton* singleton = [MySingleton getInstance];
    
    //localication
    NSString* logoutText = NSLocalizedStringFromTableInBundle(@"Logout", nil, singleton.globalLocaleBundle, nil);
    self.logoutBtn.title = [NSString stringWithFormat:@"< %@ - %@", singleton.globalUserName, logoutText];
    self.collectionBtn.title = NSLocalizedStringFromTableInBundle(@"Achievement", nil, singleton.globalLocaleBundle, nil);
    
    
    //set background image
    NSString* imageName= NSLocalizedStringFromTableInBundle(@"mainViewBG", nil, singleton.globalLocaleBundle, nil);
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    self.backgroundView.alpha = 0.1f;
    [self.view sendSubviewToBack:self.backgroundView];
    
    //notification called when main view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissCollectionViewController)
                                                 name:@"CollectionViewControllerDismissed"
                                               object:nil];
    //notification called when note view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissNoteViewController)
                                                 name:@"NoteViewControllerDismissed"
                                               object:nil];
    
    //notification called when share view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissShareViewController)
                                                 name:@"ShareViewControllerDismissed"
                                               object:nil];
    //refresh when login
    [self getAllNoteByUserID:singleton.globalUserID andServer:singleton.globalUserServer];
}

//location delegate
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
    //UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[errorAlert show];
    NSLog(@"Error: %@",error.description);
}

//location delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"didUpdateLocations");
    CLLocation *crnLoc = [locations lastObject];
    
    NSString * latitude = [NSString stringWithFormat:@"%.25f",crnLoc.coordinate.latitude];
    NSString * longitude = [NSString stringWithFormat:@"%.25f",crnLoc.coordinate.longitude];
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:crnLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            locInfo = [NSString stringWithFormat:@"%@ %@ %@ %@", latitude, longitude, locatedAt, placemark.subLocality];
            //save in singleton
            singleton.globalLocInfo = locInfo;
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    [locationManager stopUpdatingLocation];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)enableAllButtons{
    logoutBtn.enabled = YES;
    addBtn.enabled = YES;
    refreshBtn.enabled=YES;
    collectionBtn.enabled=YES;
}

-(void)disableAllButtons{
    logoutBtn.enabled = NO;
    addBtn.enabled = NO;
    refreshBtn.enabled=NO;
    collectionBtn.enabled= NO;
}

- (IBAction)handleLogout:(id)sender {
    //noticfy login page for dismissing.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)handleAdd:(id)sender {
    MySingleton* singleton = [MySingleton getInstance];
    [self disableAllButtons];
    
    [MySingleton startLoading:self.view];

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        bool success = [self addNewNoteBy:singleton.globalUserID andLoc:singleton.globalLocInfo andServer:singleton.globalUserServer];
        bool successSR = [self getAllNoteByUserID:singleton.globalUserID andServer:singleton.globalUserServer];
        bool successCombined = success && successSR;
        [MySingleton endLoading:self.view andSuccess:success];
        [self enableAllButtons];
        if (successCombined){
            [myCollView reloadData];
        }
    });

}

- (IBAction)handleRefresh:(id)sender {
    NSLog(@"Refresh Screen");
    
    //OFF Button
    [self disableAllButtons];
    
    MySingleton* singleton = [MySingleton getInstance];
    [MySingleton startLoading:self.view];
    
    //ON Button
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //do function
        bool successSR = [self getAllNoteByUserID:singleton.globalUserID andServer:singleton.globalUserServer];
        [MySingleton endLoading:self.view andSuccess:successSR];
        if (successSR){
            [myCollView reloadData];
        }
        [self enableAllButtons];
    });

}

//notification called when collection view dismiss
-(void)didDismissCollectionViewController {
    NSLog(@"didDismissCollectionViewController");
    //refresh
    [self handleRefresh:nil];
}

//notification called when note view dismiss
-(void)didDismissNoteViewController {
    NSLog(@"didDismissNoteViewController");
    //refresh
    [self handleRefresh:nil];
}

- (bool)getAllNoteByUserID:(NSString *)UserID andServer:(NSString *)Server{
    bool boolSuccess = false;
    noteArray = nil;
    noteCount = 0;

    NSLog(@"getAllNoteByUserID");
    
    if([UserID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"getAllUserNotes.php" andDataInput:dataInput];
        //NSLog(@"jsonData = %@",jsonData);
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            noteCount = [jsonData[@"count"] intValue];
            if (noteCount > 0){
                noteArray = [jsonData objectForKey:@"data"];
            }
            
            noteControlBtnArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < noteCount; i++){
                BOOL b = false;
                [noteControlBtnArray addObject:[NSNumber numberWithBool:b]];
            }
            
            boolSuccess = true;
            
        }else if ([success  isEqual: @"ERROR"]){
            NSString * error_msg = [jsonData objectForKey:@"error_msg"];
            NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
            [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
            NSLog(@"system_error_msg = %@",system_error_msg);
        }
    }
    return boolSuccess;
}

-(bool)deleteNoteBy:(NSString *)NoteID andServer:(NSString *)Server{
    bool boolSuccess = false;
    
    if([NoteID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"deleteNote.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
        if ([success  isEqual: @"OK"]){
            boolSuccess = true;
        }else if ([success  isEqual: @"ERROR"]){
            NSString * error_msg = [jsonData objectForKey:@"error_msg"];
            NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
            [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
            NSLog(@"system_error_msg = %@",system_error_msg);
        }
    }
    return boolSuccess;
}

-(bool)addNewNoteBy:(NSString *)UserID andLoc:(NSString *)Loc andServer:(NSString *)Server{
    NSLog(@"addNewNoteBy");
    bool boolSuccess = false;
    
    if([UserID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:Loc] forKey:@"Location"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"addNote.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
        if ([success  isEqual: @"OK"]){
            boolSuccess = true;
        }else if ([success  isEqual: @"ERROR"]){
            NSString * error_msg = [jsonData objectForKey:@"error_msg"];
            NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
            [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
            NSLog(@"system_error_msg = %@",system_error_msg);
        }
    }
    return boolSuccess;
}

-(void)handleEdit:(id)sender{
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"Edit with noteID = %@", singleton.globalOnSelectedNoteID);
    [self performSegueWithIdentifier:@"noteSegue" sender:self];
}

//notification called when main view dismiss
-(void)didDismissShareViewController {
    NSLog(@"Dismiss Share View");
    [self.poc dismissPopoverAnimated:YES];
}

//for share menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void) handleNoteClick:(id)sender{
    NSLog(@"button clicked .................");
    UIButton * buttonClicked = (UIButton * )sender;
    currentClickedRect = buttonClicked.frame;
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalOnSelectedNoteID = [NSString stringWithFormat:@"%@",buttonClicked.titleLabel.text];
    NSLog (@"singleton.globalOnSelectedNoteID = %@",singleton.globalOnSelectedNoteID);
    //open note
    [self handleEdit:nil];
}

- (void) handleControlBtnClick:(id)sender{
    //MySingleton* singleton = [MySingleton getInstance];
    UIButton * buttonClicked = (UIButton * )sender;

    currentClickedRect = buttonClicked.frame;
    NSLog(@"Control button clicked ................. %ld",(long)buttonClicked.tag);

    //hide control view
    if ([[noteControlBtnArray objectAtIndex:buttonClicked.tag] boolValue]){
        BOOL b = false;
        [noteControlBtnArray replaceObjectAtIndex:buttonClicked.tag withObject:[NSNumber numberWithBool:b]];
    }else{
        BOOL b = true;
        [noteControlBtnArray replaceObjectAtIndex:buttonClicked.tag withObject:[NSNumber numberWithBool:b]];
    }
    
    //reload
    [myCollView reloadData];
}

- (void) handleEditBtnClick:(id)sender{
    //MySingleton* singleton = [MySingleton getInstance];
    UIButton * buttonClicked = (UIButton * )sender;
    
    currentClickedRect = buttonClicked.frame;
    NSLog(@"Edit button clicked ................. %ld",(long)buttonClicked.tag);
    
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalOnSelectedNoteID = [NSString stringWithFormat:@"%ld",(long)buttonClicked.tag];
    NSLog (@"singleton.globalOnSelectedNoteID = %@",singleton.globalOnSelectedNoteID);
    //open note
    [self handleEdit:nil];
}

- (void) handleShareBtnClick:(id)sender{
    /*
    //MySingleton* singleton = [MySingleton getInstance];
    UIButton * buttonClicked = (UIButton * )sender;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    UICollectionViewLayoutAttributes *attributes = [myCollView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect cellRect = attributes.frame;

    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalOnSelectedNoteID = buttonClicked.titleLabel.text;
    
    NSLog(@"Share with noteID = %@", singleton.globalOnSelectedNoteID);
    ShareViewController *svc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"ShareViewCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:svc];
    poc.delegate=self;
    [poc presentPopoverFromRect:cellRect inView:myCollView  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    */
}

- (void) handleDeleteBtnClick:(id)sender{
    //MySingleton* singleton = [MySingleton getInstance];
    UIButton * buttonClicked = (UIButton * )sender;
    
    currentClickedRect = buttonClicked.frame;
    
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"Delete with noteID ld = %ld",(long)buttonClicked.tag);
    [self disableAllButtons];
    
    [MySingleton startLoading:self.view];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        bool success = [self deleteNoteBy:[NSString stringWithFormat:@"%ld",(long)buttonClicked.tag] andServer:singleton.globalUserServer];
        [MySingleton endLoading:self.view andSuccess:success];
        [self enableAllButtons];
        [self handleRefresh:nil];
    });
}

//onSelectedGlobalNoteID

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"[noteArray count] = %lu",(unsigned long)[noteArray count]);
    return [noteArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MySingleton* singleton = [MySingleton getInstance];
    
    MainViewCollectionCell * myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellItem" forIndexPath:indexPath];
    
    //set button title
    NSString * myTitle = [NSString stringWithFormat:@"%@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"NoteID"]]; //*
    [myCell.btn setTitle:myTitle forState:UIControlStateNormal];
    [myCell.btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    //for simple click on control button
    myCell.controlBtn.tag = indexPath.row;
    [myCell.controlBtn addTarget:self action:@selector(handleControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    myCell.cancelBtn.tag = indexPath.row;
    [myCell.cancelBtn addTarget:self action:@selector(handleControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    myCell.editBtn.tag = [myTitle intValue];
    [myCell.editBtn addTarget:self action:@selector(handleEditBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    myCell.shareBtn.hidden=true;
    
    /*
    myCell.shareBtn.tag = indexPath.row;
    [myCell.shareBtn addTarget:self action:@selector(handleShareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    */
     
    myCell.deleteBtn.tag = [myTitle intValue];
    [myCell.deleteBtn addTarget:self action:@selector(handleDeleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //hide control view
    if ([[noteControlBtnArray objectAtIndex:indexPath.row] boolValue]){
        myCell.controlView.hidden=false;
        myCell.controlView.userInteractionEnabled=true;
    }else{
        myCell.controlView.hidden=true;
        myCell.controlView.userInteractionEnabled=false;
    }
    
    myCell.nameLabel.text = [NSString stringWithFormat:@"%@ - %@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"Topic"],[[noteArray objectAtIndex:indexPath.row] objectForKey:@"SubTopic"]];
    
    //set background image
    NSString * status = [[noteArray objectAtIndex:indexPath.row] objectForKey:@"Status"];
    if ([status rangeOfString:@"normal"].location != NSNotFound){
        NSLog(@"normal board");
        [myCell.btn setBackgroundImage:[UIImage imageNamed:@"whiteboard"] forState:UIControlStateNormal];
    }else if ([status rangeOfString:@"exercise"].location != NSNotFound){
        [myCell.btn setBackgroundImage:[UIImage imageNamed:@"metalboard"] forState:UIControlStateNormal];
    }else if ([status rangeOfString:@"test"].location != NSNotFound){
        [myCell.btn setBackgroundImage:[UIImage imageNamed:@"graphboard"] forState:UIControlStateNormal];
    }else if ([status rangeOfString:@"competition"].location != NSNotFound){
        [myCell.btn setBackgroundImage:[UIImage imageNamed:@"corkboard"] forState:UIControlStateNormal];
    }else{
        [myCell.btn setBackgroundImage:[UIImage imageNamed:@"chalkboard"] forState:UIControlStateNormal];
    }
    
    NSString * tnContent = nil;
    tnContent = [NSString stringWithFormat:@"%@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"Thumbnail"]];
    //UIImageView *imageView = nil;
    if (tnContent != nil && ![tnContent  isEqual: @""]){
        //NSLog(@"tnContent = %@", tnContent);
        tnContent = [tnContent stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
        //NSData * tnBase64Data = [[NSData alloc] initWithBase64EncodedString:tnContent options:0];
        //UIImage * tnImage = [[UIImage alloc] initWithData:tnBase64Data];
        UIImage * tnImage =[MySingleton decodeBase64ToImage:tnContent];
        
        //put image into button
        myCell.myThumbnail.image = tnImage;
    }
    
    NSString * NoteID = [NSString stringWithFormat:@"%@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"NoteID"]]; //*
    NSString * QuestionID = [NSString stringWithFormat:@"%@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"QuestionID"]]; //*
    NSString * Difficulty = [NSString stringWithFormat:@"%@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"Difficulty"]]; //*
    NSString * FromUserID = [NSString stringWithFormat:@"%@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"FromUserID"]]; //*
    NSString * UserName = [NSString stringWithFormat:@"%@",[[noteArray objectAtIndex:indexPath.row] objectForKey:@"UserName"]]; //*
    
    NSString * difficultyText = @"";
    if ([Difficulty  isEqual: @"1"]){
        difficultyText = NSLocalizedStringFromTableInBundle(@"difficultySC0", nil, singleton.globalLocaleBundle, nil);
    }else if ([Difficulty  isEqual: @"2"]){
        difficultyText = NSLocalizedStringFromTableInBundle(@"difficultySC1", nil, singleton.globalLocaleBundle, nil);
    }else if ([Difficulty  isEqual: @"3"]){
        difficultyText = NSLocalizedStringFromTableInBundle(@"difficultySC2", nil, singleton.globalLocaleBundle, nil);
    }
    NSString * difficultyLabel = NSLocalizedStringFromTableInBundle(@"difficultyLabel", nil, singleton.globalLocaleBundle, nil);
    
    if ([status rangeOfString:@"normal"].location != NSNotFound){
        NSString* ribbonNote = NSLocalizedStringFromTableInBundle(@"disTypeSC0", nil, singleton.globalLocaleBundle, nil);
        myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@ #%@",ribbonNote,NoteID];
    }else if ([status rangeOfString:@"exercise"].location != NSNotFound){
        NSString* ribbonEX = NSLocalizedStringFromTableInBundle(@"disTypeSC1", nil, singleton.globalLocaleBundle, nil);
        if ([QuestionID  isEqual: @"<null>"])
            myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@",ribbonEX];
        else
            myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@ #%@",ribbonEX,QuestionID];
        myCell.leftDownLabel.text = [NSString stringWithFormat:@"%@: %@",difficultyLabel,difficultyText];
    }else if ([status rangeOfString:@"test"].location != NSNotFound){
        NSString* ribbonTest = NSLocalizedStringFromTableInBundle(@"disTypeSC2", nil, singleton.globalLocaleBundle, nil);
        if ([QuestionID  isEqual: @"<null>"])
            myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@",ribbonTest];
        else
            myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@ #%@",ribbonTest,QuestionID];
        myCell.leftDownLabel.text = [NSString stringWithFormat:@"%@: %@",difficultyLabel,difficultyText];
    }else if ([status rangeOfString:@"competition"].location != NSNotFound){
        NSString* ribbonCompetition = NSLocalizedStringFromTableInBundle(@"disTypeSC3", nil, singleton.globalLocaleBundle, nil);
        if ([QuestionID  isEqual: @"<null>"])
            myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@",ribbonCompetition];
        else
            myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@ #%@",ribbonCompetition,QuestionID];
        myCell.leftDownLabel.text = [NSString stringWithFormat:@"%@: %@",difficultyLabel,difficultyText];
    }
    
    //FromUserID
    if(FromUserID != singleton.globalUserID){
        myCell.noteIDLabel.text = [NSString stringWithFormat:@"%@ (%@)",myCell.noteIDLabel.text,UserName];
    }
    
    if ([status rangeOfString:@"Pre"].location != NSNotFound){
        NSString* statusPre = NSLocalizedStringFromTableInBundle(@"statusPre", nil, singleton.globalLocaleBundle, nil);
        myCell.statusLabel.text = statusPre;
    }else if ([status rangeOfString:@"Post"].location != NSNotFound){
        NSString* statusPost = NSLocalizedStringFromTableInBundle(@"statusPost", nil, singleton.globalLocaleBundle, nil);
        myCell.statusLabel.text = statusPost;
    }

    //for simple click
    [myCell.btn addTarget:self action:@selector(handleNoteClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return myCell;
}
#pragma mark - UICollectionViewDelegate
/*
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
 
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
 
}
*/
@end
