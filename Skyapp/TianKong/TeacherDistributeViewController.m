//
//  TeacherDistributeViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 18/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "TeacherDistributeViewController.h"
#import "MySingleton.h"

@interface TeacherDistributeViewController ()

@end

@implementation TeacherDistributeViewController

@synthesize distributeBtn;
@synthesize statusLabel;
@synthesize groupLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MySingleton* singleton = [MySingleton getInstance];
    //NSString* giftLabelText = NSLocalizedStringFromTableInBundle(@"giftLabelText", nil, singleton.globalLocaleBundle, nil);
    //giftLabel.text = [NSString stringWithFormat:@"%@", giftLabelText];
    NSString* groupLabelText = NSLocalizedStringFromTableInBundle(@"groupLabelText", nil, singleton.globalLocaleBundle, nil);
    groupLabel.text = [NSString stringWithFormat:@"%@", groupLabelText];
    NSString* distributeBtnText = NSLocalizedStringFromTableInBundle(@"distributeBtnText", nil, singleton.globalLocaleBundle, nil);
    [distributeBtn setTitle:distributeBtnText forState:UIControlStateNormal];
    
    //find gift access at DB
    /*
    bool successGift = [self getGiftAccessRightByUserID];
    selectedGift = @"";
    if (successGift){
        showGiftIdentifierArray = [[NSMutableArray alloc] init];
        showGiftStrArray = [[NSMutableArray alloc] init];
        showGiftImageNameArray = [[NSMutableArray alloc] init];
        for(int i =0; i < giftRightArrayCount; i++){
            [showGiftIdentifierArray addObject:[[giftRightArray objectAtIndex:i] objectForKey:@"GiftNo"]];
            NSString * giftText = @"Gift Number: ";
            [showGiftStrArray addObject:[NSString stringWithFormat:@"%@%@", giftText,[[giftRightArray objectAtIndex:i] objectForKey:@"GiftNo"]]];
            NSString * collectionName = singleton.ICON_COLLECT[[[[giftRightArray objectAtIndex:i] objectForKey:@"GiftNo"] intValue]-1 ][0];
            [showGiftImageNameArray addObject:collectionName];
        }
    }
    */
    
    NoOfAns = 0;
    NoOfAnsBox = 0;
    
    successGroupFind = [self getGroupByUserID:singleton.globalUserID andServer:singleton.globalUserServer];
    if (successGroupFind){
        //
    }else{
        NSLog(@"fail successGift");
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!successGroupFind){
        [self performSelector:@selector(noticeDismiss) withObject:nil afterDelay:0.1];
    }
}

- (void) setNoOfAnsBox:(int)myNum{
    NoOfAnsBox = myNum;
}

- (void) setNoOfAns:(int)myNum{
    NoOfAns = myNum;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
    if ([tableView.restorationIdentifier  isEqual: @"giftTableView"]){
        
        MySingleton* singleton = [MySingleton getInstance];
        if ([singleton.globalReceivedNoteStatus  isEqual: @"preOpen"] || [singleton.globalReceivedNoteStatus  isEqual: @"postOpen"])
            return 0;
        else
            return giftRightArrayCount;
     
        return 0;
    }*/
    if ([tableView.restorationIdentifier  isEqual: @"groupTableView"]){
        return groupDBArrayCount;
    }else{
        return 0;
    }
}

//UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if ([tableView.restorationIdentifier  isEqual: @"giftTableView"]){
        
        NSString *simpleTableIdentifier = [showGiftIdentifierArray objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.textLabel.text = [showGiftStrArray objectAtIndex:indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[showGiftImageNameArray objectAtIndex:indexPath.row]];
        
        return cell;
     
    }*/
    if ([tableView.restorationIdentifier  isEqual: @"groupTableView"]){
        NSString * tableIdentifier = [NSString stringWithFormat:@"%@",[[groupDBArray objectAtIndex:indexPath.row] objectForKey:@"GroupID"]]; //*
        NSString * groupName = [NSString stringWithFormat:@"%@",[[groupDBArray objectAtIndex:indexPath.row] objectForKey:@"GroupName"]]; //*
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
        }
        cell.textLabel.text = groupName;
        cell.imageView.image = [UIImage imageNamed:@"loadscreen"];
        
        return cell;
    }else{
        //no use
        static NSString *simpleTableIdentifier = @"SimpleTableCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        return cell;
    }
    
}

- (bool)getGroupByUserID:(NSString *)UserID andServer:(NSString *)Server{
    bool boolSuccess = false;
    groupDBArray = nil;
    groupDBArrayCount = 0;
    
    NSLog(@"getGroupByUserID");
    
    if([UserID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"loadGroup.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            groupDBArrayCount = [jsonData[@"count"] integerValue];
            if (groupDBArrayCount > 0){
                groupDBArray = [jsonData objectForKey:@"data"];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.restorationIdentifier  isEqual: @"giftTableView"]){
        // Save text of the selected cell:
        //UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        //selectedGift = cell.reuseIdentifier;
    }else if ([tableView.restorationIdentifier  isEqual: @"groupTableView"]){
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        selectedGroup = cell.reuseIdentifier;
    }else{
        //
    }
}


- (IBAction)handleDistribute:(id)sender {
    MySingleton* singleton = [MySingleton getInstance];
    
    //OFF BUTTON
    distributeBtn.enabled = NO;
    UIColor *color = [UIColor lightGrayColor];
    [sender setTitleColor:color forState:UIControlStateNormal];
    
    [MySingleton startLoading:self.view];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        bool success = [self doDistribute:singleton.globalUserID andLoc:singleton.globalLocInfo andServer:singleton.globalUserServer];
        [MySingleton endLoading:self.view andSuccess:success];
        if (success){
            //[self dismissViewControllerAnimated:YES completion:nil];
            NSString* successMessage = NSLocalizedStringFromTableInBundle(@"completeDistributeText", nil, singleton.globalLocaleBundle, nil);
            statusLabel.text = successMessage;
        }else{
            //[self alertStatus:@"Share Fail Content" :@"Share Fail Heading":0];
            NSString* failMessage = NSLocalizedStringFromTableInBundle(@"selectGroupContentText", nil, singleton.globalLocaleBundle, nil);
            statusLabel.text = failMessage;
            
            distributeBtn.enabled = YES;
            UIColor *color = [UIColor redColor];
            [sender setTitleColor:color forState:UIControlStateNormal];
        }
    });
}


-(bool)doDistribute:(NSString *)UserID andLoc:(NSString *)Loc andServer:(NSString *)Server{
    MySingleton* singleton = [MySingleton getInstance];

    NSLog (@"selectedGroup = %@",selectedGroup);
    
    bool boolSuccess = false;
    
    if ([selectedGroup  isEqual: @""] ||  selectedGroup == nil){
        //alert to select group
        NSString* selectGroupHeadText = NSLocalizedStringFromTableInBundle(@"selectGroupHeadText", nil, singleton.globalLocaleBundle, nil);
        NSString* selectGroupContentText = NSLocalizedStringFromTableInBundle(@"selectGroupContentText", nil, singleton.globalLocaleBundle, nil);
        [MySingleton alertStatus:selectGroupContentText:selectGroupHeadText:0];
    } else {
        bool isNormal = [singleton.globalReceivedNoteStatus isEqual: @"normal"];
        
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:Loc] forKey:@"Location"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalOnSelectedNoteID] forKey:@"NoteID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:selectedGroup] forKey:@"GroupID"]; //
        [dataInput setObject:@"-1" forKey:@"GiftNo"]; //
        [dataInput setObject:@"0" forKey:@"GiftSubNo"]; //
        [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",NoOfAnsBox]] forKey:@"NoOfAnsBox"]; //
        [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",NoOfAns]] forKey:@"NoOfAns"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteStatus] forKey:@"DistributeType"]; //
        
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteSubject] forKey:@"Subject"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteTopic] forKey:@"Topic"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteSubTopic] forKey:@"SubTopic"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteKeywords] forKey:@"Keywords"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteRemarks] forKey:@"Remarks"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteDifficulty] forKey:@"Difficulty"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteDifficultyPresentation] forKey:@"DifficultyPresentation"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteHighlightAns] forKey:@"HighlightAns"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteGiveGift] forKey:@"GiveGift"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteTimeLimit] forKey:@"TimeLimit"]; //
        [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteMaxTrial] forKey:@"MaxTrial"]; //

        
        //connect server
        NSMutableDictionary *jsonData;
        
        if (isNormal){
            jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"distributeNote.php" andDataInput:dataInput];
        }else{
            jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"addQuestionAndDistribute.php" andDataInput:dataInput];
        }
        
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



-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TeacherViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
}


@end
