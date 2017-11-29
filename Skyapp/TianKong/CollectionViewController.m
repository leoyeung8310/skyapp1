//
//  CollectionViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 12/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "CollectionViewController.h"
#import "MySingleton.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    collectionArray = [[NSArray alloc]init];
    collectionCount = 0;
    
    //get singleton
    MySingleton* singleton = [MySingleton getInstance];
    
    //localication
    NSString* backText = NSLocalizedStringFromTableInBundle(@"Back", nil, singleton.globalLocaleBundle, nil);
    self.backBtn.title = [NSString stringWithFormat:@"< %@ %@", singleton.globalUserName, backText];
    
    //set background image
    //NSString* imageName= NSLocalizedStringFromTableInBundle(@"mainViewBG", nil, singleton.globalLocaleBundle, nil);
    //self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:imageName]];
    //self.backgroundView.alpha = 0.1f;
    [self.view sendSubviewToBack:self.backgroundView];
    
    getCollectionsStatus = [self getCollection:singleton.globalUserID andServer:singleton.globalUserServer];
    
    if (getCollectionsStatus){
        NSLog(@"showCollections Success");
        for(int i =0; i < collectionCount; i++){
            NSLog(@"UserID : %@", [[collectionArray objectAtIndex:i] objectForKey:@"UserID"]);
            NSLog(@"GiftNo : %@", [[collectionArray objectAtIndex:i] objectForKey:@"GiftNo"]);
            NSLog(@"GiftSubNo : %@", [[collectionArray objectAtIndex:i] objectForKey:@"GiftSubNo"]);
        }
    }else{
        NSLog(@"showCollections Fail");
    }
    

}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (getCollectionsStatus){
        [self showCollections];
    }else{
        [self handleBack:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleBack:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCollections{
    MySingleton* singleton = [MySingleton getInstance];
    for(int i =0; i < singleton.ICON_COLLECT.count; i++){
        // create button object

        //boolean array
        NSMutableArray *boolArray = [[NSMutableArray alloc] init];
        for(int j =0; j < singleton.ICON_COLLECT.count; j++){
            boolArray[j] = @NO;
        }
        
        for(int j =0; j < collectionCount; j++){
            NSLog(@"c array = %@",[collectionArray objectAtIndex:j]);
            boolArray[[[[collectionArray objectAtIndex:j] objectForKey:@"GiftNo"] intValue]-1] = @YES;
        }
        
        UIButton * button =[UIButton buttonWithType:UIButtonTypeSystem];
        button.enabled=NO;
        
        //set button size
        [button sizeToFit];
        CGRect buttonFrame =button.frame;
        buttonFrame.size=CGSizeMake(200, 250);
        button.frame=buttonFrame;

        //set background image
        
        NSString * imageNormalLoc = [NSString stringWithFormat:@"%@_200x250", singleton.ICON_COLLECT[i][0] ];
        NSString * imageBlackLoc = [NSString stringWithFormat:@"%@_black", singleton.ICON_COLLECT[i][0] ];
        if ([boolArray[i] boolValue])
            [button setBackgroundImage:[UIImage imageNamed:imageNormalLoc] forState:UIControlStateNormal];
        else
            [button setBackgroundImage:[UIImage imageNamed:imageBlackLoc] forState:UIControlStateNormal];
        
        // set button center
        button.center=CGPointMake(140+250*(i%4),240+320*(i/4));
        
        //set number label size and location
        UILabel * numLabel = [[UILabel alloc] init]; //(x,y,w,h)
        [numLabel sizeToFit];
        CGRect labelFrame = numLabel.frame;
        labelFrame.size=CGSizeMake(200, 30);
        numLabel.frame = labelFrame;
        numLabel.center=CGPointMake(140+250*(i%4),100+320*(i/4));
        
        //set number label feature
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.textAlignment = NSTextAlignmentRight;
        numLabel.textColor=[UIColor blackColor];
        numLabel.text = [NSString stringWithFormat:@"%@ %d", @"NO. ", i+1];
        
        //set name label size and location
        UILabel * nameLabel = [[UILabel alloc] init]; //(x,y,w,h)
        [nameLabel sizeToFit];
        CGRect nameFrame = nameLabel.frame;
        nameFrame.size=CGSizeMake(200, 30);
        nameLabel.frame = nameFrame;
        nameLabel.center=CGPointMake(140+250*(i%4),380+320*(i/4));
        
        //set name label feature
        //nameLabel.backgroundColor = [UIColor clearColor];
        //nameLabel.textAlignment = NSTextAlignmentCenter;
        //nameLabel.textColor=[UIColor blackColor];
        //NSString * nameText = NSLocalizedStringFromTableInBundle(COLLECTION_NAME[i], nil, singleton.globalLocaleBundle, nil);
        //nameLabel.text = [NSString stringWithFormat:@"%@", nameText];
        //if (userGotThisAch)
        //    nameLabel.alpha = 1.0f;
        //else
        //    nameLabel.alpha = 0.0f;
     
        
        //add objects to UIView
        [self.view addSubview:numLabel];
        [self.view addSubview:button];
        
        //[self.view addSubview:nameLabel];
    }
}

- (bool)getCollection:(NSString *)UserID andServer:(NSString *)Server{
    bool boolSuccess = false;
    collectionArray = nil;
    collectionCount = 0;
    
    NSLog(@"getAllNoteByUserID");
    
    if([UserID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"loadCollections.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            collectionCount = [jsonData[@"count"] intValue];
            if (collectionCount > 0){
                collectionArray = [jsonData objectForKey:@"data"];
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

@end
