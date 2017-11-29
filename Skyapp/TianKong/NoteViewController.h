//
//  NoteViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 12/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"
#import "DragControlBtn.h"
#import "SaveController.h"
#import "WebViewController.h"
#import "LogController.h"
#import "DefineQuestionView.h"

@interface NoteViewController : UIViewController <UIPopoverControllerDelegate, UIApplicationDelegate>{
    bool loadNoteSuccess;
    bool needSave;
    NSArray * uiBtnArr;
    NSArray * uiBtnName;
    
    //NSTimer
    NSTimer * timerWhenOpen;
    NSTimer * timerWhenHitAnsBox;
    int timeO;
    int timeHAB;
    
    //count answer
    int correctAnswer;
    int fullMarks;
    
    UIImage * backgroundImg;
}

@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

//top bar btns
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *iconBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addTextBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *galleryBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *drawBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *geometryBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *answerBoxBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *defineQuestionBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editTagBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *distributeBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;

//bot bar btns
@property (strong, nonatomic) IBOutlet UIBarButtonItem *showAnsBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *hideAnsBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *readStudentRecordBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previewBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *feelingCorrectBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *feelingWrongBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *feelingGoodBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *feelingNoIdeaBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *feelingNoTimeBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *commentBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *browserBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeHeadLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

//top bar methods
- (IBAction)handleBack:(id)sender;
- (IBAction)handleIcon:(id)sender;	
- (IBAction)handleAddText:(id)sender;
- (IBAction)handleGallery:(id)sender;
- (IBAction)handleCamera:(id)sender;
- (IBAction)handleDraw:(id)sender;
- (IBAction)handleGeometry:(id)sender;
- (IBAction)handleAnswerBox:(id)sender;
- (IBAction)handleDefineQuestion:(id)sender;
- (IBAction)handleEditTag:(id)sender;
- (IBAction)handleDistribute:(id)sender;
- (IBAction)handleShare:(id)sender;
- (IBAction)handleSave:(id)sender;

//bot bar methods
- (IBAction)handleShowAns:(id)sender;
- (IBAction)handleHideAns:(id)sender;
- (IBAction)handleReadStudentRecord:(id)sender;
- (IBAction)handlePreview:(id)sender;
- (IBAction)handleFeelingCorrect:(id)sender;
- (IBAction)handleFeelingWrong:(id)sender;
- (IBAction)handleFeelingGood:(id)sender;
- (IBAction)handleFeelingNoIdea:(id)sender;
- (IBAction)handleFeelingNoTime:(id)sender;
- (IBAction)handleComment:(id)sender;
- (IBAction)handleBrowser:(id)sender;

//for all popview, use this controller
@property (nonatomic, retain) UIPopoverController *poc;

//for draw handling
@property (nonatomic, retain) DrawView *myDrawView;
@property (nonatomic, retain) DefineQuestionView *myDefineQuestionView;


//for control resize
@property (nonatomic, retain) NSMutableArray *myButtons;
@property (nonatomic, retain) DragControlBtn * topLeftBtn;
@property (nonatomic, retain) DragControlBtn * topRightBtn;
@property (nonatomic, retain) DragControlBtn * bottomLeftBtn;
@property (nonatomic, retain) DragControlBtn * bottomRightBtn;
@property (nonatomic, retain) NSObject * onSelectedObject;

//for save control
@property (nonatomic, retain) SaveController * mySaveController;

@end
