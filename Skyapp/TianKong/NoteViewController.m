//
//  NoteViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 12/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "NoteViewController.h"
#import "MySingleton.h"
#import "ShareViewController.h"
#import "GalleryViewController.h"
#import "TextViewController.h"
#import "DragView.h"
#import "DrawView.h"
#import "DragLabel.h"
#import "DragTextField.h"
#import <QuartzCore/QuartzCore.h> //for dash line image
#import "DragControlBtn.h"
#import "TeacherDistributeViewController.h"
#import "NoteInfoInputController.h"
#import "IconInputController.h"
#import "IconsCell.h"
#import "StudentRecordController.h"
#import "CommentViewController.h"


@interface NoteViewController ()

@end

@implementation NoteViewController

@synthesize scrollView;
@synthesize containerView;

@synthesize poc;
@synthesize myDrawView;
@synthesize myDefineQuestionView;

@synthesize iconBtn;
@synthesize backBtn;
@synthesize shareBtn;
@synthesize saveBtn;
@synthesize addTextBtn;
@synthesize galleryBtn;
@synthesize drawBtn;
@synthesize browserBtn;
@synthesize cameraBtn;
@synthesize backgroundView;
@synthesize geometryBtn;
@synthesize answerBoxBtn;
@synthesize defineQuestionBtn;
@synthesize editTagBtn;

@synthesize distributeBtn;
@synthesize showAnsBtn;
@synthesize hideAnsBtn;
@synthesize readStudentRecordBtn;
@synthesize previewBtn;
@synthesize feelingCorrectBtn;
@synthesize feelingWrongBtn;
@synthesize feelingGoodBtn;
@synthesize feelingNoIdeaBtn;
@synthesize feelingNoTimeBtn;
@synthesize commentBtn;

@synthesize statusLabel;
@synthesize timeHeadLabel;
@synthesize timeLabel;

//for control resize
@synthesize myButtons;
@synthesize topLeftBtn;
@synthesize topRightBtn;
@synthesize bottomLeftBtn;
@synthesize bottomRightBtn;
@synthesize onSelectedObject;

//for save
@synthesize mySaveController;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //get singleton
    MySingleton* singleton = [MySingleton getInstance];
    
    NSLog(@"viewDidLoad note - type = %@", singleton.globalUserType);
    
    //touch containerView to cancel selections
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.containerView addGestureRecognizer:singleFingerTap];
    self.containerView.multipleTouchEnabled=NO;
    self.containerView.exclusiveTouch =YES;
    
    //localication
    NSString* backText = NSLocalizedStringFromTableInBundle(@"Back", nil, singleton.globalLocaleBundle, nil);
    self.backBtn.title = [NSString stringWithFormat:@"< %@ - %@", singleton.globalUserName, backText];
    self.shareBtn.title = NSLocalizedStringFromTableInBundle(@"ShareBtn", nil, singleton.globalLocaleBundle, nil);
    self.saveBtn.title = NSLocalizedStringFromTableInBundle(@"SaveBtn", nil, singleton.globalLocaleBundle, nil);
    self.distributeBtn.title = NSLocalizedStringFromTableInBundle(@"distributeBtnText", nil, singleton.globalLocaleBundle, nil);
    self.showAnsBtn.title = NSLocalizedStringFromTableInBundle(@"showAnsBtnText", nil, singleton.globalLocaleBundle, nil);
    self.hideAnsBtn.title = NSLocalizedStringFromTableInBundle(@"hideAnsBtnText", nil, singleton.globalLocaleBundle, nil);
    
    //refresh scrollView and containerView
    scrollView.contentSize=CGSizeMake(containerView.frame.size.width, containerView.frame.size.height+400);
    scrollView.showsVerticalScrollIndicator = YES;
    
    UIImage * plainGreyImage = [MySingleton imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(containerView.frame.size.width,500)];
    UIImageView *  imageCoverTop = [[UIImageView alloc] initWithImage:plainGreyImage];
    imageCoverTop.frame = CGRectMake(0,-500, containerView.frame.size.width, 500);
    [scrollView addSubview:imageCoverTop];
    UIImageView *  imageCoverBot = [[UIImageView alloc] initWithImage:plainGreyImage];
    imageCoverBot.frame = CGRectMake(0,containerView.frame.size.height, containerView.frame.size.width, 500);
    [scrollView addSubview:imageCoverBot];
    
    //for alert save before back
    needSave = false;
    
    //for save
    mySaveController = [[SaveController alloc]init];
    
    //load notecontent from DB
    loadNoteSuccess = [mySaveController loadNoteBy:singleton.globalOnSelectedNoteID andServer:singleton.globalUserServer isViewOnly:false];
    
    if (loadNoteSuccess){
        //check not only space
        [mySaveController decodeAllObjects:self.containerView isViewOnly:false];
        
        //add notifications observersedcode
        [self addNotificationsObservers];
        
        //NSLog
        [self showNumberOfObjects];
        
        //add control btns
        myButtons = [[NSMutableArray alloc] init];
        
        //full in
        topLeftBtn = [[DragControlBtn alloc] initWithFrame:CGRectMake(0, 0, R_LENGTH, R_LENGTH) withType:@"topLeftBtn"];
        topRightBtn = [[DragControlBtn alloc] initWithFrame:CGRectMake(0, 0, R_LENGTH, R_LENGTH) withType:@"topRightBtn"];
        bottomLeftBtn = [[DragControlBtn alloc] initWithFrame:CGRectMake(0, 0, R_LENGTH, R_LENGTH) withType:@"bottomLeftBtn"];
        bottomRightBtn = [[DragControlBtn alloc] initWithFrame:CGRectMake(0, 0, R_LENGTH, R_LENGTH) withType:@"bottomRightBtn"];
        
        [myButtons addObject:topLeftBtn];
        [myButtons addObject:topRightBtn];
        [myButtons addObject:bottomLeftBtn];
        [myButtons addObject:bottomRightBtn];
        
        for (DragControlBtn* btn in myButtons){
            [self.containerView addSubview:btn];
            btn.hidden=true;
        }
        
        //for suggested and default frame for Textfield
        if (CGRectIsEmpty(singleton.globalPreviousTFFrame)){
            //Just make sure the initialize width and height not exceeds max and min. then it will be fine.
            singleton.globalPreviousTFFrame = CGRectMake(0, 0, DEFAULT_TF_WIDTH,DEFAULT_TF_HEIGHT);
        }
        
        //for webview
        if (singleton.wvc == nil)
            singleton.wvc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"WebViewCtrler"];
        
        //load background image
        
        NSString * bgContent = [NSString stringWithFormat:@"%@",singleton.globalReceivedNoteBackgroundImageStr]; //* avoid null value
        if (bgContent != nil && ![bgContent  isEqual: @""] && ![bgContent  isEqual: @"<null>"]){
            //NSLog(@"tnContent = %@", tnContent);
            bgContent = [bgContent stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
            //NSData * bgBase64Data = [[NSData alloc] initWithBase64EncodedString:bgContent options:0];
            //backgroundImg = [[UIImage alloc] initWithData:bgBase64Data];
            backgroundImg=[MySingleton decodeBase64ToImage:bgContent];
            [self storeBGView:backgroundImg];
        }
        
        //
        [self refreshBackgroundViewByStatus];
        
        uiBtnArr = @[backBtn, iconBtn, addTextBtn, galleryBtn, cameraBtn, drawBtn, geometryBtn, answerBoxBtn, defineQuestionBtn, editTagBtn, distributeBtn, shareBtn, saveBtn, showAnsBtn, hideAnsBtn, readStudentRecordBtn, previewBtn, feelingCorrectBtn, feelingWrongBtn, feelingGoodBtn, feelingNoIdeaBtn, feelingNoTimeBtn,commentBtn, browserBtn];
        
        uiBtnName = @[@"back", @"use gift", @"text", @"gallery", @"camera", @"draw", @"geometry", @"answerbox", @"defineQuestionBtn",@"teacher's mode", @"distribute", @"share", @"save", @"show answer", @"hide answer", @"read student record", @"thumbnail", @"feeling correct btn", @"feeling incorrect btn", @"feeling happy btn", @"feeling sad btn", @"feeling times up btn",@"commentBtn", @"browser"];
        
    }else{
        NSLog(@"Loading note fail");
    }
}

- (void) hideUIBtn:(UIBarButtonItem *) btn{
    btn.title=@"";
    btn.image=nil;
    btn.enabled=false;
}

- (void) showUIBtn:(UIBarButtonItem *) btn{
    for (int i = 0; i < uiBtnArr.count; i++){
        if (btn == uiBtnArr[i]){
            btn.image = [UIImage imageNamed:uiBtnName[i]];
            btn.enabled=true;
            break;
        }
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!loadNoteSuccess){
        [self handleBack:nil];
    }
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    if (isPre){
        [self doWaitingAnsSetting];
    }else if (isPost){
        [self doSubmittedAnsSetting];
    }
    
    //refresh View interaction
    [self refreshViewInteraction];
    
    //refresh Status Label
    [self refreshStatusLabel];
    
    //hide buttons depend on note status and user status
    [self hideButtons];
    
    //buttons depend on user type
    [self enableAllButtons];
    
    NSLog(@"willappear - globalReceivedNoteQuestionLines = %@",singleton.globalReceivedNoteQuestionLines);
}

- (void) refreshStatusLabel{
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    bool simExercise = [singleton.globalReceivedNoteStatus rangeOfString:@"exercise"].location != NSNotFound;
    bool simTest = [singleton.globalReceivedNoteStatus rangeOfString:@"test"].location != NSNotFound;
    bool simCompetition = [singleton.globalReceivedNoteStatus rangeOfString:@"competition"].location != NSNotFound;
    
    NSLog(@"refreshStatusLabel");
    if (isPre && (simExercise || simTest || simCompetition)){
        //show trial
        int MaxTrial = [singleton.globalReceivedNoteMaxTrial intValue];
        int NoOfTrial = [singleton.globalReceivedNoteNoOfTrial intValue];
        if (MaxTrial == 0){
            statusLabel.text = @"";
        }else{
            int trialLeft = MaxTrial - NoOfTrial;
            NSString* trialLeftText = NSLocalizedStringFromTableInBundle(@"trialLeftText", nil, singleton.globalLocaleBundle, nil);
            statusLabel.text = [NSString stringWithFormat:@"%@ : %d", trialLeftText, trialLeft];
        }
        
        //show time limit
        if (![singleton.globalReceivedNoteTimeLimit  isEqual: @"0"]){
            NSString* timeHeadLabelText = NSLocalizedStringFromTableInBundle(@"timeHeadLabelText", nil, singleton.globalLocaleBundle, nil);
            timeHeadLabel.text = [NSString stringWithFormat:@"%@", timeHeadLabelText];
            int timeLeft = [singleton.globalReceivedNoteTimeLimit intValue] - timeO;
            timeLabel.text = [NSString stringWithFormat:@"%d",timeLeft];
        }else{
            timeHeadLabel.text = @"";
            timeLabel.text = @"";
        }
        
    }else if (isPost && (simExercise || simTest || simCompetition)){
        statusLabel.text = @"";
        // show marks
        if (fullMarks != 0){
            NSString* marksHeadLabelText = NSLocalizedStringFromTableInBundle(@"marksHeadLabelText", nil, singleton.globalLocaleBundle, nil);
            timeHeadLabel.text = [NSString stringWithFormat:@"%@", marksHeadLabelText];
            timeLabel.text = [NSString stringWithFormat:@"%d/%d",correctAnswer,fullMarks];
        }else{
            timeHeadLabel.text = @"";
            timeLabel.text = @"";
        }
    }else{
        statusLabel.text = @"";
        timeHeadLabel.text = @"";
        timeLabel.text = @"";
    }

}

- (void) refreshViewInteraction{
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    if (isPre || isPost){
        for (UIView *subview in self.containerView.subviews){
            if([subview isKindOfClass:[DragTextField class]]){
                DragTextField * dtf = (DragTextField *) subview;
                NSLog(@"answer = %@",[dtf getANSTEXT]);
                NSLog(@"answer status = %@",[dtf getANSSTATUS]);
            }else if([subview isKindOfClass:[DragView class]]){
                DragView * obj = (DragView *)subview;
                NSLog(@"DragView getLINK = %@",[obj getLINK]);
                bool isStudentInput = [[obj getANSSTATUS]  isEqual: @"studentInput"];
                bool isNoLink = [[obj getLINK]  isEqual: @"noCallLink"];
                if (isStudentInput){
                    subview.userInteractionEnabled=YES;
                }else{
                    if (isNoLink){
                        subview.userInteractionEnabled=NO;
                    }else{
                        subview.userInteractionEnabled=YES;
                    }
                }
            }else if([subview isKindOfClass:[DragLabel class]]){
                DragLabel * obj = (DragLabel *)subview;
                bool isStudentInput = [[obj getANSSTATUS]  isEqual: @"studentInput"];
                bool isBookmark = [obj getBOOKMARK];
                if (isStudentInput){
                    subview.userInteractionEnabled=YES;
                }else{
                    if (isBookmark){
                        subview.userInteractionEnabled=YES;
                    }else{
                        subview.userInteractionEnabled=NO;
                    }
                }
            }
        }
    }
}

- (void) hideButtons{
    
    MySingleton* singleton = [MySingleton getInstance];
    
    NSLog(@"hideButtons - NoteStatus = %@",singleton.globalReceivedNoteStatus);
    
    bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
    bool isStudent = [singleton.globalUserType isEqual: @"student"];
    bool isNormal = [singleton.globalReceivedNoteStatus isEqual: @"normal"];
    bool isExercise = [singleton.globalReceivedNoteStatus isEqual: @"exercise"];
    bool isTest = [singleton.globalReceivedNoteStatus isEqual: @"test"];
    bool isCompetition = [singleton.globalReceivedNoteStatus isEqual: @"competition"];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    
    //teacher button
    if (isTeacher && (isNormal || isExercise || isTest || isCompetition)){
        [self showUIBtn:answerBoxBtn];
        [self showUIBtn:defineQuestionBtn];
        [self showUIBtn:editTagBtn];
        [self showUIBtn:distributeBtn];
        [self showUIBtn:showAnsBtn];
        [self showUIBtn:hideAnsBtn];
        [self showUIBtn:readStudentRecordBtn];
        [self showUIBtn:previewBtn];
    }else{
        [self hideUIBtn:answerBoxBtn];
        [self hideUIBtn:defineQuestionBtn];
        [self hideUIBtn:editTagBtn];
        [self hideUIBtn:distributeBtn];
        [self hideUIBtn:showAnsBtn];
        [self hideUIBtn:hideAnsBtn];
        [self hideUIBtn:readStudentRecordBtn];
        [self hideUIBtn:previewBtn];
    }
    
    //student button
    if (isStudent && (isPre || isPost)){
        [self showUIBtn:feelingCorrectBtn];
        [self showUIBtn:feelingWrongBtn];
        [self showUIBtn:feelingGoodBtn];
        [self showUIBtn:feelingNoIdeaBtn];
        [self showUIBtn:feelingNoTimeBtn];
        [self showUIBtn:commentBtn];
        
    }else{
        [self hideUIBtn:feelingCorrectBtn];
        [self hideUIBtn:feelingWrongBtn];
        [self hideUIBtn:feelingGoodBtn];
        [self hideUIBtn:feelingNoIdeaBtn];
        [self hideUIBtn:feelingNoTimeBtn];
        [self hideUIBtn:commentBtn];
    }
    
    //change share and save buttons
    [self refreshSaveAndShareBtns:isStudent withPre:isPre];
    
    //17+ shows browser button
    if (APP_TYPE == 0){
        [self showUIBtn:browserBtn];
    }else{
        [self hideUIBtn:browserBtn];
    }
}

- (void) doWaitingAnsSetting{
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    
    //hide and disable button
    NSLog(@"doWaitingAnsSetting");
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * dtf = (DragTextField *) subview;
            [dtf handleWaitAns];
        }
    }
    //change save button to submit button
    if (isPre){
        self.saveBtn.title = NSLocalizedStringFromTableInBundle(@"submitButtonText", nil, singleton.globalLocaleBundle, nil);
        //set timer
        timeO = 0;
        timeHAB = 0;
        [self startTimer:@"timerWhenOpen"];
    }
    
    //LogCon
    singleton.logCon = [[LogController alloc] init];
}

- (void) doSubmittedAnsSetting{
    //hide and disable button
    NSLog(@"doSubmittedAnsSetting");
    
    //highlight wrong ans
    [self highlightWrongAnswers];
    
    //show marks
    correctAnswer = 0;
    fullMarks = 0;
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *) subview;
            fullMarks++;
            if ([obj.text  isEqual: [obj getANSTEXT]]){
                correctAnswer++;
            }
        }
    }
}

-(void)startTimer:(NSString *)myTimerName{
    if ([myTimerName  isEqual: @"timerWhenOpen"] && timerWhenOpen == nil){
        timerWhenOpen = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addTimeForOpen) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerWhenOpen forMode:UITrackingRunLoopMode];
    }else if ([myTimerName  isEqual: @"timerWhenHitAnsBox"] && timerWhenHitAnsBox == nil){
        timerWhenHitAnsBox = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(addTimeForHitAnsBox) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timerWhenHitAnsBox forMode:UITrackingRunLoopMode];
    }
}

-(void)endTimer:(NSString *)myTimerName{
    if ([myTimerName  isEqual: @"timerWhenOpen"]){
        [timerWhenOpen invalidate];
        timerWhenOpen = nil;
        
    }else if ([myTimerName  isEqual: @"timerWhenHitAnsBox"]){
        [timerWhenHitAnsBox invalidate];
        timerWhenHitAnsBox = nil;
    }
}

-(void)addTimeForOpen{
    timeO++;
    
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool simCompetition = [singleton.globalReceivedNoteStatus rangeOfString:@"competition"].location != NSNotFound;
    if (isPre){
        if (simCompetition && ![singleton.globalReceivedNoteTimeLimit  isEqual: @"0"]){
            int timeLeft = [singleton.globalReceivedNoteTimeLimit intValue] - timeO;
            if (timeLeft >= 0)
                timeLabel.text = [NSString stringWithFormat:@"%d",timeLeft];
            if (timeLeft == 0)
                [self handleSave:saveBtn];
        }
    }
}

-(void)addTimeForHitAnsBox{
    timeHAB++;
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"keyboardWasShown");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"keyboardOnNoteView" andEventAction:@"show" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"keyboardOnNoteView" andEventAction:@"hide" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

-(void)callStartTimerForHitAnsBox:(NSNotification *) notification{
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    if (isPre){
        [self startTimer:@"timerWhenHitAnsBox"];
    }
}

- (void) addNotificationsObservers{
    //notification called when share view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissController)
                                                 name:@"ViewControllerDismissed"
                                               object:nil];
    
    //notification called when share view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissNoteInputViewController)
                                                 name:@"NoteInputViewControllerDismissed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissTeacherDistributeViewController)
                                                 name:@"TeacherViewControllerDismissed"
                                               object:nil];
    //notification called when gallery view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissGalleryViewController:)
                                                 name:@"GalleryViewControllerDismissed"
                                               object:nil];
    
    //notification called when draw view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissDrawView)
                                                 name:@"DrawViewDismissed"
                                               object:nil];
    //notification called when draw view dismiss with no stroke
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissDrawViewWithNoStroke)
                                                 name:@"DrawViewDismissedWithNoStroke"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDefineQuestionViewDismissed)
                                                 name:@"DefineQuestionViewDismissed"
                                               object:nil];
    
    
    //notification called when gallery view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissTextViewController:)
                                                 name:@"TextViewControllerDismissed"
                                               object:nil];
    
    //notification called when obj touch or pan
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(AppearControlBtn:)
                                                 name:@"noticeOnSelectedFromObj"    //ReadyForResize
                                               object:nil];
    
    //notification called when obj delete
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didNoticeRemove:)
                                                 name:@"ViewRemoved"
                                               object:nil];
    
    //notification called when obj touch or pan
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RefreshControlBtns:)
                                                 name:@"noticeDraggingFromObj" //RefreshControlBtnPosition
                                               object:nil];
    
    //notification to finish any movement
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelAllViewSelections)
                                                 name:@"cancelAllViewSelections" //NotTouched
                                               object:nil];
    
    //notification for control btns
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noticeDraggingFromBtn:)
                                                 name:@"noticeDraggingFromBtn"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(noticeEndDragFromBtn:)
                                                 name:@"noticeEndDragFromBtn"
                                               object:nil];
    
    //notification from DragLabel to call textviewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callEditTextViewController:)
                                                 name:@"callEditTextViewController"
                                               object:nil];
    
    //notification from WebView to create label
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewCreateText:)
                                                 name:@"webViewCreateText"
                                               object:nil];
    
    //notification from WebView to create image
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewCreateImage:)
                                                 name:@"webViewCreateImage"
                                               object:nil];
    
    //notification from WebView to create bgimage
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewCreateBGImage:)
                                                 name:@"webViewCreateBGImage"
                                               object:nil];
    
    //notification from WebView to create bookmark
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(webViewCreateBookmark:)
                                                 name:@"webViewCreateBookmark"
                                               object:nil];
    
    //notification from obj to call webviewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callWebViewController:)
                                                 name:@"callWebViewController"
                                               object:nil];
    
    //notification from obj to call webviewcontroller
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callWebViewReport:)
                                                 name:@"callWebViewReport"
                                               object:nil];
    
    //notification from ans box to call start timer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callStartTimerForHitAnsBox:)
                                                 name:@"callStartTimerForHitAnsBox"
                                               object:nil];
    
    //scroll when keyboard shown if needed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    //ans note call when label or view becomes ans, allowing distribute
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshNoteButtons:)
                                                 name:@"refreshNoteButtons"
                                               object:nil];
    
    //icon input view selected a icon
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iconInputCreateIcon:)
                                                 name:@"iconInputCreateIcon"
                                               object:nil];
    /*
    //notification called when analyze view button
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleStudentRecordController)
                                                 name:@"openStudentRecord"
                                               object:nil];
    
    //notification called when analyze view button
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleThumbailController)
                                                 name:@"openThumbnailRecord"
                                               object:nil];
    */
    
    //Observe Application Log
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgrounding) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)backgrounding{
    NSLog(@"toBackground");
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"appObserver" andEventAction:@"toBackground" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void)becomeActive{
    NSLog(@"beActive");
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"appObserver" andEventAction:@"beActive" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleIcon:(id)sender {
    IconInputController *iic = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"IconInputCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:iic];
    poc.delegate=self;
    
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"emojiViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];

}

-(void)iconInputCreateIcon :(NSNotification *) notification {
    MySingleton* singleton = [MySingleton getInstance];
    UIButton * obj = nil;
    int iconType = -1;
    int iconNo = -1;
    if ([[notification userInfo] isKindOfClass:[UIButton class]]){
        NSLog(@"iconInputCreateIcon - yes");
        obj = (UIButton *)[notification userInfo];
        iconType = (int)obj.tag/10000;
        iconNo = (int)obj.tag%10000;
        
        UIImage *image = nil;

        if (iconType == 0)
            image = [UIImage imageNamed:singleton.ICON_COLLECT[iconNo][0]];
        
        if (image != nil){

            if (iconType == 0)
                //log has been done inside
                [self createDragView:image andLink:@"noCallLink" andTitle:@"noCallTitle" andIconStatus:singleton.ICON_COLLECT[iconNo][1] andIsIcon:true];
        }
        [self.poc dismissPopoverAnimated:YES];
    }
}

- (IBAction)handleBack:(id)sender {
    MySingleton* singleton = [MySingleton getInstance];
    if (needSave){
        NSString* confirmToLeaveNoteText = NSLocalizedStringFromTableInBundle(@"confirmToLeaveNoteText", nil, singleton.globalLocaleBundle, nil);
        NSString* yesText = NSLocalizedStringFromTableInBundle(@"yes", nil, singleton.globalLocaleBundle, nil);
        NSString* noText = NSLocalizedStringFromTableInBundle(@"no", nil, singleton.globalLocaleBundle, nil);
        UIAlertView *alertConfirmViewLeaveNote = [[UIAlertView alloc] initWithTitle:confirmToLeaveNoteText message:nil delegate:self cancelButtonTitle:noText otherButtonTitles:yesText, nil];
        [alertConfirmViewLeaveNote show];
    }else{
        //directly go back
        [self leaveNote];
    }
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"backButton" andEventAction:@"click" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleShare:(id)sender {
    [self cancelAllViewSelections];
    MySingleton* singleton = [MySingleton getInstance];
    
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isStudent = [singleton.globalUserType isEqualToString:@"student"];
    
    if (isStudent & isPre){
        //save
        [self handleSave:sender]; //simple save
    }else{
        //share
        [self handleSave:nil]; //will disable
        
        NSLog(@"Share with noteID = %@", singleton.globalOnSelectedNoteID);
        ShareViewController *svc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"ShareViewCtrler"];
        poc = [[UIPopoverController alloc] initWithContentViewController:svc];
        poc.delegate=self;
        if (poc != nil){
            [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        }
        
        //log
        NSArray * key = @[];
        NSArray * data = @[];
        //log
        NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
        [singleton.logCon setEventType:@"shareViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    }
    
}

- (IBAction)handleSave:(id)sender {
    //saveBtn.enabled=false;
    UIBarButtonItem * btnClicked = nil;
    if (sender != nil){
        btnClicked = (UIBarButtonItem *)sender;
    }
    
    //disableAllButtons
    if (btnClicked == saveBtn || shareBtn){
        [self disableAllButtons];
    }
    
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isStudent = [singleton.globalUserType isEqualToString:@"student"];
    bool simExercise = [singleton.globalReceivedNoteStatus rangeOfString:@"exercise"].location != NSNotFound;
    bool simTest = [singleton.globalReceivedNoteStatus rangeOfString:@"test"].location != NSNotFound;
    bool simCompetition = [singleton.globalReceivedNoteStatus rangeOfString:@"competition"].location != NSNotFound;
    bool isFromShareBtn = false;
    if (sender == shareBtn)
        isFromShareBtn = true;
    
    //change all showingCorrectAns back to waitAns
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *) subview;
            if ([[obj getANSSTATUS]  isEqual: @"showCorrectAns"]){
                [obj handleWaitAns];
            }
        }
    }
    
    //save students input answer into title
    if (isPre && isStudent){
        for (UIView *subview in self.containerView.subviews){
            if([subview isKindOfClass:[DragTextField class]]){
                DragTextField * obj = (DragTextField *) subview;
                if ([[obj getANSSTATUS]  isEqual: @"waitAns"]){
                    [obj setTITLE:obj.text];
                    NSLog(@"title = %@, obj.text = %@",[obj getTITLE],obj.text);
                }
            }
        }
    }
    
    //clean
    [self cancelAllViewSelections];
    
    //------------UIImage to NSData to NSString(thumbnail)-----------
    UIGraphicsBeginImageContextWithOptions(containerView.bounds.size, containerView.opaque, 0.0);
    [containerView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //Resize
    UIImage * resizeIMG = [self scaleImage:img toResolution:296]; //change to this height
    
    NSString * imageStr = [MySingleton encodeToBase64String:resizeIMG];
    //this is needed since '+' cannot be transferred by POST
    imageStr = [imageStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSString * bgImageStr = [MySingleton encodeToBase64String:backgroundImg];
    //this is needed since '+' cannot be transferred by POST
    bgImageStr = [bgImageStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    //store BGIMAGE in singleton
    singleton.globalReceivedNoteBackgroundImageStr = [NSString stringWithFormat:@"%@",bgImageStr];
    
    [mySaveController encodeAllObjects:containerView];

    //count feedback icons
    int countCorrect = 0;
    int countIncorrect= 0;
    int countHappy = 0;
    int countNoIdea = 0;
    int countTimesup = 0;
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragView class]]){
            DragView * obj = (DragView *) subview;
            if ([obj getIsIcon]){
                if ([[obj getIconStatus]  isEqual:@"correct" ]){
                    countCorrect++;
                }else if ([[obj getIconStatus]  isEqual:@"incorrect" ]){
                    countIncorrect++;
                }else if ([[obj getIconStatus]  isEqual:@"happy" ]){
                    countHappy++;
                }else if ([[obj getIconStatus]  isEqual:@"noidea" ]){
                    countNoIdea++;
                }else if ([[obj getIconStatus]  isEqual:@"timesup" ]){
                    countTimesup++;
                }
            }
        }
    }
    NSLog (@"countCorrect = %d , countIncorrect = %d, countHappy = %d , countNoIdea = %d , countTimesup = %d", countCorrect, countIncorrect, countHappy, countNoIdea, countTimesup);
    
    //check if all answer boxes have answer
    bool allHaveAnswer = true;
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *) subview;
            if ([obj.text  isEqual: @""]){
                allHaveAnswer = false;
            }
        }
    }
    
    //check if all answer are corrects in answer box
    bool checkIfAllAnswerCorrect = true;
    correctAnswer = 0;
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *) subview;
            if ([obj.text  isEqual: [obj getANSTEXT]]){
                correctAnswer++;
            }else{
                checkIfAllAnswerCorrect = false;
            }
        }
    }
    
    NSLog(@"Correct Answers # = %d",correctAnswer);
    NSLog(@"checkIfAllAnswerCorrect = %d",checkIfAllAnswerCorrect);
    
    //show loading screen
    CGPoint offsetPT = [scrollView contentOffset];
    int offsetPTY = offsetPT.y;
    [MySingleton startLoadingForScrollView:self.scrollView withOffSetY:offsetPTY];
    
    //last log either save/submit button
    if (!isPre || isFromShareBtn){
        //is save
        NSArray * key = @[];
        NSArray * data = @[];
        NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
        [singleton.logCon setEventType:@"saveObserver" andEventAction:@"save" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    }else if (isPre && isStudent){
        //is submit
        NSArray * key = @[];
        NSArray * data = @[];
        NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
        [singleton.logCon setEventType:@"submitObserver" andEventAction:@"submit" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    }

    
    //LogCon - add new log
    NSDate *saveOrSubmitTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *submitTimeStr = [dateFormatter stringFromDate:saveOrSubmitTime];
    
    [singleton.logCon initActivity:singleton.globalReceivedNoteStatus andSubmitTime:submitTimeStr andLocation:singleton.globalLocInfo];
    NSString * eventLog = [NSString stringWithFormat:@"%@",[singleton.logCon transformToJsonFromat]];
    
    if (!isPre || isFromShareBtn){
        //--------------------------------------------------simply save-------------------------------------------
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            bool success = false;
            if(false) {
                //
            } else {
                //input
                NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalOnSelectedNoteID] forKey:@"NoteID"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteStr] forKey:@"NoteContent"]; //
                [dataInput setObject:[[NSString alloc] initWithString:imageStr] forKey:@"Thumbnail"]; //
                if (bgImageStr != nil){
                    [dataInput setObject:[[NSString alloc] initWithString:bgImageStr] forKey:@"BackgroundImage"]; //
                }
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalLocInfo] forKey:@"Location"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalAnswerID] forKey:@"AnswerID"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countCorrect]] forKey:@"CountCorrect"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countIncorrect]] forKey:@"CountIncorrect"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countHappy]] forKey:@"CountHappy"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countNoIdea]] forKey:@"CountNoIdea"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countTimesup]] forKey:@"CountTimesup"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",correctAnswer]] forKey:@"Marks"]; //
                
                [dataInput setObject:[[NSString alloc] initWithString:eventLog] forKey:@"EventLog"]; //
                
                //connect server
                NSMutableDictionary *jsonData;
                jsonData = [MySingleton jsonPostMultipleNSStringTo:singleton.globalUserServer andSubLink:@"saveNote.php" andDataInput:dataInput];
                
                //get result
                NSString * successSTR = [jsonData objectForKey:@"success"];
                //NSString * AnswerID = [jsonData objectForKey:@"AnswerID"];
                //NSLog(@"AnswerID = %@",AnswerID);
                
                //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
                if ([successSTR  isEqual: @"OK"]){
                    needSave = false;
                    success = true;
                    
                    //update LogCon
                    [singleton.logCon updateAfterSuccessSaveOrSubmit:eventLog];
                    
                }else if ([successSTR  isEqual: @"ERROR"]){
                    NSString * error_msg = [jsonData objectForKey:@"error_msg"];
                    NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
                    [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
                    NSLog(@"system_error_msg = %@",system_error_msg);
                }
            }
            [MySingleton endLoadingForScrollView:self.scrollView andSuccess:success withOffSetY:offsetPTY];
            
            if (btnClicked == saveBtn || shareBtn){
                double delayInSeconds = 2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self enableAllButtons];
                });
            }
            
            
        });
    }else if (isPre && isStudent){
        //--------------------------------------------------submit steps-------------------------------------------
        //turn off timer and reset timer
        NSLog (@"time 1 = %d, timer 2= %d",timeO,timeHAB);
        [self endTimer:@"timerWhenOpen"];
        [self endTimer:@"timerWhenHitAnsBox"];
        
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //---------------------------------------------------------------------------------------
            if(false) {
                //warning
            } else {
                //input
                NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalUserID] forKey:@"UserID"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalOnSelectedNoteID] forKey:@"NoteID"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalQuestionID] forKey:@"QuestionID"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalAnswerID] forKey:@"AnswerID"]; //

                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",correctAnswer]] forKey:@"Marks"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",timeO]] forKey:@"TimeTakenOpen"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",timeHAB]] forKey:@"TimeTakenTouchFirstAns"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalLocInfo] forKey:@"Location"]; //
                
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",allHaveAnswer]] forKey:@"allHaveAnswer"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",checkIfAllAnswerCorrect]] forKey:@"checkIfAllAnswerCorrect"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countCorrect]] forKey:@"CountCorrect"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countIncorrect]] forKey:@"CountIncorrect"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countHappy]] forKey:@"CountHappy"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countNoIdea]] forKey:@"CountNoIdea"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countTimesup]] forKey:@"CountTimesup"]; //
                
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteStatus] forKey:@"NoteStatus"]; //
                
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteHighlightAns] forKey:@"HighlightAns"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteGiveGift] forKey:@"GiveGift"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteTimeLimit] forKey:@"TimeLimit"]; //
                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteMaxTrial] forKey:@"MaxTrial"]; //
                
                [dataInput setObject:[[NSString alloc] initWithString:eventLog] forKey:@"EventLog"]; //

                [dataInput setObject:[[NSString alloc] initWithString:singleton.globalReceivedNoteStr] forKey:@"NoteContent"]; //
                [dataInput setObject:[[NSString alloc] initWithString:imageStr] forKey:@"Thumbnail"]; //
                
                
                //connect server
                NSMutableDictionary *jsonData;
                
                // ---------------- wrong coded in v1.25, requires update in v1.26 (start)----------------
                //jsonData = [MySingleton jsonPostMultipleNSStringTo:SERVER_ADDRESS andSubLink:@"submitAndUpdateAnswer.php" andDataInput:dataInput]; //old
                jsonData = [MySingleton jsonPostMultipleNSStringTo:singleton.globalUserServer andSubLink:@"submitAndUpdateAnswer.php" andDataInput:dataInput]; //1.26
                // ---------------- wrong coded in v1.25, requires update in v1.26 (end)----------------
                
                //get result
                NSString * successStr = [jsonData objectForKey:@"success"];
                //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
                if ([successStr  isEqual: @"OK"]){
                    [MySingleton endLoadingForScrollView:self.scrollView andSuccess:true withOffSetY:offsetPTY];
                    
                    NSString * NewNoteStatus = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"NewNoteStatus"]]; //*
                    //NSString * alertType = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"alertType"]]; //*
                    NSString * alertHead = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"alertHead"]]; //*
                    NSString * alertMsg = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"alertMsg"]]; //*
                    NSString * GiftNo = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"GiftNo"]]; //*
                    NSString * countSubmit = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"countSubmit"]]; //*
                    NSString * NoOfAnsBox = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"NoOfAnsBox"]]; //*
                    
                    NSLog(@"NoOfAnsBox = %@",NoOfAnsBox);
                    needSave = false;
                    
                    if (![NewNoteStatus  isEqual: @"<null>"]){
                        singleton.globalReceivedNoteStatus = NewNoteStatus;
                    }
                    
                    bool isNewPre  = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
                    bool isNewPost  = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
                    
                    //check need to indicate wrong answer
                    if ([singleton.globalReceivedNoteHighlightAns  isEqual: @"1"] || (isStudent && isNewPost && (simExercise || simTest || simCompetition))){
                        [self highlightWrongAnswers];
                    }
                    
                    //give random gift
                    if (![GiftNo  isEqual: @"<null>"]){
                        //exists gift
                        NSString * imageNormalLoc = singleton.ICON_COLLECT[[GiftNo intValue]-1][0];
                        UIImage *giftImage = [UIImage imageNamed:imageNormalLoc];
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, giftImage.size.width, giftImage.size.height)];
                        imageView.contentMode=UIViewContentModeCenter;
                        [imageView setImage:giftImage];
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertHead
                                                                            message:alertMsg
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles: nil];
                        //check if os version is 7 or above
                        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
                            [alertView setValue:imageView forKey:@"accessoryView"];
                        }else{
                            [alertView addSubview:imageView];
                        }
                        [alertView show];
                    }else{
                        [MySingleton alertStatus:alertMsg :alertHead :0];
                    }
                    
                    //update LogCon
                    [singleton.logCon updateAfterSuccessSaveOrSubmit:eventLog];
                    
                    //start timer again if it is still Pre
                    if (isStudent && isNewPre){
                        NSLog(@"Reset Timers");
                        //clean timer
                        timeO = 0;
                        timeHAB = 0;
                        [self startTimer:@"timerWhenOpen"];
                        
                        [self refreshBackgroundViewByStatus];
                    }else if (isStudent && isNewPost){
                        //isPost
                        [self doSubmittedAnsSetting];
                    }
                    
                    //update share and save buttons
                    [self refreshSaveAndShareBtns:isStudent withPre:isNewPre];
                    
                    //update StatusLabel
                    singleton.globalReceivedNoteNoOfTrial = countSubmit;
                    [self refreshStatusLabel];
                    
                }else if ([successStr  isEqual: @"ERROR"]){
                    [MySingleton endLoadingForScrollView:self.scrollView andSuccess:false withOffSetY:offsetPTY];
                    
                    NSString * error_msg = [jsonData objectForKey:@"error_msg"];
                    NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
                    NSString * CheckGiftNo = [jsonData objectForKey:@"CheckGiftNo"];
                   
                    [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
                    NSLog(@"system_error_msg = %@",system_error_msg);
                    NSLog(@"CheckGiftNo = %@",CheckGiftNo);
                }
                
            }
            
            if (btnClicked == saveBtn || shareBtn){
                double delayInSeconds = 2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self enableAllButtons];
                });
            }
        });
    }
}

- (void) refreshSaveAndShareBtns:(bool)isStudent withPre:(bool)isPre{
    if(isStudent & isPre){
        //on 1) save and on 2) submit
        //change submit button if comes to Post
        saveBtn.image = [UIImage imageNamed:@"submit"];
        [saveBtn setTintColor:[UIColor redColor]];
        shareBtn.image = [UIImage imageNamed:@"save"];
    }else{
        //off 2) share and on 2) save
        saveBtn.image = [UIImage imageNamed:@"save"];
        [saveBtn setTintColor:nil];
        shareBtn.image = [UIImage imageNamed:@"share"];
    }
}

- (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution {
    
    CGImageRef imgRef = [image CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //if already at the minimum resolution, return the orginal image, otherwise scale
    if (width <= resolution && height <= resolution) {
        return image;
        
    } else {
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            bounds.size.width = resolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = resolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}


- (IBAction)handleAddText:(id)sender {
    NSLog(@"Handle Text");
    [self cancelAllViewSelections];
    
    //MySingleton* singleton = [MySingleton getInstance];
    TextViewController *tvc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"TextViewCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:tvc];
    poc.delegate=self;
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"textViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleCamera:(id)sender {
    NSLog(@"Handle Camera");
    [self cancelAllViewSelections];
    
    //MySingleton* singleton = [MySingleton getInstance];
    GalleryViewController *gvc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"GalleryViewCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:gvc];
    poc.delegate=self;
    
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [gvc setTypeToCamera];
    }

    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"cameraViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleGallery:(id)sender {
    NSLog(@"Handle Gallery");
    [self cancelAllViewSelections];

    GalleryViewController *gvc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"GalleryViewCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:gvc];
    poc.delegate=self;
    
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [gvc setTypeToGallery];
    }
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"galleryViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleDraw:(id)sender {
    [self cancelAllViewSelections];
    
    self.scrollView.scrollEnabled=NO;
    [self disableAllButtons];
    
    CGPoint offsetPT = [scrollView contentOffset];
    int newH = offsetPT.y;
    [scrollView setContentOffset:CGPointMake(0, newH) animated:YES];
    
    CGRect frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    myDrawView = [[DrawView alloc] initWithFrame:frame offsetH:newH];
    [self.containerView addSubview:myDrawView];
    myDrawView.center = CGPointMake(CGRectGetMidX(self.containerView.bounds), CGRectGetMidY(self.containerView.bounds));
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"offsetHeight"];
    NSArray * data = @[[NSString stringWithFormat:@"%d",newH]];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"drawViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleGeometry:(id)sender {
    NSLog(@"open Geometry");
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"geomertyViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleBrowser:(id)sender {
    NSLog(@"open browser");
    MySingleton* singleton = [MySingleton getInstance];
    //Teacher version only
    if (APP_TYPE == 0){
        poc = [[UIPopoverController alloc] initWithContentViewController:singleton.wvc];
        poc.delegate=self;
        
        if (poc != nil){
            [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"openBrowser" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleAnswerBox:(id)sender {
    [self cancelAllViewSelections];
    CGPoint offsetPT = [scrollView contentOffset];
    int newH = offsetPT.y;
    MySingleton* singleton = [MySingleton getInstance];
    DragTextField * dtf = [[DragTextField alloc] initWithFrame:singleton.globalPreviousTFFrame inputStr:@"" andLink:@"noCallLink" andTitle:@"" offsetH:newH];
    [self.containerView addSubview:dtf];
    
    //refresh buttons
    [self enableAllButtons];
    
    //for back button to alert save before leave
    needSave = true;
}

- (IBAction)handleDefineQuestion:(id)sender {
    
    [self cancelAllViewSelections];
    
    [self disableAllButtons];
    
    //CGPoint offsetPT = [scrollView contentOffset];
    int newH = 40+TOOLBAR_HEIGHT;
    //[scrollView setContentOffset:CGPointMake(0, newH) animated:YES];
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, TOOLBAR_HEIGHT);
    
    myDefineQuestionView = [[DefineQuestionView alloc] initWithFrame:frame offsetH:newH setContainerView:containerView setScrollView:scrollView];
    [self.view addSubview:myDefineQuestionView];
    myDefineQuestionView.center = CGPointMake(CGRectGetMidX(self.view.bounds), newH);
    
    //log
    /*
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"offsetHeight"];
    NSArray * data = @[[NSString stringWithFormat:@"%d",newH]];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"drawViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    */
    
}

- (void) openBrowserByLink: (NSString *) myLink{
    MySingleton* singleton = [MySingleton getInstance];
    poc = [[UIPopoverController alloc] initWithContentViewController:singleton.wvc];
    poc.delegate=self;
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:browserBtn permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        [singleton.wvc loadRequestFromNewURL:myLink];
    }
    
    //log
    NSArray * key = @[@"link"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",myLink]];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"openBrowserByLink" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

//touch containerView to close menu and cancel all selected objects
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    
    //check if it hits no objects
    bool hitNoObjects = true;
    for (UIView *subview in self.containerView.subviews){
        //only check if it is clicking non selecting object
        if (CGRectContainsPoint(subview.frame, location) && ![subview isHidden] && [subview isUserInteractionEnabled]){
            hitNoObjects = false;
        }
    }
    
    //if yes, cancel all view selections
    if (hitNoObjects){
        NSLog(@"hitNoObjects, cancel all view selections");
        [self cancelAllViewSelections];
    }else{
        NSLog(@"hit some object");
    }

    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"hitObject"];
    NSArray * data = @[[NSString stringWithFormat:@"%d",!hitNoObjects]];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"generalView" andEventAction:@"singleTap" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void) cancelAllViewSelections{
    NSLog(@"cancelAllViewSelections");
    
    onSelectedObject = nil;
    
    //hide control btns
    [self DismissControlBtn];
    
    for (UIView *subview in self.containerView.subviews){
        //Drag Label
        if([subview isKindOfClass:[DragLabel class]]){
            //NSLog(@"DragLabel at (%f,%f)",subview.frame.origin.x,subview.frame.origin.y);
            DragLabel * obj = (DragLabel *) subview;
            [obj restoreOriginal];
            [obj refreshBorder];
        } else if([subview isKindOfClass:[DragView class]]){
            //NSLog(@"DragView at (%f,%f)",subview.frame.origin.x,subview.frame.origin.y);
            DragView * obj = (DragView *) subview;
            [obj restoreOriginal];
            [obj refreshBorder];
        } else if([subview isKindOfClass:[DragTextField class]]){
            //NSLog(@"DragTextField at (%f,%f)",subview.frame.origin.x,subview.frame.origin.y);
            DragTextField * obj = (DragTextField *) subview;
            [obj toLayerTop];
            if ([[obj getSTATUS]  isEqual: @"typing"] || [[obj getANSSTATUS]  isEqual: @"waitAns"]){
                [obj endEditing:YES];
                [obj resignFirstResponder];
            }
            [obj restoreOriginal];
            [obj refreshBorder];
        }
    }
    
    //refresh
    [self refreshBackgroundViewByStatus];
    scrollView.scrollEnabled=YES;
}

//testing
-(void) removeAllObjects{
    for (UIView *subview in self.containerView.subviews){
        [subview removeFromSuperview];
    }
}

//testing
-(void) showNumberOfObjects{
    int countLabel = 0;
    int countImageView = 0;
    int countTF = 0;
    
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[UITextField class]]){
            countTF++;
            NSLog(@"TF at (%f,%f)",subview.frame.origin.x,subview.frame.origin.y);
        }
        if([subview isKindOfClass:[UILabel class]]){
            countLabel++;
            NSLog(@"Label at (%f,%f)",subview.frame.origin.x,subview.frame.origin.y);
        }
        if([subview isKindOfClass:[UIImageView class]]){
            countImageView++;
            NSLog(@"ImageView at (%f,%f)",subview.frame.origin.x,subview.frame.origin.y);
        }
    }
    
    NSLog(@"countLabel = %d", countLabel);
    NSLog(@"countImageView = %d", countImageView);
    NSLog(@"countTF = %d", countTF);
}

//notification called when share view dismiss
-(void)didDismissController {
    NSLog(@"Dismiss View");
    [self.poc dismissPopoverAnimated:YES];
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"anyViewController" andEventAction:@"dismiss" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

-(void)didDismissNoteInputViewController{
    [self.poc dismissPopoverAnimated:YES];
    [self enableAllButtons];
    [self refreshBackgroundViewByStatus];
}

-(void)didDismissTeacherDistributeViewController{
    [self.poc dismissPopoverAnimated:YES];
    [self enableAllButtons];
    [self refreshBackgroundViewByStatus];
}

//notification called when gallery view dismiss
-(void)didDismissGalleryViewController :(NSNotification *) notification {
    NSLog(@"Dismiss Gallery View");
    GalleryViewController * gwc = (GalleryViewController *)[notification object];
    if (gwc.selectedImage != nil){
        UIImage *image = gwc.selectedImage;
        [self createDragView:image andLink:@"noCallLink" andTitle:@"noCallTitle" andIconStatus:@"normal" andIsIcon:false];
    }else{
        NSLog(@"cancel selection in gallery view controller");
    }
    //dismiss popup
    [self.poc dismissPopoverAnimated:YES];
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"galleryViewController" andEventAction:@"dismiss" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void)storeBGView:(UIImage *)image{
    NSLog(@"storeBGView");

    containerView.backgroundColor = [UIColor colorWithPatternImage:image];
    [self cancelAllViewSelections];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"backgroundView" andEventAction:@"store" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void)createDragView:(UIImage *)image andLink:(NSString *)myLink andTitle:(NSString *)myTitle andIconStatus:(NSString *)myIconStatus andIsIcon:(bool)myIsIcon{
    CGPoint offsetPT = [scrollView contentOffset];
    int newH = offsetPT.y;
    DragView *myView = [[DragView alloc] initWithImage:image andLink:myLink andTitle:myTitle offsetH:newH andIconStatus:myIconStatus andIsIcon:myIsIcon];
    [self.containerView addSubview:myView];
    [self cancelAllViewSelections];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    //log
    NSArray * key = @[@"link",@"title",@"offsetHeight",@"iconType",@"isIcon"];
    NSArray * data = @[
                       [NSString stringWithFormat:@"%@",myLink],
                       [NSString stringWithFormat:@"%@",myTitle],
                       [NSString stringWithFormat:@"%d",newH],
                       [NSString stringWithFormat:@"%@",myIconStatus],
                       [NSString stringWithFormat:@"%d",myIsIcon]
                       ];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"dragView" andEventAction:@"create" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

//notification called when text view controller dismiss
-(void)didDismissTextViewController:(NSNotification *) notification {
    NSLog(@"Dismiss Text View");
    TextViewController * twc = (TextViewController *)[notification object];
    
    //get NSdata back to image, and put it into imageview
    NSAttributedString * mtuStr = [[NSAttributedString alloc] initWithAttributedString:twc.myTextView.attributedText];
    
    if ([twc getHasCurrentLabel]){
        [self updateText:mtuStr bySelectedObj:onSelectedObject];
    }else{
        [self createText:mtuStr withLink:@"noCallLink" withTitle:@"noCallTitle" isBookMark:false];
    }
    
    //dismiss popup
    [self.poc dismissPopoverAnimated:YES];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"text"];
    NSArray * data = @[
                       [NSString stringWithFormat:@"%@",[mtuStr string]]
                       ];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"textViewController" andEventAction:@"dismiss" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

//notification called when draw view dismiss
-(void)didDismissDrawView {
    NSLog(@"Dismiss Draw View");
    [myDrawView removeFromSuperview];
    
    //get NSdata back to image
    MySingleton* singleton = [MySingleton getInstance];
    NSData *imageData = singleton.globalImageData;
    
    //Resize Image
    UIImage *originalImage = [[UIImage alloc] initWithData:imageData];
    CGSize destinationSize = self.containerView.frame.size;
    
    UIGraphicsBeginImageContext(destinationSize);
    [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //Crop Image
    CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], singleton.globalImageRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    CGPoint offsetPT = [scrollView contentOffset];
    int newH = offsetPT.y;
    
    //put it into imageview
    DragView *myView = [[DragView alloc] initWithImage:croppedImage andLink:@"noCallLink" andTitle:@"noCallTitle" offsetH:newH andIconStatus:@"normal" andIsIcon:false];
    myView.frame = CGRectMake(singleton.globalImageRect.origin.x, singleton.globalImageRect.origin.y, myView.frame.size.width, myView.frame.size.height);
    [self.containerView addSubview:myView];
    [self becomeFirstResponder];
    
    //reset
    [self enableAllButtons];
    [self cancelAllViewSelections];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    NSArray * key = @[@"objX",@"objY",@"objWidth",@"objHeight"];
    NSArray * data = @[
             [NSString stringWithFormat:@"%f",singleton.globalImageRect.origin.x],
             [NSString stringWithFormat:@"%f",singleton.globalImageRect.origin.y],
             [NSString stringWithFormat:@"%f",myView.frame.size.width],
             [NSString stringWithFormat:@"%f",myView.frame.size.height]
             ];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"drawView" andEventAction:@"dismissWithStroke" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

//notification called when draw view dismiss
-(void)didDismissDrawViewWithNoStroke {
    NSLog(@"Dismiss Draw View With No Stroke");
    [myDrawView removeFromSuperview];
    [self becomeFirstResponder];

    //log
    NSArray * key = @[];
    NSArray * data = @[];

    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"drawView" andEventAction:@"dismissWithoutStroke" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
    
    [self enableAllButtons];
    [self cancelAllViewSelections];
}

//notification called when draw view dismiss
-(void)didDefineQuestionViewDismissed {
    NSLog(@"Dismiss Define Question View");

    [myDefineQuestionView removeFromSuperview];
    [self becomeFirstResponder];
    
    //for back button to alert save before leave
    needSave = true;
    
    [self enableAllButtons];
    [self cancelAllViewSelections];
}

-(void)refreshNoteButtons:(NSNotification *) notification{
    [self enableAllButtons];
}

-(void)didNoticeRemove:(NSNotification *) notification{
    NSLog(@"Remove view here");
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    if ([[notification object] isKindOfClass:[DragLabel class]]){
        //log
        DragLabel * obj = (DragLabel *) [notification object];
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight",@"text"];
        data = @[
                 @"dragLabel",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height],
                 [NSString stringWithFormat:@"%@",[obj.getAttStr string]]
                 ];
    }else if ([[notification object] isKindOfClass:[DragView class]]){
        //log
        DragView * obj = (DragView *) [notification object];
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight"];
        data = @[
                 @"dragView",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height]
                 ];
    }
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"removeObject" andEventAction:@"appear" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
    [[notification object] removeFromSuperview];
    [self becomeFirstResponder];
    
    //refresh button
    [self enableAllButtons];
    
    //for back button to alert save before leave
    needSave = true;
}

//notification called when obj ReadyForResize
-(void)AppearControlBtn:(NSNotification *) notification{
    NSLog(@"AppearControlBtn here");
    [self cancelAllViewSelections];
    scrollView.scrollEnabled=NO;
    onSelectedObject = [notification object];
    UIView * obj = (UIView *) onSelectedObject;
    [self RefreshControlBtns:nil];

    for (DragControlBtn* btn in myButtons){
        //put ctrl buttons on same layer of object
        [self.containerView insertSubview:btn atIndex:[obj.superview.subviews indexOfObject:obj]+1];
        if ([onSelectedObject isKindOfClass:[DragLabel class]]){
            //DragLabel * obj = (DragLabel *) [notification object];
            if(btn == topLeftBtn || btn == bottomRightBtn){
                btn.hidden=false;
            }else{
                btn.hidden=true;
            }
        }else if ([onSelectedObject isKindOfClass:[DragView class]]){
            //DragView * obj = (DragView *) [notification object];
            btn.hidden=false;
        }else if ([onSelectedObject isKindOfClass:[DragTextField class]]){
            //DragTextField * obj = (DragTextField *) [notification object];
            if(btn == topLeftBtn || btn == bottomRightBtn){
                btn.hidden=false;
            }else{
                btn.hidden=true;
            }
        }
    }
    
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    if ([onSelectedObject isKindOfClass:[DragLabel class]]){
        //log
        DragLabel * obj = (DragLabel *) onSelectedObject;
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight",@"text"];
        data = @[
                 @"dragLabel",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height],
                 [NSString stringWithFormat:@"%@",[obj.getAttStr string]]
                 ];
    }else if ([onSelectedObject isKindOfClass:[DragView class]]){
        //log
        DragView * obj = (DragView *) onSelectedObject;
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight"];
        data = @[
                 @"dragView",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height]
                 ];
    }
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"controlButtons" andEventAction:@"appear" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

//notification called when obj dragged
-(void)RefreshControlBtns:(NSNotification *) notification{
    [self repositioningAllCtrlBtns];
    [self refreshOnSelectedObjBorder];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log object new movement (include pan)
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    if ([onSelectedObject isKindOfClass:[DragLabel class]]){
        //log
        DragLabel * obj = (DragLabel *) onSelectedObject;
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight",@"link",@"title",@"theta",@"text"];
        data = @[
                 @"dragLabel",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height],
                 [NSString stringWithFormat:@"%@",[obj getLINK]],
                 [NSString stringWithFormat:@"%@",[obj getTITLE]],
                 [NSString stringWithFormat:@"%f",[obj getTHETA]],
                 [NSString stringWithFormat:@"%@",[obj.getAttStr string]]
                 ];
    }else if ([onSelectedObject isKindOfClass:[DragView class]]){
        //log
        DragView * obj = (DragView *) onSelectedObject;
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight",@"link",@"title",@"theta"];
        data = @[
                 @"dragView",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height],
                 [NSString stringWithFormat:@"%@",[obj getLINK]],
                 [NSString stringWithFormat:@"%@",[obj getTITLE]],
                 [NSString stringWithFormat:@"%f",[obj getTHETA]]
                 ];
    }
    
    //log
    
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    //to avoid too much duplicate event log, we dont
    [singleton.logCon setEventType:@"refreshView" andEventAction:@"do" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

-(void)DismissControlBtn{
    NSLog(@"DismissControlBtn here");
    for (DragControlBtn* btn in myButtons){
        btn.hidden=true;
    }
}

-(void)noticeDraggingFromBtn:(NSNotification *) notification{
    NSLog(@"RefreshOnSelectedFrameByControlBtnDragged here");
    MySingleton* singleton = [MySingleton getInstance];
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    NSString * buttonType = @"";
    
    DragControlBtn * ctrlBtn = (DragControlBtn *)[notification object];
    if ([onSelectedObject isKindOfClass:[DragLabel class]] || [onSelectedObject isKindOfClass:[DragTextField class]] || [onSelectedObject isKindOfClass:[DragView class]]){
        UIView * obj;
        if ([onSelectedObject isKindOfClass:[DragLabel class]]){
            obj = (DragLabel *)onSelectedObject;
        }else if ([onSelectedObject isKindOfClass:[DragTextField class]]){
            obj = (DragTextField *)onSelectedObject;
        }else if ([onSelectedObject isKindOfClass:[DragView class]]){
            obj = (DragView *)onSelectedObject;
        }
        if(ctrlBtn == topLeftBtn){
            //log
            buttonType = @"topLeftBtn";
            
            [ctrlBtn changeToDown];
            [bottomRightBtn changeToLock];
            
            CGPoint oldBottmRight = CGPointMake(obj.frame.origin.x+obj.frame.size.width, obj.frame.origin.y+obj.frame.size.height);
            float newWidth = oldBottmRight.x-ctrlBtn.center.x;
            float newHeight = oldBottmRight.y-ctrlBtn.center.y;
            
            CGPoint newPT = CGPointMake(ctrlBtn.center.x+newWidth/2, ctrlBtn.center.y+newHeight/2);
            //only move if center does not exists containView
            if (CGRectContainsPoint(self.containerView.frame, newPT)){
                bool condForAll = newWidth > MIN_FRAME_LENGTH/2 && newHeight > MIN_FRAME_LENGTH/2;
                bool condForTF = newWidth <= MAX_TF_WIDTH && newHeight <= MAX_TF_HEIGHT && newWidth >= MIN_TF_WIDTH;
                if ([onSelectedObject isKindOfClass:[DragLabel class]] || [onSelectedObject isKindOfClass:[DragView class]] ){
                    if (condForAll){
                        obj.frame = CGRectMake(ctrlBtn.center.x, ctrlBtn.center.y, newWidth, newHeight);
                    }
                }else if ([onSelectedObject isKindOfClass:[DragTextField class]]){
                    if (condForAll && condForTF){
                        obj.frame = CGRectMake(ctrlBtn.center.x, ctrlBtn.center.y, newWidth, newHeight);
                        singleton.globalPreviousTFFrame = CGRectMake(0, 0, newWidth, newHeight);
                    }
                }
            }
            
            [self repositioningAllCtrlBtns];
            [self refreshOnSelectedObjBorder];
        }else if(ctrlBtn == bottomRightBtn){
            //log
            buttonType = @"bottomRightBtn";
            
            [ctrlBtn changeToDown];
            [topLeftBtn changeToLock];
            
            float newWidth = ctrlBtn.center.x-obj.frame.origin.x;
            float newHeight = ctrlBtn.center.y-obj.frame.origin.y;
            
            CGPoint newPT = CGPointMake(obj.frame.origin.x+newWidth/2, obj.frame.origin.y+newHeight/2);
            //only move if center does not exists containView
            if (CGRectContainsPoint(self.containerView.frame, newPT)){
                bool condForAll = newWidth > MIN_FRAME_LENGTH/2 && newHeight > MIN_FRAME_LENGTH/2;
                bool condForTF = newWidth <= MAX_TF_WIDTH && newHeight <= MAX_TF_HEIGHT && newWidth >= MIN_TF_WIDTH;
                if ([onSelectedObject isKindOfClass:[DragLabel class]] || [onSelectedObject isKindOfClass:[DragView class]]){
                    if (condForAll){
                        obj.frame = CGRectMake(obj.frame.origin.x, obj.frame.origin.y, newWidth, newHeight);
                    }
                }else if ([onSelectedObject isKindOfClass:[DragTextField class]]){
                    if (condForAll && condForTF){
                        obj.frame = CGRectMake(obj.frame.origin.x, obj.frame.origin.y, newWidth, newHeight);
                        singleton.globalPreviousTFFrame = CGRectMake(0, 0, newWidth, newHeight);
                    }
                }
            }
    
            [self repositioningAllCtrlBtns];
            [self refreshOnSelectedObjBorder];
        }else if (ctrlBtn == topRightBtn){
            //log
            buttonType = @"topRightBtn";
            
            //only DragView can rotate
            DragView * dv;
            if ([onSelectedObject isKindOfClass:[DragView class]]){
                dv = (DragView *)onSelectedObject;
            }

            for (DragControlBtn * btn in myButtons){
                btn.hidden = true;
            }
            
            float deltaY = ctrlBtn.center.y - dv.center.y;
            float deltaX = ctrlBtn.center.x - dv.center.x;
            float angleInDegrees = atan2(deltaY, deltaX) * 180 / M_PI + 45;
            //change to near -270,-180-90,0,90,180,270
            angleInDegrees = [self calculateNear90Degree:angleInDegrees];
            
            [dv setTransform:CGAffineTransformMakeRotation(angleInDegrees * M_PI / 180)];
            [dv setTHETA:angleInDegrees];
        }else if (ctrlBtn == bottomLeftBtn){
            //log
            buttonType = @"bottomLeftBtn";
            
            //only DragView can rotate
            DragView * dv;
            if ([onSelectedObject isKindOfClass:[DragView class]]){
                dv = (DragView *)onSelectedObject;
            }
            
            for (DragControlBtn * btn in myButtons){
                btn.hidden = true;
            }
            float deltaY = ctrlBtn.center.y - dv.center.y;
            float deltaX = ctrlBtn.center.x - dv.center.x;
            float angleInDegrees = atan2(deltaY, deltaX) * 180 / M_PI + 225;
            //change to near -270,-180-90,0,90,180,270
            angleInDegrees = [self calculateNear90Degree:angleInDegrees];
            [dv setTransform:CGAffineTransformMakeRotation(angleInDegrees * M_PI / 180)];
            [dv setTHETA:angleInDegrees];
        }
        //for back button to alert save before leave
        needSave = true; 
    }
    
    //log
    if ([onSelectedObject isKindOfClass:[DragLabel class]]){
        //log
        DragLabel * obj = (DragLabel *) onSelectedObject;
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight",@"text",@"buttonType"];
        data = @[
                 @"dragLabel",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height],
                 [NSString stringWithFormat:@"%@",[obj.getAttStr string]],
                 [NSString stringWithFormat:@"%@",buttonType]
                 ];
    }else if ([onSelectedObject isKindOfClass:[DragView class]]){
        //log
        DragView * obj = (DragView *) onSelectedObject;
        key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight",@"buttonType"];
        data = @[
                 @"dragView",
                 [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                 [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                 [NSString stringWithFormat:@"%f",obj.frame.size.width],
                 [NSString stringWithFormat:@"%f",obj.frame.size.height],
                 [NSString stringWithFormat:@"%@",buttonType]
                 ];
    }
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    //to avoid too much duplicate event log, we dont 
    [singleton.logCon setEventType:@"dragButton" andEventAction:@"dragging" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (float) calculateNear90Degree: (float)angleInDegrees{
    angleInDegrees = (int) angleInDegrees % 360;
    if (angleInDegrees>-360 && angleInDegrees<=-225){
        angleInDegrees = -270;
    }else if (angleInDegrees>-225 && angleInDegrees<=-135){
        angleInDegrees = -180;
    }else if (angleInDegrees>-135 && angleInDegrees<=-45){
        angleInDegrees = -90;
    }else if (angleInDegrees>-45 && angleInDegrees<=45){
        angleInDegrees = 0;
    }else if (angleInDegrees>45 && angleInDegrees<=135){
        angleInDegrees = 90;
    }else if (angleInDegrees>135 && angleInDegrees<=225){
        angleInDegrees = 180;
    }else if (angleInDegrees>225 && angleInDegrees<=360){
        angleInDegrees = 270;
    }
    return angleInDegrees;
}

-(void)noticeEndDragFromBtn:(NSNotification *) notification{
    NSLog(@"RefreshOnSelectedFrameByControlBtnDragged here");
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    
    //repositioning all buttons
    [self repositioningAllCtrlBtns];
    [self refreshOnSelectedObjBorder];
    for (DragControlBtn * btn in myButtons){
        [btn changeToOrigin];
        if ([onSelectedObject isKindOfClass:[DragLabel class]]){
            if (btn == bottomLeftBtn || btn == topRightBtn)
                btn.hidden=true;
            else if (btn == topLeftBtn || btn == bottomRightBtn)
                btn.hidden=false;
            
            //log
            DragLabel * obj = (DragLabel *) onSelectedObject;
            key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight",@"text"];
            data = @[
                               @"dragLabel",
                               [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                               [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                               [NSString stringWithFormat:@"%f",obj.frame.size.width],
                               [NSString stringWithFormat:@"%f",obj.frame.size.height],
                               [NSString stringWithFormat:@"%@",[obj.getAttStr string]]
                               ];
        }else if ([onSelectedObject isKindOfClass:[DragView class]]){
            btn.hidden=false;
            
            //log
            DragView * obj = (DragView *) onSelectedObject;
            key = @[@"type",@"objX",@"objY",@"objWidth",@"objHeight"];
            data = @[
                               @"dragView",
                               [NSString stringWithFormat:@"%f",obj.frame.origin.x],
                               [NSString stringWithFormat:@"%f",obj.frame.origin.y],
                               [NSString stringWithFormat:@"%f",obj.frame.size.width],
                               [NSString stringWithFormat:@"%f",obj.frame.size.height]
                               ];
        }else if ([onSelectedObject isKindOfClass:[DragTextField class]]){
            if (btn == bottomLeftBtn || btn == topRightBtn)
                btn.hidden=true;
            else if (btn == topLeftBtn || btn == bottomRightBtn)
                btn.hidden=false;
            
            key = @[];
            data = @[];
        }
    }
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"dragButton" andEventAction:@"endDrag" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

///---

//notification from WebView to create label
-(void)webViewCreateText:(NSNotification *) notification{
    NSLog(@"webViewCreateText here");
    WebViewController * wv = (WebViewController *)[notification object];
    [self createText:wv.attStr withLink:wv.sbAddressField.text withTitle:wv.sbPageTitle.text isBookMark:false];
    [poc dismissPopoverAnimated:YES];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"text",@"link",@"title"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",[wv.attStr string]],[NSString stringWithFormat:@"%@",wv.sbAddressField.text],[NSString stringWithFormat:@"%@",wv.sbPageTitle.text]];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"saveText" andContent:content    andTimeStamp:[MySingleton getTimeStr]];
}

//notification from WebView to create image
-(void)webViewCreateImage:(NSNotification *) notification{
    NSLog(@"webViewCreateImage here");
    WebViewController * wv = (WebViewController *)[notification object];
    [self createDragView:wv.tmpImage andLink:wv.sbAddressField.text andTitle:wv.sbPageTitle.text andIconStatus:@"normal" andIsIcon:false];
    
    [poc dismissPopoverAnimated:YES];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"link",@"title"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",wv.sbAddressField.text],[NSString stringWithFormat:@"%@",wv.sbPageTitle.text]];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"createImage" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

//notification from WebView to create image
-(void)webViewCreateBGImage:(NSNotification *) notification{
    MySingleton* singleton = [MySingleton getInstance];
    
    backgroundImg = [[UIImage alloc] init];
    NSLog(@"webViewCreateBGImage here");
    WebViewController * wv = (WebViewController *)[notification object];
    UIGraphicsBeginImageContext(containerView.frame.size);
    //UIGraphicsBeginImageContextWithOptions(containerView.frame.size, NO, 4);
    [wv.tmpImage drawInRect:containerView.bounds];
    backgroundImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *bgImageData = UIImagePNGRepresentation(backgroundImg);     //change Image to NSData
    //encode image
    NSString * bgImageStr= [bgImageData base64EncodedStringWithOptions:kNilOptions];
    //this is needed since '+' cannot be transferred by POST
    bgImageStr = [bgImageStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    //store BGIMAGE in singleton??
    singleton.globalReceivedNoteBackgroundImageStr = [NSString stringWithFormat:@"%@",bgImageStr];

    [self storeBGView:backgroundImg];
    
    [poc dismissPopoverAnimated:YES];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"setBackground" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}


//notification from WebView to create bookmark
-(void)webViewCreateBookmark:(NSNotification *) notification{
    NSLog(@"webViewCreateBookmark here");
    WebViewController * wv = (WebViewController *)[notification object];
    NSAttributedString * name = [[NSAttributedString alloc] initWithString:wv.sbPageTitle.text];
    [self createText:name withLink:wv.sbAddressField.text withTitle:wv.sbPageTitle.text isBookMark:true];
    
    [poc dismissPopoverAnimated:YES];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"link",@"title"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",wv.sbAddressField.text],[NSString stringWithFormat:@"%@",wv.sbPageTitle.text]];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"createBookmark" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}


-(void) repositioningAllCtrlBtns{
    UIView * obj = (UIView *)onSelectedObject;
    topLeftBtn.center = CGPointMake(obj.frame.origin.x, obj.frame.origin.y);
    topRightBtn.center = CGPointMake(obj.frame.origin.x+obj.frame.size.width, obj.frame.origin.y);
    bottomLeftBtn.center = CGPointMake(obj.frame.origin.x, obj.frame.origin.y+obj.frame.size.height);
    bottomRightBtn.center = CGPointMake(obj.frame.origin.x+obj.frame.size.width, obj.frame.origin.y+obj.frame.size.height);
}

-(void) refreshOnSelectedObjBorder{
    if ([onSelectedObject isKindOfClass:[DragLabel class]]){
        DragLabel * obj = (DragLabel *)onSelectedObject;
        [obj refreshBorder];
    }else if ([onSelectedObject isKindOfClass:[DragView class]]){
        DragView * obj = (DragView *)onSelectedObject;
        [obj refreshBorder];
    }else if ([onSelectedObject isKindOfClass:[DragTextField class]]){
        DragTextField * obj = (DragTextField *)onSelectedObject;
        [obj refreshBorder];
    }
}

- (void) createText: (NSAttributedString *)mutStr withLink:(NSString *)myLink withTitle:(NSString *)myTitle isBookMark:(bool)myIsBookMark{
    NSLog(@"createText");
    CGPoint offsetPT = [scrollView contentOffset];
    int newH = offsetPT.y;
    NSLog(@"newH = %d", newH);
    DragLabel *myDragLabel = [[DragLabel alloc] initWithFrame:CGRectZero inputStr:mutStr andLink:myLink andTitle:myTitle isBookMark:myIsBookMark offsetH:newH];
    NSString * newText = myDragLabel.text;
    [self.containerView addSubview:myDragLabel];
    
    //refresh
    [self cancelAllViewSelections];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"text"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",newText]];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"dragLabel" andEventAction:@"createText" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void) updateText:(NSAttributedString *)mutStr bySelectedObj:(NSObject *)obj {
    NSLog(@"updateText");
    DragLabel * myDragLabel = (DragLabel *) obj;
    NSString * oriText = myDragLabel.text;
    myDragLabel.attributedText = mutStr;
    NSString * newText = myDragLabel.text;
    [myDragLabel refreshFrame];
    
    //refresh
    [self cancelAllViewSelections];
    
    //for back button to alert save before leave
    needSave = true;
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"from",@"to"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",oriText],[NSString stringWithFormat:@"%@",newText]];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"dragLabel" andEventAction:@"updateText" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void) disableAllButtons{
    for (int i = 0; i < uiBtnArr.count; i++){
        UIBarButtonItem * btn = (UIBarButtonItem *) uiBtnArr[i];
        btn.enabled=false;
    }
}

- (void) enableAllButtons{
    MySingleton* singleton = [MySingleton getInstance];
    //bool isNormal = [singleton.globalReceivedNoteStatus isEqualToString:@"normal"];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    bool simCompetition = [singleton.globalReceivedNoteStatus rangeOfString:@"competition"].location != NSNotFound;
    //NSLog(@"enableAllButtons - %@",singleton.globalUserType);
    
    //check if there exists ansbox
    int numOfAnsBox = 0;
    bool allAnsBoxShowing = true;
    bool allAnsBoxHiding = true;
    
    //check if there are too many dtf, dv or dl
    int countDTF = 0;
    int countDV = 0;
    int countDL = 0;
    
    //loop through all subviews
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *) subview;
            //NSLog(@"obj = %@",[obj getANSSTATUS] );
            numOfAnsBox++;
            if (allAnsBoxShowing && [[obj getANSSTATUS]  isEqual: @"hideAns"]){
                allAnsBoxShowing = false;
            }
            if (allAnsBoxHiding && [[obj getANSSTATUS]  isEqual: @"showAns"]){
                allAnsBoxHiding = false;
            }
            countDTF++;
        }else if([subview isKindOfClass:[DragView class]]){
            DragView * obj = (DragView *)subview;
            if ([obj getIsAns]){
                numOfAnsBox++;
                if (allAnsBoxShowing && [[obj getANSSTATUS]  isEqual: @"hideAns"]){
                    allAnsBoxShowing = false;
                }
                if (allAnsBoxHiding && [[obj getANSSTATUS]  isEqual: @"showAns"]){
                    allAnsBoxHiding = false;
                }
            }
            countDV++;
        }else if([subview isKindOfClass:[DragLabel class]]){
            DragLabel * obj = (DragLabel *)subview;
            if ([obj getIsAns]){
                numOfAnsBox++;
                if (allAnsBoxShowing && [[obj getANSSTATUS]  isEqual: @"hideAns"]){
                    allAnsBoxShowing = false;
                }
                if (allAnsBoxHiding && [[obj getANSSTATUS]  isEqual: @"showAns"]){
                    allAnsBoxHiding = false;
                }
            }
            countDL++;
        }
    }
    NSLog(@"countDTF=%d",countDTF);
    NSLog(@"countDV=%d",countDV);
    NSLog(@"countDL=%d",countDL);

    //handle each buttons differently
    for (int i = 0; i < uiBtnArr.count; i++){
        UIBarButtonItem * btn = (UIBarButtonItem *) uiBtnArr[i];
        if (btn.image != nil){
            if (btn == shareBtn){
                if (!isPost){
                    btn.enabled=true;   //share image
                }else{
                    btn.enabled=false;  //isPre = save image, others = share image
                }
            }else if (btn == distributeBtn){
                btn.enabled=true;
                //if (!isNormal && numOfAnsBox>0){
                /*
                if (!isNormal){
                    btn.enabled=true;
                }else{
                    btn.enabled=false;
                }
                */
            }else if (btn == showAnsBtn){
                if (!allAnsBoxShowing){
                    btn.enabled=true;
                }else{
                    btn.enabled=false;
                }
            }else if (btn == hideAnsBtn){
                if (!allAnsBoxHiding){
                    btn.enabled=true;
                }else{
                    btn.enabled=false;
                }
            }else if(btn == geometryBtn){
                btn.enabled=false;
            }else if(btn == backBtn){
                if (isPre && simCompetition)
                    btn.enabled=false;
                else
                    btn.enabled=true;
            }else if(btn == cameraBtn || btn == galleryBtn || btn == iconBtn || btn == drawBtn || btn == geometryBtn){
                if (countDV >= MAX_OBJECT_IN_NOTE)
                    btn.enabled=false;
                else
                    btn.enabled=true;
            }else if(btn == addTextBtn){
                if (countDL >= MAX_OBJECT_IN_NOTE)
                    btn.enabled=false;
                else
                    btn.enabled=true;
            }else if(btn == answerBoxBtn){
                if (countDTF >= MAX_OBJECT_IN_NOTE)
                    btn.enabled=false;
                else
                    btn.enabled=true;
            }else{
                //enable for those non-hidden and non-specific defined button
                btn.enabled=true;
            }
        }else{
            btn.enabled=false;
        }
    }
}
- (void) refreshBackgroundViewByStatus{
    MySingleton* singleton = [MySingleton getInstance];
    //set background image
    NSString * status = singleton.globalReceivedNoteStatus;
    if ([status rangeOfString:@"normal"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"whiteboard"]];
    }else if ([status rangeOfString:@"exercise"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"metalboard"]];
    }else if ([status rangeOfString:@"test"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"graphboard"]];
    }else if ([status rangeOfString:@"competition"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"corkboard"]];
    }else{
        [backgroundView setImage:[UIImage imageNamed: @"chalkboard"]];
    }

}

//for share menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//it is called when the menu is open.
- (BOOL)becomeFirstResponder
{
    //NSLog(@"becomeFirstResponder");
    // starts listening for UIMenuControllerDidHideMenuNotification & triggers resignFirstResponder if received
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    return [super becomeFirstResponder];
}

//it is called when the menu is closed.
- (BOOL)resignFirstResponder
{
    NSLog(@"resignFirstResponder");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    // your custom cleanup code here (e.g. deselection)
    //[self restoreOriginal];
    return [super resignFirstResponder];
}

//UIPopover delegate
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    NSLog(@"popover dismissing");
    // do something now that it's been dismissed
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[];
    NSArray * data = @[];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"userDismissPopover" andEventAction:@"click" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
    //log
    NSString * eventType;
    NSString * eventAction;
    
    //textviewcontroller
    if ([popoverController.contentViewController isKindOfClass:[TextViewController class]]){
        id mem = popoverController.contentViewController;
        TextViewController *twc=[mem init];
        
        //turn off keyboard first
        [twc.myTextView endEditing:YES];
        [twc.myTextView resignFirstResponder];
        [[twc view] endEditing:YES];
        [twc resignFirstResponder];
        [[self view] endEditing:YES];
        [self becomeFirstResponder];
        
        //not @"" shows alert
        if (![twc.myTextView.text isEqual: @""]){
            MySingleton* singleton = [MySingleton getInstance];
            NSString* confirmToLeaveTVText = NSLocalizedStringFromTableInBundle(@"confirmToLeaveTVText", nil, singleton.globalLocaleBundle, nil);
            NSString* yesText = NSLocalizedStringFromTableInBundle(@"yes", nil, singleton.globalLocaleBundle, nil);
            NSString* noText = NSLocalizedStringFromTableInBundle(@"no", nil, singleton.globalLocaleBundle, nil);
            
            UIAlertView *alertConfirmView = [[UIAlertView alloc] initWithTitle:confirmToLeaveTVText message:nil delegate:self cancelButtonTitle:noText otherButtonTitles:yesText, nil];
            [alertConfirmView show];
            
            //log
            eventType = @"textViewController";
            eventAction = @"dismissFail";
            [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
            
            return NO;
        }else{
            //log
            eventType = @"textViewController";
            eventAction = @"dismissOK";
            [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
            
            return YES;
        }
    }else if ([popoverController.contentViewController isKindOfClass:[CommentViewController class]]){
        id mem = popoverController.contentViewController;
        CommentViewController *cvc=[mem init];
        
        //turn off keyboard first
        [cvc.myTextView endEditing:YES];
        [cvc.myTextView resignFirstResponder];
        [[cvc view] endEditing:YES];
        [cvc resignFirstResponder];
        [[self view] endEditing:YES];
        [self becomeFirstResponder];
        
        //not @"" shows alert
        if (cvc.mySaveBtn.isEnabled){
            MySingleton* singleton = [MySingleton getInstance];
            NSString* confirmToLeaveTVText = NSLocalizedStringFromTableInBundle(@"confirmToLeaveTVText", nil, singleton.globalLocaleBundle, nil);
            NSString* yesText = NSLocalizedStringFromTableInBundle(@"yes", nil, singleton.globalLocaleBundle, nil);
            NSString* noText = NSLocalizedStringFromTableInBundle(@"no", nil, singleton.globalLocaleBundle, nil);
            
            UIAlertView *alertConfirmView = [[UIAlertView alloc] initWithTitle:confirmToLeaveTVText message:nil delegate:self cancelButtonTitle:noText otherButtonTitles:yesText, nil];
            [alertConfirmView show];
            
            //log
            eventType = @"commentController";
            eventAction = @"dismissFail";
            [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
            return NO;
        }else{
            //log
            eventType = @"commentController";
            eventAction = @"dismissOK";
            [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
            return YES;
        }
    }else if ([popoverController.contentViewController isKindOfClass:[NoteInfoInputController class]]){
        id mem = popoverController.contentViewController;
        NoteInfoInputController *niic=[mem init];
        
        //turn off keyboard first
        [[niic view] endEditing:YES];
        [niic resignFirstResponder];
        [[self view] endEditing:YES];
        [self becomeFirstResponder];
        
        //not @"" shows alert
        if (niic.madeChange){
            MySingleton* singleton = [MySingleton getInstance];
            NSString* confirmToLeaveTVText = NSLocalizedStringFromTableInBundle(@"confirmToLeaveTVText", nil, singleton.globalLocaleBundle, nil);
            NSString* yesText = NSLocalizedStringFromTableInBundle(@"yes", nil, singleton.globalLocaleBundle, nil);
            NSString* noText = NSLocalizedStringFromTableInBundle(@"no", nil, singleton.globalLocaleBundle, nil);
            
            UIAlertView *alertConfirmView = [[UIAlertView alloc] initWithTitle:confirmToLeaveTVText message:nil delegate:self cancelButtonTitle:noText otherButtonTitles:yesText, nil];
            [alertConfirmView show];
            
            //log
            eventType = @"noteInfoController";
            eventAction = @"dismissFail";
            [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
            
            return NO;
        }else{
            [self enableAllButtons];
            [self refreshBackgroundViewByStatus];
            
            //log
            eventType = @"noteInfoController";
            eventAction = @"dismissOK";
            [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];

            return YES;
        }
    }else if ([popoverController.contentViewController isKindOfClass:[GalleryViewController class]]){
        NSLog(@"Gallery View dismissed by clicking out of area of popup view");
        [popoverController dismissPopoverAnimated:YES];
        
        //log
        eventType = @"galleryViewController";
        eventAction = @"dismissOK";
        [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
        
        return YES;
    }else if ([popoverController.contentViewController isKindOfClass:[TeacherDistributeViewController class]]){
        NSLog(@"Teacher Distribute View dismissed by clicking out of area of popup view");
        [self enableAllButtons];
        [self refreshBackgroundViewByStatus];
        [popoverController dismissPopoverAnimated:YES];
        
        //log
        eventType = @"teacherDistributeViewController";
        eventAction = @"dismissOK";

        return YES;
    }else {
        //log
        eventType = @"otherPopoverController";
        eventAction = @"dismissOK";
        [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
        
        return YES;
    }
}

- (void) leaveNote{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NoteViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//UIPopover delegate alert
-(void)alertView:(UIAlertView *)alertConfirmView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"title = %@",alertConfirmView.title);
    MySingleton* singleton = [MySingleton getInstance];
    NSString* confirmToLeaveTVText = NSLocalizedStringFromTableInBundle(@"confirmToLeaveTVText", nil, singleton.globalLocaleBundle, nil);
    NSString* confirmToLeaveNoteText = NSLocalizedStringFromTableInBundle(@"confirmToLeaveNoteText", nil, singleton.globalLocaleBundle, nil);
    
    //log
    NSString * eventType;
    NSString * eventAction;
    
    //leave note
    if (alertConfirmView.title == confirmToLeaveNoteText){
        if (buttonIndex == 0) { // means NO button pressed
            NSLog(@"Cancel");
            eventType = @"leaveNote";
            eventAction = @"alertCancel";
        }
        if(buttonIndex == 1) { // means YES button pressed
            NSLog(@"YES");
            eventType = @"leaveNote";
            eventAction = @"alertOK";
            [self leaveNote];
        }
    }
    //leave textview
    else if (alertConfirmView.title == confirmToLeaveTVText){
        if (buttonIndex == 0) { // means NO button pressed
            NSLog(@"Cancel");
            eventType = @"textViewController";
            eventAction = @"alertCancel";
        }
        if(buttonIndex == 1) { // means YES button pressed
            NSLog(@"YES");
            eventType = @"textViewController";
            eventAction = @"alertOK";
            
            [self enableAllButtons];
            [self refreshBackgroundViewByStatus];
            [poc dismissPopoverAnimated:YES];
        }
    }
    
    //log
    NSArray * key = @[];
    NSArray * data = @[];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:eventType andEventAction:eventAction andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (void)callEditTextViewController:(NSNotification *) notification{
    NSLog(@"callEditTextViewController");
    [self cancelAllViewSelections];
    
    onSelectedObject = [notification object];
    TextViewController *tvc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"TextViewCtrler"];
    
    //get original text from notification (DragLabel)
    DragLabel * myDragLabel = (DragLabel *)onSelectedObject;
    
    poc = [[UIPopoverController alloc] initWithContentViewController:tvc];
    poc.delegate=self;
    
    if (poc!= nil && onSelectedObject!=nil){
        NSLog(@"callEditTextViewController - in deep");
        [poc presentPopoverFromRect:myDragLabel.frame inView:self.containerView permittedArrowDirections:UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight|UIPopoverArrowDirectionDown animated:YES];
        [tvc addText:myDragLabel.attributedText];
        
        //log
        MySingleton* singleton = [MySingleton getInstance];
        NSArray * key = @[@"text"];
        NSArray * data = @[[NSString stringWithFormat:@"%@",myDragLabel.text]];
        NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
        [singleton.logCon setEventType:@"textViewController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    }
}

- (void)callWebViewController:(NSNotification *) notification{
    NSLog(@"callWebViewController");
    MySingleton* singleton = [MySingleton getInstance];
    [self cancelAllViewSelections];
    
    NSObject * checkObj = [notification object];
    NSString * myLink = @"";
    if ([checkObj isKindOfClass:[DragLabel class]]){
        DragLabel * obj = (DragLabel *)[notification object];
        NSLog(@"callWebViewController = %@", obj.getLINK);
        myLink = [[NSString alloc] initWithFormat:@"%@", obj.getLINK];
    }else if ([checkObj isKindOfClass:[DragView class]]){
        DragView * obj = (DragView *)[notification object];
        NSLog(@"callWebViewController = %@", obj.getLINK);
        myLink = [[NSString alloc] initWithFormat:@"%@", obj.getLINK];
    }

    //log
    NSArray * key = @[@"link"];
    NSArray * data = @[myLink];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"openLink" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
    if (APP_TYPE == 0){
        //Teacher version only
        [self openBrowserByLink:myLink];
            
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:myLink]];
    }
    
}

- (void)callWebViewReport:(NSNotification *) notification{
    NSLog(@"web view from report button");
    MySingleton* singleton = [MySingleton getInstance];
    
    [self handleBrowser:browserBtn];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //do function
        [singleton.wvc loadReport];
    });
}

//teacher functions
- (IBAction)handleEditTag:(id)sender {
    [self cancelAllViewSelections];
    
    [self handleSave:nil];
    
    NoteInfoInputController *niic = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"NoteInfoInputCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:niic];
    poc.delegate=self;
    
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)handleShowAns:(id)sender {
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *)subview;
            [obj handleShowAns];
        }else if([subview isKindOfClass:[DragView class]]){
            DragView * obj = (DragView *)subview;
            [obj handleShowAns];
        }else if([subview isKindOfClass:[DragLabel class]]){
            DragLabel * obj = (DragLabel *)subview;
            [obj handleShowAns];
        }
    }
    //refresh buttons
    [self enableAllButtons];
}

- (IBAction)handleHideAns:(id)sender {
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *)subview;
            [obj handleHideAns];
        }else if([subview isKindOfClass:[DragView class]]){
            DragView * obj = (DragView *)subview;
            [obj handleHideAns];
        }else if([subview isKindOfClass:[DragLabel class]]){
            DragLabel * obj = (DragLabel *)subview;
            [obj handleHideAns];
        }
    }
    //refresh buttons
    [self enableAllButtons];
}

- (IBAction)handleDistribute:(id)sender {
    [self cancelAllViewSelections];
    
    int NoOfAns = 0;
    int NoOfAnsBox = 0;
    //count num of ans box
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            NoOfAns++;
            NoOfAnsBox++;
        }else if([subview isKindOfClass:[DragView class]]){
            DragView * obj = (DragView *)subview;
            if ([obj getIsAns]){
                NoOfAns++;
            }
        }else if([subview isKindOfClass:[DragLabel class]]){
            DragLabel * obj = (DragLabel *)subview;
            if ([obj getIsAns]){
                NoOfAns++;
            }
        }
    }
    
    [self handleHideAns:nil];
    
    [self handleSave:nil];  //must be after hide ans, otherwise thumbnail will show the ans in students view
    
    bool allAnsBoxInputtedAns = true;
    //check if all answer box has been inputted answer
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * dtf = (DragTextField *)subview;
            NSLog(@"dtf getANSTEXT= %@", [dtf getANSTEXT] );
            NSLog(@"dtf getTEXT = %@", [dtf getSTR] );
            if ([[dtf getANSTEXT]  isEqual: @""]){
                NSLog(@"answer not yet inputted");
                allAnsBoxInputtedAns = false;
                [dtf handleShowAns];
            }
        }
    }
    
    MySingleton* singleton = [MySingleton getInstance];
    bool isNormal = [singleton.globalReceivedNoteStatus isEqual: @"normal"];
    
    if((isNormal && NoOfAns == 0 && NoOfAnsBox == 0) || !isNormal){
        if (allAnsBoxInputtedAns){
            //for next step
            TeacherDistributeViewController *tdvc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"TeacherDistributeViewCtrler"];
            poc = [[UIPopoverController alloc] initWithContentViewController:tdvc];
            poc.delegate=self;
            if (poc != nil){
                [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            [tdvc setNoOfAnsBox:NoOfAnsBox];
            [tdvc setNoOfAns:NoOfAns];
        }else{
            //alert input answer before distribute
            NSString* alertInputAnsHeadText = NSLocalizedStringFromTableInBundle(@"alertInputAnsHeadText", nil, singleton.globalLocaleBundle, nil);
            NSString* alertInputAnsContentText = NSLocalizedStringFromTableInBundle(@"alertInputAnsContentText", nil, singleton.globalLocaleBundle, nil);
            [MySingleton alertStatus:alertInputAnsContentText :alertInputAnsHeadText :0];
            
            [self enableAllButtons];
        }
    }else{
        //alert normal note should not contain ans or ansbox
        NSString* alertInputAnsHeadText = NSLocalizedStringFromTableInBundle(@"alertNoteContainAnsHeadText", nil, singleton.globalLocaleBundle, nil);
        NSString* alertInputAnsContentText = NSLocalizedStringFromTableInBundle(@"alertNoteContainAnsContentText", nil, singleton.globalLocaleBundle, nil);
        [MySingleton alertStatus:alertInputAnsContentText :alertInputAnsHeadText :0];
        
        [self enableAllButtons];
    }

}

- (IBAction)handleReadStudentRecord:(id)sender {
    NSLog(@"handleThumbailController");
    StudentRecordController *src = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"StudentRecordCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:src];
    poc.delegate=self;
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:readStudentRecordBtn permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
}

- (IBAction)handlePreview:(id)sender {
    NSLog(@"handleThumbailController");
    StudentRecordController *src = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"StudentThumbnailCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:src];
    poc.delegate=self;
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:previewBtn permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
}

- (IBAction)handleFeelingCorrect:(id)sender {
    MySingleton* singleton = [MySingleton getInstance];
    NSString * imageName = @"feeling correct 70";
    NSString * iconStatus = @"correct";
    UIImage *image = [UIImage imageNamed:imageName];
    [self createDragView:image andLink:@"noCallLink" andTitle:@"noCallTitle" andIconStatus:iconStatus andIsIcon:true];
    
    //log
    NSArray * key = @[@"iconType"];
    NSArray * data = @[iconStatus];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"emoji" andEventAction:@"add" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleFeelingWrong:(id)sender {
    NSString * imageName = @"feeling incorrect 70";
    NSString * iconStatus = @"incorrect";
    UIImage *image = [UIImage imageNamed:imageName];
    [self createDragView:image andLink:@"noCallLink" andTitle:@"noCallTitle" andIconStatus:iconStatus andIsIcon:true];
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"iconType"];
    NSArray * data = @[iconStatus];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"emoji" andEventAction:@"add" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleFeelingGood:(id)sender {
    NSString * imageName = @"feeling happy 70";
    NSString * iconStatus = @"happy";
    UIImage *image = [UIImage imageNamed:imageName];
    [self createDragView:image andLink:@"noCallLink" andTitle:@"noCallTitle" andIconStatus:iconStatus andIsIcon:true];
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"iconType"];
    NSArray * data = @[iconStatus];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"emoji" andEventAction:@"add" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleFeelingNoIdea:(id)sender {
    NSString * imageName = @"feeling sad 70";
    NSString * iconStatus = @"noidea";
    UIImage *image = [UIImage imageNamed:imageName];
    [self createDragView:image andLink:@"noCallLink" andTitle:@"noCallTitle" andIconStatus:iconStatus andIsIcon:true];
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"iconType"];
    NSArray * data = @[iconStatus];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"emoji" andEventAction:@"add"   andContent:content    andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleFeelingNoTime:(id)sender {
    NSString * imageName = @"feeling times up 70";
    NSString * iconStatus = @"timesup";
    UIImage *image = [UIImage imageNamed:imageName];
    [self createDragView:image andLink:@"noCallLink" andTitle:@"noCallTitle" andIconStatus:iconStatus andIsIcon:true];
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"iconType"];
    NSArray * data = @[iconStatus];
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"emoji" andEventAction:@"add" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

- (IBAction)handleComment:(id)sender {
    NSLog(@"Handle Comment");
    [self cancelAllViewSelections];
    
    //MySingleton* singleton = [MySingleton getInstance];
    CommentViewController *tvc = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"CommentViewCtrler"];
    poc = [[UIPopoverController alloc] initWithContentViewController:tvc];
    poc.delegate=self;
    if (poc != nil){
        [poc presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        //log
        MySingleton* singleton = [MySingleton getInstance];
        NSMutableDictionary * content;
        NSArray * key = @[];
        NSArray * data = @[];
        content = [MySingleton putTwoArraysIntoDict:key andData:data];
        [singleton.logCon setEventType:@"commentController" andEventAction:@"open" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    }
}

- (void) highlightWrongAnswers{
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *) subview;
            if (![obj.text  isEqual: [obj getANSTEXT]] || [obj.text  isEqual: @""]){
                //indicate it is wrong or empty
                [obj highlightBox];
            }else{
                NSLog(@"dehighlightBox");
                [obj dehighlightBox];
            }
        }
    }
}

@end


