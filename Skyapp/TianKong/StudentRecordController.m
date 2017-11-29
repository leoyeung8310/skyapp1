//
//  StudentRecordController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "StudentRecordController.h"
#import "StudentRecordHeader.h"
#import "StudentRecordCell.h"
#import "MySingleton.h"
#import "QuartzCore/QuartzCore.h"


@interface StudentRecordController ()

@end

@implementation StudentRecordController

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
    buttonToCommentDict = [[NSMutableDictionary alloc] init];
    buttonToNameDict = [[NSMutableDictionary alloc] init];
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
    fixed1.width = 20.0f; // or whatever you want
    UIBarButtonItem *fixed2= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixed2.width = 20.0f; // or whatever you want
    UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    /*
    UIImage *imageEm =[[UIImage imageNamed:@"email"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *emailButtonItem =
    [[UIBarButtonItem alloc] initWithImage:imageEm
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleEmail)];
    */
    UIImage *imageRe =[[UIImage imageNamed:@"refresh"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *refreshButtonItem =
    [[UIBarButtonItem alloc] initWithImage:imageRe
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(handleRefresh:event:)];
    
    UIImage *imageFR =[[UIImage imageNamed:@"fullreport"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *fullReportButtonItem =
    [[UIBarButtonItem alloc] initWithImage:imageFR
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(openFullReport)];
    
    toolBar.items = [NSArray arrayWithObjects:flex1, refreshButtonItem, fixed1, fullReportButtonItem, flex2, nil];
    //toolBar.items = [NSArray arrayWithObjects:flex1, emailButtonItem, fixed1, refreshButtonItem, fixed2, thumbnailButtonItem, flex2, nil];
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
        StudentRecordHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if (indexPath.section == 0)
            headerView.actHeadLabel.text = NSLocalizedStringFromTableInBundle(@"actHeadLabel", nil, singleton.globalLocaleBundle, nil);
        else
            headerView.actHeadLabel.text = @"";

        headerView.studentLabel.text = NSLocalizedStringFromTableInBundle(@"studentLabel", nil, singleton.globalLocaleBundle, nil);
        headerView.marksLabel.text = NSLocalizedStringFromTableInBundle(@"marksLabel", nil, singleton.globalLocaleBundle, nil);
        headerView.feelingLabel.text = NSLocalizedStringFromTableInBundle(@"feelingLabel", nil, singleton.globalLocaleBundle, nil);
        headerView.trialsLabel.text = NSLocalizedStringFromTableInBundle(@"trialsLabel", nil, singleton.globalLocaleBundle, nil);
        headerView.timeTakenLabel.text = NSLocalizedStringFromTableInBundle(@"timeTakenLabel", nil, singleton.globalLocaleBundle, nil);
        headerView.commentLabel.text = NSLocalizedStringFromTableInBundle(@"commentLabel", nil, singleton.globalLocaleBundle, nil);
        headerView.readLabel.text = NSLocalizedStringFromTableInBundle(@"readLabel", nil, singleton.globalLocaleBundle, nil);
        
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
    StudentRecordCell * myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellItem" forIndexPath:indexPath];
    
    NSString * classNo = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"ClassNo"]];
    myCell.classNoLabel.text = classNo;
    
    NSString * studentName = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"UserName"]];
    myCell.studentLabel.text = studentName;
   
    NSString * Marks = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Marks"]];
    NSString * NoOfAnsBox = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"NoOfAnsBox"]];
    float systemPre = ceil([Marks floatValue]/[NoOfAnsBox floatValue]*100);
    myCell.marksLabel.text = [NSString stringWithFormat:@"%@/%@ (%d%%)",Marks,NoOfAnsBox,(int)systemPre];
    
    NSString * CountCorrect = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"CountCorrect"]];
    NSString * NoOfAns = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"NoOfAns"]];
    float studentPre = ceil([CountCorrect floatValue]/[NoOfAns floatValue]*100);
    myCell.CountCorrect.text = [NSString stringWithFormat:@"%@/%@ (%d%%)",CountCorrect,NoOfAns,(int)studentPre];
    
    myCell.CountIncorrect.text = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"CountIncorrect"]];
    myCell.CountHappy.text = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"CountHappy"]];
    myCell.CountNoIdea.text = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"CountNoIdea"]];
    myCell.CountTimesUp.text = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"CountTimesUp"]];
    
    NSString * NoOfTrial = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"NoOfTrial"]];
    NSString * MaxTrial = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"MaxTrial"]];
    if ([MaxTrial  isEqual: @"0"]){
        myCell.trialsLabel.text = NoOfTrial;
    }else{
        myCell.trialsLabel.text = [NSString stringWithFormat:@"%@/%@",NoOfTrial,MaxTrial];
    }
    
    NSString * TimeTaken = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"TimeTaken"]];
    NSString * TimeLimit = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"TimeLimit"]];
    if ([TimeLimit  isEqual: @"0"]){
        myCell.timeTakenLabel.text = TimeTaken;
    }else{
        myCell.timeTakenLabel.text = [NSString stringWithFormat:@"%@/%@",TimeTaken,TimeLimit];
    }
    
    NSString * Comments = [NSString stringWithFormat:@"%@",[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Comments"]];
    myCell.viewCommentBtn.tag = [[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"studentNoteID"] intValue];
    if (![Comments  isEqual: @""]){\
        [buttonToCommentDict setValue:Comments forKey:[NSString stringWithFormat:@"%ld",(long)myCell.viewCommentBtn.tag]];
        [buttonToNameDict setValue:studentName forKey:[NSString stringWithFormat:@"%ld",(long)myCell.viewCommentBtn.tag]];
        myCell.viewCommentBtn.enabled=YES;
        [myCell.viewCommentBtn addTarget:self action:@selector(commentViewBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        myCell.viewCommentBtn.enabled=NO;
    }
    
    myCell.viewBtn.tag = [[[[srSplitArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"studentNoteID"] intValue];
    [myCell.viewBtn addTarget:self action:@selector(viewBtnTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    return myCell;
}

-(void) commentViewBtnTapped:(id)sender{
    MySingleton* singleton = [MySingleton getInstance];
    UIButton * btn = (UIButton*)sender;
    NSString * tag = [NSString stringWithFormat:@"%ld",(long)btn.tag];
    NSString * studentName = [buttonToNameDict valueForKey:tag];
    NSString * comments = [buttonToCommentDict valueForKey:tag];
    NSString * say = NSLocalizedStringFromTableInBundle(@"say", nil, singleton.globalLocaleBundle, nil);
    [MySingleton alertStatus:comments :[NSString stringWithFormat:@"%@ %@",studentName,say] :0];
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
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"studentPerformance.php" andDataInput:dataInput];
        NSLog(@"jsonData = %@",jsonData);
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            srArrCount = [jsonData[@"count"] intValue];
            if (srArrCount > 0){
                srArr = [jsonData objectForKey:@"data"];
                NSLog(@"srArr = %@",srArr);
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


-(bool)queryEmailStudentRecord:(NSString*)NoteID andServer:(NSString *)Server{
    bool boolSuccess = false;
    srArr = nil;
    srArrCount = 0;
    
    NSLog(@"queryEmailStudentRecord");
    
    if([NoteID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"emailStudentPerformance.php" andDataInput:dataInput];
        NSLog(@"jsonData = %@",jsonData);
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
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

-(void)openFullReport{
    NSLog(@"open full report");
    [self noticeDismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callWebViewReport" //NotTouched
                                                        object:self
                                                      userInfo:nil];
}

@end
