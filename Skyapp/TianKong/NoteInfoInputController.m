//
//  NoteInfoInputController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 25/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "NoteInfoInputController.h"
#import "MySingleton.h"
#import "PickerViewController.h"

@interface NoteInfoInputController ()

@end

@implementation NoteInfoInputController

@synthesize headLabel;
@synthesize subjectLabel;
@synthesize disTypeLabel;
@synthesize topicLabel;
@synthesize subTopicLabel;
@synthesize keywordsTF;
@synthesize remarksLabel;
@synthesize disTypeSC;
@synthesize highlightAnsLabel;
@synthesize giveGiftLabel;
@synthesize giveGiftSC;
@synthesize timeLimitLabel;
@synthesize maxTrialLabel;
@synthesize maxTrialSC;
@synthesize subjectSC;
@synthesize subTopicTF;
@synthesize highlightAnsSC;
@synthesize timeLimitSC;
@synthesize topicTF;
@synthesize remarksTF;
@synthesize difficultyLabel;
@synthesize difficultySC;
@synthesize difficultyPresentationLabel;
@synthesize difficultyPresentationSC;
@synthesize okBtn;
@synthesize statusLabel;
@synthesize keywordsLabel;
@synthesize madeChange;
@synthesize pickTopicBtn;
@synthesize pickSubTopicBtn;
@synthesize poc;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //seqNumTF.delegate = self;
    
    MySingleton* singleton = [MySingleton getInstance];
    
    madeChange = false;
    //textView delegate
    topicTF.delegate=self;
    subTopicTF.delegate=self;
    keywordsTF.delegate=self;
    remarksTF.delegate=self;
    
    headLabel.text = NSLocalizedStringFromTableInBundle(@"headLabel", nil, singleton.globalLocaleBundle, nil);
    
    subjectLabel.text = NSLocalizedStringFromTableInBundle(@"subjectLabel", nil, singleton.globalLocaleBundle, nil);
    topicLabel.text = NSLocalizedStringFromTableInBundle(@"topicLabel", nil, singleton.globalLocaleBundle, nil);
    subTopicLabel.text = NSLocalizedStringFromTableInBundle(@"subTopicLabel", nil, singleton.globalLocaleBundle, nil);
    keywordsLabel.text = NSLocalizedStringFromTableInBundle(@"keywordsLabel", nil, singleton.globalLocaleBundle, nil);
    remarksLabel.text = NSLocalizedStringFromTableInBundle(@"remarksLabel", nil, singleton.globalLocaleBundle, nil);
    
    disTypeLabel.text = NSLocalizedStringFromTableInBundle(@"disTypeLabel", nil, singleton.globalLocaleBundle, nil);
    difficultyLabel.text = NSLocalizedStringFromTableInBundle(@"difficultyLabel", nil, singleton.globalLocaleBundle, nil);
    difficultyPresentationLabel.text = NSLocalizedStringFromTableInBundle(@"difficultyPresentationLabel", nil, singleton.globalLocaleBundle, nil);
    highlightAnsLabel.text = NSLocalizedStringFromTableInBundle(@"highlightAnsLabel", nil, singleton.globalLocaleBundle, nil);
    giveGiftLabel.text = NSLocalizedStringFromTableInBundle(@"giveGiftLabel", nil, singleton.globalLocaleBundle, nil);
    timeLimitLabel.text = NSLocalizedStringFromTableInBundle(@"timeLimitLabel", nil, singleton.globalLocaleBundle, nil);
    maxTrialLabel.text = NSLocalizedStringFromTableInBundle(@"maxTrialLabel", nil, singleton.globalLocaleBundle, nil);

    NSString * okBtnText = NSLocalizedStringFromTableInBundle(@"SaveBtn", nil, singleton.globalLocaleBundle, nil);
    [okBtn setTitle:okBtnText forState:UIControlStateNormal];
    
    [subjectSC setTitle:NSLocalizedStringFromTableInBundle(@"subjectSC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [subjectSC setTitle:NSLocalizedStringFromTableInBundle(@"subjectSC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    [subjectSC setTitle:NSLocalizedStringFromTableInBundle(@"subjectSC2", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:2];
    [subjectSC setTitle:NSLocalizedStringFromTableInBundle(@"subjectSC3", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:3];
    
    [disTypeSC setTitle:NSLocalizedStringFromTableInBundle(@"disTypeSC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [disTypeSC setTitle:NSLocalizedStringFromTableInBundle(@"disTypeSC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    [disTypeSC setTitle:NSLocalizedStringFromTableInBundle(@"disTypeSC2", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:2];
    [disTypeSC setTitle:NSLocalizedStringFromTableInBundle(@"disTypeSC3", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:3];
    
    [difficultySC setTitle:NSLocalizedStringFromTableInBundle(@"difficultySC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [difficultySC setTitle:NSLocalizedStringFromTableInBundle(@"difficultySC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    [difficultySC setTitle:NSLocalizedStringFromTableInBundle(@"difficultySC2", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:2];
    
    [difficultyPresentationSC setTitle:NSLocalizedStringFromTableInBundle(@"difficultyPresentationSC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [difficultyPresentationSC setTitle:NSLocalizedStringFromTableInBundle(@"difficultyPresentationSC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    
    [highlightAnsSC setTitle:NSLocalizedStringFromTableInBundle(@"highlightAnsSC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [highlightAnsSC setTitle:NSLocalizedStringFromTableInBundle(@"highlightAnsSC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    
    [giveGiftSC setTitle:NSLocalizedStringFromTableInBundle(@"giveGiftSC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [giveGiftSC setTitle:NSLocalizedStringFromTableInBundle(@"giveGiftSC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    
    [timeLimitSC setTitle:NSLocalizedStringFromTableInBundle(@"timeLimitSC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [timeLimitSC setTitle:NSLocalizedStringFromTableInBundle(@"timeLimitSC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    [timeLimitSC setTitle:NSLocalizedStringFromTableInBundle(@"timeLimitSC2", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:2];
    [timeLimitSC setTitle:NSLocalizedStringFromTableInBundle(@"timeLimitSC3", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:3];
    [timeLimitSC setTitle:NSLocalizedStringFromTableInBundle(@"timeLimitSC4", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:4];
    
    [maxTrialSC setTitle:NSLocalizedStringFromTableInBundle(@"maxTrialSC0", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:0];
    [maxTrialSC setTitle:NSLocalizedStringFromTableInBundle(@"maxTrialSC1", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:1];
    [maxTrialSC setTitle:NSLocalizedStringFromTableInBundle(@"maxTrialSC2", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:2];
    [maxTrialSC setTitle:NSLocalizedStringFromTableInBundle(@"maxTrialSC3", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:3];
    [maxTrialSC setTitle:NSLocalizedStringFromTableInBundle(@"maxTrialSC4", nil, singleton.globalLocaleBundle, nil) forSegmentAtIndex:4];
    
    [subjectSC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    [disTypeSC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    [difficultySC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    [difficultyPresentationSC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    [highlightAnsSC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    [giveGiftSC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    [timeLimitSC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    [maxTrialSC addTarget:self action:@selector(SCChanged) forControlEvents:UIControlEventValueChanged];
    
    NSDictionary * statusToNum  = @{ @"normal"   : @"0",
                                     @"exercise" : @"1",
                                     @"test" : @"2",
                                     @"competition" : @"3",
                                     };
    //NSLog(@"singleton.globalReceivedNoteStatus = %@", singleton.globalReceivedNoteStatus);
    if (singleton.globalReceivedNoteStatus!=nil){
        //NSLog(@"singleton.globalReceivedNoteStatus = %d", [[statusToNum objectForKey:singleton.globalReceivedNoteStatus] intValue]);
        chosenDisType = singleton.globalReceivedNoteStatus;
        disTypeSC.selectedSegmentIndex=[[statusToNum objectForKey:singleton.globalReceivedNoteStatus] intValue];
    }
    
    //set default value
    if (singleton.globalReceivedNoteStatus ==nil || [singleton.globalReceivedNoteStatus isEqual:@""] ){
        chosenDisType = @"normal";
    }
    [self refreshSelection];
    
    NSDictionary * subjectToNum  = @{ @"maths"   : @"0",
                                     @"english" : @"1",
                                     @"chinese" : @"2",
                                     @"others" : @"3",
                                     };
    if (singleton.globalReceivedNoteSubject!=nil){
        subjectSC.selectedSegmentIndex=[[subjectToNum objectForKey:singleton.globalReceivedNoteSubject] intValue];
    }
    if (singleton.globalReceivedNoteTopic!=nil){
        topicTF.text = singleton.globalReceivedNoteTopic;
    }
    if (singleton.globalReceivedNoteSubTopic!=nil){
        subTopicTF.text = singleton.globalReceivedNoteSubTopic;
    }
    if (singleton.globalReceivedNoteKeywords!=nil){
        keywordsTF.text = singleton.globalReceivedNoteKeywords;
    }
    if (singleton.globalReceivedNoteRemarks!=nil){
        remarksTF.text = singleton.globalReceivedNoteRemarks;
    }
    
    if (![singleton.globalReceivedNoteStatus  isEqual: @"normal"]){
        NSDictionary * noteDifficultyToNum  = @{ @"1"   : @"0",
                                                 @"2" : @"1",
                                                 @"3" : @"2",
                                                 };
        if (singleton.globalReceivedNoteDifficulty!=nil){
            difficultySC.selectedSegmentIndex=[[noteDifficultyToNum objectForKey:singleton.globalReceivedNoteDifficulty] intValue];
        }
        
        if (singleton.globalReceivedNoteDifficultyPresentation!=nil){
            NSLog(@"globalReceivedNoteDifficultyPresentation %@", singleton.globalReceivedNoteDifficultyPresentation);
            difficultyPresentationSC.selectedSegmentIndex=[singleton.globalReceivedNoteDifficultyPresentation intValue];
        }
        if (singleton.globalReceivedNoteHighlightAns!=nil){
            highlightAnsSC.selectedSegmentIndex=[singleton.globalReceivedNoteHighlightAns intValue];
        }
        if (singleton.globalReceivedNoteGiveGift!=nil){
            giveGiftSC.selectedSegmentIndex=[singleton.globalReceivedNoteGiveGift intValue];
        }
        NSDictionary * timeLimitToNum  = @{ @"0" : @"0",
                                            @"10" : @"1",
                                            @"30" : @"2",
                                            @"60" : @"3",
                                            @"300" : @"4",
                                            };
        if (singleton.globalReceivedNoteTimeLimit!=nil){
            timeLimitSC.selectedSegmentIndex=[[timeLimitToNum objectForKey:singleton.globalReceivedNoteTimeLimit] intValue];
        }
        NSDictionary * maxTrialToNum  = @{ @"0" : @"0",
                                           @"1" : @"1",
                                           @"3" : @"2",
                                           @"5" : @"3",
                                           @"10" : @"4",
                                           };
        if (singleton.globalReceivedNoteMaxTrial!=nil){
            maxTrialSC.selectedSegmentIndex=[[maxTrialToNum objectForKey:singleton.globalReceivedNoteMaxTrial] intValue];
        }
    }
    
    [pickTopicBtn setTitle:NSLocalizedStringFromTableInBundle(@"pickName", nil, singleton.globalLocaleBundle, nil) forState:UIControlStateNormal];
    [pickSubTopicBtn setTitle:NSLocalizedStringFromTableInBundle(@"pickName", nil, singleton.globalLocaleBundle, nil) forState:UIControlStateNormal];

}

- (void)SCChanged{
    madeChange = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleOK:(id)sender {
    okBtn.enabled = NO;
    MySingleton* singleton = [MySingleton getInstance];
    [MySingleton startLoading:self.view];
    
    int mySubject = (int)subjectSC.selectedSegmentIndex;
    if (mySubject == 0){
        chosenSubject = @"maths";
    }else if (mySubject == 1){
        chosenSubject = @"english";
    }else if (mySubject == 2){
        chosenSubject = @"chinese";
    }else if (mySubject == 3){
        chosenSubject = @"others";
    }
    
    int myDisType = (int)disTypeSC.selectedSegmentIndex;
    if (myDisType == 0){
        chosenDisType = @"normal";
    }else if (myDisType == 1){
        chosenDisType = @"exercise";
    }else if (myDisType == 2){
        chosenDisType = @"test";
    }else if (myDisType == 3){
        chosenDisType = @"competition";
    }
    
    int myDifficulty = (int)difficultySC.selectedSegmentIndex;
    if (myDifficulty == 0){
        chosenDifficulty = 1;
    }else if (myDifficulty == 1){
        chosenDifficulty = 2;
    }else if (myDifficulty == 2){
        chosenDifficulty = 3;
    }
    
    chosenDifficultyPresentation = (int)difficultyPresentationSC.selectedSegmentIndex;
    
    chosenHighlightAns = (int)highlightAnsSC.selectedSegmentIndex;

    chosenGiveGift= (int)giveGiftSC.selectedSegmentIndex;

    int myTimeLimit = (int)timeLimitSC.selectedSegmentIndex;
    
    if (myTimeLimit == 0){
        chosenTimeLimit = 0;
    }else if (myTimeLimit == 1){
        chosenTimeLimit = 10;
    }else if (myTimeLimit == 2){
        chosenTimeLimit = 30;
    }else if (myTimeLimit == 3){
        chosenTimeLimit = 60;
    }else if (myTimeLimit == 4){
        chosenTimeLimit = 300;
    }
    
    int myMaxTrial = (int)maxTrialSC.selectedSegmentIndex;
    
    if (myMaxTrial == 0){
        chosenMaxTrial = 0;
    }else if (myMaxTrial == 1){
        chosenMaxTrial = 1;
    }else if (myMaxTrial == 2){
        chosenMaxTrial = 3;
    }else if (myMaxTrial == 3){
        chosenMaxTrial = 5;
    }else if (myMaxTrial == 4){
        chosenMaxTrial = 10;
    }
    
    //ON Button
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //do function
        bool updateSuccess = [self updateNoteTag:singleton.globalOnSelectedNoteID andUserID:singleton.globalUserID andServer:singleton.globalUserServer];
        [MySingleton endLoading:self.view andSuccess:updateSuccess];
        
        if (updateSuccess){
            //[self dismissViewControllerAnimated:YES completion:nil];
            NSString* successShareMessage = NSLocalizedStringFromTableInBundle(@"successChangeTagMessage", nil, singleton.globalLocaleBundle, nil);
            statusLabel.text = successShareMessage;
            [topicTF resignFirstResponder];
            [topicTF endEditing:YES];
            [subTopicTF resignFirstResponder];
            [subTopicTF endEditing:YES];
            [keywordsTF resignFirstResponder];
            [keywordsTF endEditing:YES];
            [remarksTF resignFirstResponder];
            [remarksTF endEditing:YES];
            
            madeChange = false;
            
        }else{
            //[self alertStatus:@"Share Fail Content" :@"Share Fail Heading":0];
            NSString* failShareMessage = NSLocalizedStringFromTableInBundle(@"failChangeTagMessage", nil, singleton.globalLocaleBundle, nil);
            statusLabel.text = failShareMessage;
        }
        
        okBtn.enabled = YES;
        
    });
}

- (bool) updateNoteTag:(NSString *)NoteID andUserID:(NSString *)UserID andServer:(NSString *)Server{
    MySingleton* singleton = [MySingleton getInstance];
    bool boolSuccess = false;
    
    if([NoteID isEqualToString:@""] || [UserID isEqualToString:@""] || [Server isEqualToString:@""] ) {
        //
    } else {
        NSString * new1 = [[NSString alloc] initWithString:chosenDisType];
        NSString * new2 = [[NSString alloc] initWithString:chosenSubject];
        NSString * new3 = [[NSString alloc] initWithString:topicTF.text];
        NSString * new4 = [[NSString alloc] initWithString:subTopicTF.text];
        NSString * new5 = [[NSString alloc] initWithString:keywordsTF.text];
        NSString * new6 = [[NSString alloc] initWithString:remarksTF.text];
        NSString * new7 = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",chosenDifficulty]];
        NSString * new8 = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",chosenHighlightAns]];
        NSString * new9 = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",chosenGiveGift]];
        NSString * new10 = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",chosenTimeLimit]];
        NSString * new11 = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",chosenMaxTrial]];
        NSString * new12 = [[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",chosenDifficultyPresentation]];
        
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        [dataInput setObject:new1 forKey:@"Status"]; //
        [dataInput setObject:new2 forKey:@"Subject"]; //
        [dataInput setObject:new3 forKey:@"Topic"]; //
        [dataInput setObject:new4 forKey:@"SubTopic"]; //
        [dataInput setObject:new5 forKey:@"Keywords"]; //
        [dataInput setObject:new6 forKey:@"Remarks"]; //
        [dataInput setObject:new7 forKey:@"Difficulty"]; //
        [dataInput setObject:new8 forKey:@"HighlightAns"]; //
        [dataInput setObject:new9 forKey:@"GiveGift"]; //
        [dataInput setObject:new10 forKey:@"TimeLimit"]; //
        [dataInput setObject:new11 forKey:@"MaxTrial"]; //
        [dataInput setObject:new12 forKey:@"DifficultyPresentation"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"updateNoteStatus.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
        if ([success  isEqual: @"OK"]){
            singleton.globalReceivedNoteStatus = new1;
            singleton.globalReceivedNoteSubject = new2;
            singleton.globalReceivedNoteTopic = new3;
            singleton.globalReceivedNoteSubTopic = new4;
            singleton.globalReceivedNoteKeywords = new5;
            singleton.globalReceivedNoteRemarks = new6;
            singleton.globalReceivedNoteDifficulty = new7;
            singleton.globalReceivedNoteHighlightAns = new8;
            singleton.globalReceivedNoteGiveGift = new9;
            singleton.globalReceivedNoteTimeLimit = new10;
            singleton.globalReceivedNoteMaxTrial = new11;
            singleton.globalReceivedNoteDifficultyPresentation = new12;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteInputViewControllerDismissed"
                                                        object:self
                                                      userInfo:nil];
}

- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    madeChange = true;
    return true;
    /*
    int max_range = 10;
    
    //check is number input only
    NSString *fulltext = [textField.text stringByAppendingString:string];
    NSString *charactersSetString = @"0123456789";
    
    NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:charactersSetString];
    NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:fulltext];
    
    // If typed character is out of Set, ignore it.
    BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
    if(!stringIsValid) {
        return NO;
    }
    
    // Check the max characters typed.
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= max_range || returnKey;
    */
    
   
}

     
- (IBAction)handleNoteTypeChange:(id)sender {
    int typeChoosen = (int)disTypeSC.selectedSegmentIndex; //store Language
    if (typeChoosen == 0){
        chosenDisType = @"normal";
    }else if (typeChoosen == 1){
        chosenDisType = @"exercise";
    }else if (typeChoosen == 2){
        chosenDisType = @"test";
    }else if (typeChoosen == 3){
        chosenDisType = @"competition";
    }
    [self refreshSelection];
}

- (void) refreshSelection{
    if ([chosenDisType  isEqual: @"normal"]){
        highlightAnsSC.selectedSegmentIndex = 0;
        difficultySC.selectedSegmentIndex = 0;
        difficultyPresentationSC.selectedSegmentIndex = 0;
        if(difficultyPresentationSC.numberOfSegments >= 2 ){
            for (int i = 0;i<2; i++){
                [difficultyPresentationSC setEnabled:NO forSegmentAtIndex:i];
            }
        }
        giveGiftSC.selectedSegmentIndex = 0;
        timeLimitSC.selectedSegmentIndex = 0;
        maxTrialSC.selectedSegmentIndex = 0;
        [highlightAnsSC setEnabled:NO forSegmentAtIndex:0];
        [highlightAnsSC setEnabled:NO forSegmentAtIndex:1];
        if(difficultySC.numberOfSegments >= 3 ){
            for (int i = 0;i<3; i++){
                [difficultySC setEnabled:NO forSegmentAtIndex:i];
            }
        }
        [giveGiftSC setEnabled:NO forSegmentAtIndex:0];
        [giveGiftSC setEnabled:NO forSegmentAtIndex:1];
        [timeLimitSC setEnabled:NO forSegmentAtIndex:0];
        [maxTrialSC setEnabled:NO forSegmentAtIndex:0];
        if(timeLimitSC.numberOfSegments >= 5 && maxTrialSC.numberOfSegments >= 5){
            for (int i = 1;i<=4; i++){
                [timeLimitSC setEnabled:NO forSegmentAtIndex:i];
                [maxTrialSC setEnabled:NO forSegmentAtIndex:i];
            }
        }
    }else if ([chosenDisType  isEqual: @"exercise"]){
        highlightAnsSC.selectedSegmentIndex = 1;
        difficultySC.selectedSegmentIndex = 0;
        difficultyPresentationSC.selectedSegmentIndex = 0;
        if(difficultyPresentationSC.numberOfSegments >= 2 ){
            for (int i = 0;i<2; i++){
                [difficultyPresentationSC setEnabled:YES forSegmentAtIndex:i];
            }
        }
        giveGiftSC.selectedSegmentIndex = 1;
        timeLimitSC.selectedSegmentIndex = 0;
        maxTrialSC.selectedSegmentIndex = 0;
        [highlightAnsSC setEnabled:YES forSegmentAtIndex:0];
        [highlightAnsSC setEnabled:YES forSegmentAtIndex:1];
        if(difficultySC.numberOfSegments >= 3 ){
            for (int i = 0;i<3; i++){
                [difficultySC setEnabled:YES forSegmentAtIndex:i];
            }
        }
        [giveGiftSC setEnabled:YES forSegmentAtIndex:0];
        [giveGiftSC setEnabled:YES forSegmentAtIndex:1];
        [timeLimitSC setEnabled:YES forSegmentAtIndex:0];
        if(timeLimitSC.numberOfSegments >= 5){
            for (int i = 1;i<=4; i++){
                [timeLimitSC setEnabled:NO forSegmentAtIndex:i];
            }
        }
        if(maxTrialSC.numberOfSegments >= 5){
            for (int i = 0;i<=4; i++){
                [maxTrialSC setEnabled:YES forSegmentAtIndex:i];
            }
        }
    }else if ([chosenDisType  isEqual: @"test"]){
        highlightAnsSC.selectedSegmentIndex = 0;
        difficultySC.selectedSegmentIndex = 0;
        difficultyPresentationSC.selectedSegmentIndex = 0;
        if(difficultyPresentationSC.numberOfSegments >= 2 ){
            for (int i = 0;i<2; i++){
                [difficultyPresentationSC setEnabled:YES forSegmentAtIndex:i];
            }
        }
        giveGiftSC.selectedSegmentIndex = 1;
        timeLimitSC.selectedSegmentIndex = 0;
        maxTrialSC.selectedSegmentIndex = 1;
        [highlightAnsSC setEnabled:NO forSegmentAtIndex:0];
        [highlightAnsSC setEnabled:NO forSegmentAtIndex:1];
        if(difficultySC.numberOfSegments >= 3 ){
            for (int i = 0;i<3; i++){
                [difficultySC setEnabled:YES forSegmentAtIndex:i];
            }
        }
        [giveGiftSC setEnabled:YES forSegmentAtIndex:0];
        [giveGiftSC setEnabled:YES forSegmentAtIndex:1];
        [timeLimitSC setEnabled:YES forSegmentAtIndex:0];
        [maxTrialSC setEnabled:NO forSegmentAtIndex:0];
        [maxTrialSC setEnabled:YES forSegmentAtIndex:1];//*
        if(timeLimitSC.numberOfSegments >= 5){
            for (int i = 1;i<=4; i++){
                [timeLimitSC setEnabled:NO forSegmentAtIndex:i];
            }
        }
        if(maxTrialSC.numberOfSegments >= 5){
            for (int i = 2;i<=4; i++){
                [maxTrialSC setEnabled:NO forSegmentAtIndex:i];
            }
        }
    }else if ([chosenDisType  isEqual: @"competition"]){
        highlightAnsSC.selectedSegmentIndex = 0;
        difficultySC.selectedSegmentIndex = 0;
        difficultyPresentationSC.selectedSegmentIndex = 0;
        if(difficultyPresentationSC.numberOfSegments >= 2 ){
            for (int i = 0;i<2; i++){
                [difficultyPresentationSC setEnabled:YES forSegmentAtIndex:i];
            }
        }
        giveGiftSC.selectedSegmentIndex = 1;
        timeLimitSC.selectedSegmentIndex = 3;
        maxTrialSC.selectedSegmentIndex = 1;
        [highlightAnsSC setEnabled:NO forSegmentAtIndex:0];
        [highlightAnsSC setEnabled:NO forSegmentAtIndex:1];
        if(difficultySC.numberOfSegments >= 3 ){
            for (int i = 0;i<3; i++){
                [difficultySC setEnabled:YES forSegmentAtIndex:i];
            }
        }
        [giveGiftSC setEnabled:YES forSegmentAtIndex:0];
        [giveGiftSC setEnabled:YES forSegmentAtIndex:1];
        [timeLimitSC setEnabled:YES forSegmentAtIndex:0];
        [maxTrialSC setEnabled:NO forSegmentAtIndex:0];
        [maxTrialSC setEnabled:YES forSegmentAtIndex:1];//*
        if(timeLimitSC.numberOfSegments >= 5){
            for (int i = 1;i<=4; i++){
                [timeLimitSC setEnabled:YES forSegmentAtIndex:i];
            }
        }
        if(maxTrialSC.numberOfSegments >= 5){
            for (int i = 2;i<=4; i++){
                [maxTrialSC setEnabled:NO forSegmentAtIndex:i];
            }
        }
    }
}

- (IBAction)handlePickTopic:(id)sender {
    //
    UIButton * btn = (UIButton *) sender;
    PickerViewController *pwc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"UIPickerViewCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:pwc];
    poc.delegate=self;
    
    int mySubject = (int)subjectSC.selectedSegmentIndex;
    NSString * curSubject;
    if (mySubject == 0){
        curSubject = @"maths";
    }else if (mySubject == 1){
        curSubject = @"english";
    }else if (mySubject == 2){
        curSubject = @"chinese";
    }else if (mySubject == 3){
        curSubject = @"others";
    }
    
    if (poc != nil){
        [poc presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionDown animated:YES];
        [pwc pointTF:topicTF setSubject:curSubject setTopic:topicTF.text setSubTopic:subTopicTF.text setType:0];
    }
}

- (IBAction)handlePickSubTopic:(id)sender {
    //
    UIButton * btn = (UIButton *) sender;
    PickerViewController *pwc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"UIPickerViewCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:pwc];
    poc.delegate=self;
    
    int mySubject = (int)subjectSC.selectedSegmentIndex;
    NSString * curSubject;
    if (mySubject == 0){
        curSubject = @"maths";
    }else if (mySubject == 1){
        curSubject = @"english";
    }else if (mySubject == 2){
        curSubject = @"chinese";
    }else if (mySubject == 3){
        curSubject = @"others";
    }
    
    if (poc != nil){
        [poc presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionDown animated:YES];
        [pwc pointTF:subTopicTF setSubject:curSubject setTopic:topicTF.text setSubTopic:subTopicTF.text setType:1];
    }
    
}


@end
