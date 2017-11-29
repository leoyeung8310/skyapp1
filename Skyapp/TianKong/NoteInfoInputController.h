//
//  NoteInfoInputController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 25/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteInfoInputController : UIViewController <UITextFieldDelegate, UIPopoverControllerDelegate>{
    NSString * chosenSubject;
    NSString * chosenDisType;
    int chosenDifficulty;
    int chosenDifficultyPresentation;
    int chosenHighlightAns;
    int chosenGiveGift;
    int chosenTimeLimit;
    int chosenMaxTrial;
}

@property (strong, nonatomic) IBOutlet UILabel *headLabel;

@property (strong, nonatomic) IBOutlet UILabel *subjectLabel;
@property (strong, nonatomic) IBOutlet UILabel *topicLabel;
@property (strong, nonatomic) IBOutlet UILabel *subTopicLabel;
@property (strong, nonatomic) IBOutlet UILabel *keywordsLabel;
@property (strong, nonatomic) IBOutlet UILabel *remarksLabel;

@property (strong, nonatomic) IBOutlet UILabel *disTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (strong, nonatomic) IBOutlet UILabel *difficultyPresentationLabel;
@property (strong, nonatomic) IBOutlet UILabel *highlightAnsLabel;
@property (strong, nonatomic) IBOutlet UILabel *giveGiftLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLimitLabel;
@property (strong, nonatomic) IBOutlet UILabel *maxTrialLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *subjectSC;
@property (strong, nonatomic) IBOutlet UITextField *topicTF;
@property (strong, nonatomic) IBOutlet UITextField *subTopicTF;
@property (strong, nonatomic) IBOutlet UITextField *keywordsTF;
@property (strong, nonatomic) IBOutlet UITextField *remarksTF;

@property (strong, nonatomic) IBOutlet UISegmentedControl *disTypeSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *difficultySC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *difficultyPresentationSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *highlightAnsSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *giveGiftSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *timeLimitSC;
@property (strong, nonatomic) IBOutlet UISegmentedControl *maxTrialSC;

@property (strong, nonatomic) IBOutlet UIButton *pickTopicBtn;
@property (strong, nonatomic) IBOutlet UIButton *pickSubTopicBtn;

@property (assign) BOOL madeChange; //for popover view leave

- (IBAction)handleNoteTypeChange:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *okBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)handleOK:(id)sender;

- (IBAction)handlePickTopic:(id)sender;
- (IBAction)handlePickSubTopic:(id)sender;

@property (nonatomic, retain) UIPopoverController *poc;


@end
