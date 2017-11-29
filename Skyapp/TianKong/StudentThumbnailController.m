//
//  StudentThumbnailController.m
//  Skyapp
//
//  Created by Cheuk yu Yeung on 7/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "StudentThumbnailController.h"
#import "StudentThumbnailHeader.h"
#import "StudentThumbnailCell.h"
#import "MySingleton.h"

@interface StudentThumbnailController ()

@end

@implementation StudentThumbnailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self allocValues];
}

- (void) allocValues{
    srArr = [[NSArray alloc] init];
    srArrCount = 0;
    successSR = false;
    srSplitArr = [[NSMutableArray alloc] init];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //refresh
    [self handleRefresh:nil event:nil];
    
    // set up toolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:toolBar];
    
    UIBarButtonItem *fixed1= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed1.width = 20.0f;
       UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *imageRe =[[UIImage imageNamed:@"refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *refreshButtonItem =
    [[UIBarButtonItem alloc] initWithImage:imageRe
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleRefresh:event:)];
    
    /*
    UIImage *imageRecord =[[UIImage imageNamed:@"read student record"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *recordButtonItem =
    [[UIBarButtonItem alloc] initWithImage:imageRecord
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(openStudentRecord)];
    */
    toolBar.items = [NSArray arrayWithObjects:flex1, refreshButtonItem, flex2, nil];
    //toolBar.items = [NSArray arrayWithObjects:flex1, refreshButtonItem, fixed1, recordButtonItem, flex2, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSLog(@"[srSplitArr count] = %lu",(unsigned long)[srSplitArr count]);
    return [srSplitArr count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"[[srSplitArr objectAtIndex:section] count]= %lu",(unsigned long)[[srSplitArr objectAtIndex:section] count]);
    return [[srSplitArr objectAtIndex:section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"viewForSupplementaryElementOfKind");
    MySingleton* singleton = [MySingleton getInstance];
    
    //configure heading
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        StudentThumbnailHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if (indexPath.section == 0)
            headerView.actHeadLabel.text = NSLocalizedStringFromTableInBundle(@"actHeadLabel", nil, singleton.globalLocaleBundle, nil);
        else
            headerView.actHeadLabel.text = @"";
        
        NSString * groupName = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:0] objectForKey:@"GroupName"]];
        NSString * questionID = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:0] objectForKey:@"QuestionID"]];
        
        NSString * Subject = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:0] objectForKey:@"Subject"]];
        NSDictionary * subjectToName  = @{ @"maths"   : NSLocalizedStringFromTableInBundle(@"subjectSC0", nil, singleton.globalLocaleBundle, nil),
                                           @"english" : NSLocalizedStringFromTableInBundle(@"subjectSC1", nil, singleton.globalLocaleBundle, nil),
                                           @"chinese" : NSLocalizedStringFromTableInBundle(@"subjectSC2", nil, singleton.globalLocaleBundle, nil),
                                           @"others" : NSLocalizedStringFromTableInBundle(@"subjectSC3", nil, singleton.globalLocaleBundle, nil),
                                           };
        for (NSString* key in subjectToName) {
            if ([Subject isEqualToString:key]){
                Subject = [NSString stringWithFormat:@"%@",subjectToName[key]];
            }
        }
        
        NSString * QuestionType = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:0] objectForKey:@"QuestionType"]];
        NSDictionary * questionToName  = @{ @"normal"   : NSLocalizedStringFromTableInBundle(@"disTypeSC0", nil, singleton.globalLocaleBundle, nil),
                                            @"exercise" : NSLocalizedStringFromTableInBundle(@"disTypeSC1", nil, singleton.globalLocaleBundle, nil),
                                            @"test" : NSLocalizedStringFromTableInBundle(@"disTypeSC2", nil, singleton.globalLocaleBundle, nil),
                                            @"competition" : NSLocalizedStringFromTableInBundle(@"disTypeSC3", nil, singleton.globalLocaleBundle, nil),
                                            };
        for (NSString* key in questionToName) {
            if ([QuestionType isEqualToString:key]){
                QuestionType = [NSString stringWithFormat:@"%@",questionToName[key]];
            }
        }
        
        NSString * Topic = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:0] objectForKey:@"Topic"]];
        NSString * SubTopic = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:0] objectForKey:@"SubTopic"]];
        
        NSString * activityName = NSLocalizedStringFromTableInBundle(@"activityName", nil, singleton.globalLocaleBundle, nil);
        headerView.statusLabel.text = [NSString stringWithFormat:@"%@ - %@: %@ - %@ %@ - %@ %@",groupName,activityName,questionID,Subject,QuestionType,Topic,SubTopic];
        
        reusableview = headerView;
    }
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //configure cell
    StudentThumbnailCell * myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellItem" forIndexPath:indexPath];
    
    NSString * tnContent = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Thumbnail"]];
    NSString * status = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"QuestionType"]];
    NSString * myTitle = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"studentNoteID"]];
    
    //ClassNo and UserName
    NSString * classNo = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"ClassNo"]];
    myCell.classNoLabel.text = classNo;
    
    NSString * studentName = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"UserName"]];
    myCell.studentLabel.text = studentName;
    
    //thumbnailBtn
    [myCell.thumbnailBtn setTitle:myTitle forState:UIControlStateNormal];
    [myCell.thumbnailBtn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    //set background image
    if ([status rangeOfString:@"normal"].location != NSNotFound){
        [myCell.thumbnailBtn setBackgroundImage:[UIImage imageNamed:@"whiteboard"] forState:UIControlStateNormal];
    }else if ([status rangeOfString:@"exercise"].location != NSNotFound){
        [myCell.thumbnailBtn setBackgroundImage:[UIImage imageNamed:@"metalboard"] forState:UIControlStateNormal];
    }else if ([status rangeOfString:@"test"].location != NSNotFound){
        [myCell.thumbnailBtn setBackgroundImage:[UIImage imageNamed:@"graphboard"] forState:UIControlStateNormal];
    }else if ([status rangeOfString:@"competition"].location != NSNotFound){
        [myCell.thumbnailBtn setBackgroundImage:[UIImage imageNamed:@"corkboard"] forState:UIControlStateNormal];
    }else{
        [myCell.thumbnailBtn setBackgroundImage:[UIImage imageNamed:@"chalkboard"] forState:UIControlStateNormal];
    }
    
    UIImageView *imageView = nil;
    if (tnContent != nil && ![tnContent  isEqual: @""]){
        //NSLog(@"tnContent = %@", tnContent);
        tnContent = [tnContent stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
        //NSData * tnBase64Data = [[NSData alloc] initWithBase64EncodedString:tnContent options:0];
        //UIImage * tnImage = [[UIImage alloc] initWithData:tnBase64Data];
        UIImage * tnImage =[MySingleton decodeBase64ToImage:tnContent];
        
        //put image into button
        imageView = [[UIImageView alloc] initWithImage:tnImage];
        imageView.frame = CGRectMake(5,5, myCell.thumbnailBtn.frame.size.width-10,myCell.thumbnailBtn.frame.size.height-10);
        //imageView.center = myCell.thumbnailBtn.center;
        [myCell.thumbnailBtn addSubview:imageView];
    }
    
    myCell.thumbnailBtn.tag = [myTitle intValue];
    [myCell.thumbnailBtn addTarget:self action:@selector(viewBtnTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    
    //NSLog(@"iv = %@",NSStringFromCGRect(imageView.frame));
    //NSLog(@"iv center = %@",NSStringFromCGPoint(imageView.center));
    //NSLog(@"thumbnailBtn = %@",NSStringFromCGRect(myCell.thumbnailBtn.frame));
    //NSLog(@"thumbnailBtn center = %@",NSStringFromCGPoint(myCell.thumbnailBtn.center));
    
    return myCell;
}

-(void)splitSR{
    srSplitArr = [[NSMutableArray alloc] init];
    NSString * curQuestionID = @"-1";
    NSMutableArray * tmpArr = nil;
    for (int i = 0; i < srArr.count; i++){
        NSString * QuestionID = [[srArr objectAtIndex:i] objectForKey:@"QuestionID"];
        if (curQuestionID == QuestionID){
            [tmpArr addObject:[srArr objectAtIndex:i]];
        }else{
            curQuestionID = QuestionID;
            if (i != 0 && tmpArr!=nil)
                [srSplitArr addObject:tmpArr];
            tmpArr = [[NSMutableArray alloc] init];
            [tmpArr addObject:[srArr objectAtIndex:i]];
        }
    }
    
    if (tmpArr != nil){
        [srSplitArr addObject:tmpArr];
    }
}

-(bool)queryStudentRecord:(NSString*)NoteID andServer:(NSString *)Server{
    
    bool boolSuccess = false;
    srArr = nil;
    srArrCount = 0;
    
    NSLog(@"queryStudentRecord");
    
    if([NoteID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"studentThumbnails.php" andDataInput:dataInput];
        NSLog(@"jsonData = %@",jsonData);
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            srArrCount = [jsonData[@"count"] intValue];
            if (srArrCount > 0){
                srArr = [jsonData objectForKey:@"data"];
                //NSLog(@"srArr = %@",srArr);
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

-(void)handleRefresh:(id)sender event:(id)event{
    NSLog(@"handleRefresh");
    MySingleton* singleton = [MySingleton getInstance];
    [MySingleton startLoading:self.view];
    
    [self allocValues];
    
    //ON Button
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //do function
        successSR = [self queryStudentRecord:singleton.globalOnSelectedNoteID andServer:singleton.globalUserServer];
        [MySingleton endLoading:self.view andSuccess:successSR];
        if (successSR){
            [self splitSR];
            [self.collectionView reloadData];
        }else{
            if (sender == nil){
                [self performSelector:@selector(noticeDismiss) withObject:nil afterDelay:0.1];
            }
        }
    });
}

-(void)viewBtnTapped:(id)sender event:(id)event{
    UIButton * btn = (UIButton*)sender;
    NSLog(@"Open View Only Note = %ld",(long)btn.tag);
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalViewOnlyNoteID = [NSString stringWithFormat:@"%ld",(long)btn.tag];
    [self performSegueWithIdentifier: @"viewOnlySegue" sender: self];
    
}

-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
}

-(void)openStudentRecord{
    [self dismissViewControllerAnimated:true completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openStudentRecord"
                                                        object:nil
                                                      userInfo:nil];
}

@end
