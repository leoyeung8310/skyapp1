//
//  MySingleton.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 10/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <CoreGraphics/CGGeometry.h>
#include "WebViewController.h"
#include "LogController.h"

@interface MySingleton : NSObject{
    NSNumber *globalLang;
    NSBundle *globalLocaleBundle; //Lang --> Path --> Bundle (for changing lang on fly)
    
    NSString *globalUserType;
    NSString *globalUserName;
    NSString *globalUserID;
    NSString *globalUserAccount;
    NSString *globalUserEmail;
    NSString *globalUserSchool;
    NSString *globalUserServer;
    
    NSString *globalOnSelectedNoteID;
    NSString *globalQuestionID;
    NSString *globalAnswerID;
    NSString *globalReceivedNoteStr;
    NSString *globalReceivedNoteStatus;
    
    NSString *globalReceivedNoteSubject;
    NSString *globalReceivedNoteTopic;
    NSString *globalReceivedNoteSubTopic;
    NSString *globalReceivedNoteKeywords;
    NSString *globalReceivedNoteRemarks;
    NSString *globalReceivedNoteDifficulty;
    NSString *globalReceivedNoteDifficultyPresentation;
    NSString *globalReceivedNoteHighlightAns;
    NSString *globalReceivedNoteGiveGift;
    NSString *globalReceivedNoteTimeLimit;
    NSString *globalReceivedNoteMaxTrial;
    NSString *globalReceivedNoteNoOfTrial;
    NSString *globalReceivedNoteBackgroundImageStr; //BackgroundImage
    NSString *globalReceivedNoteEventLog;
    NSString *globalReceivedNoteQuestionLines;
    
    NSMutableArray *CONST_STRINGS;
    NSArray *CONST_STRINGS2;
    
    //ICONS (Emoji)
    NSArray *ICON_NORMAL;
    NSArray *ICON_COLLECT;
    
    //will cancel global variables
    NSData *globalImageData;
    CGRect globalImageRect;
    
    //for init tf frame size
    CGRect globalPreviousTFFrame;
    
    //for keyboard scroll view
    UIView* activeField;
    
    //location
    NSString *globalLocInfo;
    
    //view only
    NSString *globalViewOnlyNoteID;
    NSString *globalReceivedNoteViewOnlyStr;
    NSString *globalReceivedNoteViewOnlyBackgroundImageStr;
    NSString *globalReceivedNoteViewOnlyStatus;
    
    //webview
    WebViewController *wvc;
    
    //log
    LogController *logCon;
    
    //Subject
    NSArray *TOPIC_LIST;
    NSDictionary *SUB_TOPIC_LIST;
}

//global variable declaration
@property (nonatomic,retain) NSNumber *globalLang;
@property (nonatomic,retain) NSBundle *globalLocaleBundle; //Lang --> Path --> Bundle (for changing lang on fly)

@property (nonatomic,retain) NSString *globalUserType;
@property (nonatomic,retain) NSString *globalUserName;
@property (nonatomic,retain) NSString *globalUserID;
@property (nonatomic,retain) NSString *globalUserAccount;
@property (nonatomic,retain) NSString *globalUserEmail;
@property (nonatomic,retain) NSString *globalUserSchool;
@property (nonatomic,retain) NSString *globalUserServer;

@property (nonatomic,retain) NSString *globalOnSelectedNoteID;
@property (nonatomic,retain) NSString *globalQuestionID;
@property (nonatomic,retain) NSString *globalAnswerID;
@property (nonatomic,retain) NSString *globalReceivedNoteStr;
@property (nonatomic,retain) NSString *globalReceivedNoteStatus;

@property (nonatomic,retain) NSString *globalReceivedNoteSubject;
@property (nonatomic,retain) NSString *globalReceivedNoteTopic;
@property (nonatomic,retain) NSString *globalReceivedNoteSubTopic;
@property (nonatomic,retain) NSString *globalReceivedNoteKeywords;
@property (nonatomic,retain) NSString *globalReceivedNoteRemarks;
@property (nonatomic,retain) NSString *globalReceivedNoteDifficulty;
@property (nonatomic,retain) NSString *globalReceivedNoteDifficultyPresentation;
@property (nonatomic,retain) NSString *globalReceivedNoteHighlightAns;
@property (nonatomic,retain) NSString *globalReceivedNoteGiveGift;
@property (nonatomic,retain) NSString *globalReceivedNoteTimeLimit;
@property (nonatomic,retain) NSString *globalReceivedNoteMaxTrial;
@property (nonatomic,retain) NSString *globalReceivedNoteNoOfTrial;
@property (nonatomic,retain) NSString *globalReceivedNoteBackgroundImageStr; //BackgroundImage
@property (nonatomic,retain) NSString *globalReceivedNoteEventLog;
@property (nonatomic,retain) NSString *globalReceivedNoteQuestionLines;

//ICONS (Emoji)
@property (nonatomic,retain) NSArray *ICON_NORMAL;
@property (nonatomic,retain) NSArray *ICON_COLLECT;

//will cancel global variables
@property (nonatomic,retain) NSData *globalImageData;
@property (nonatomic,assign) CGRect globalImageRect;//??? any problem

//for init tf frame size
@property (nonatomic,assign) CGRect globalPreviousTFFrame;//??? any problem

//for keyboard scroll view
@property (nonatomic,retain) UIView* activeField;

//location
@property (nonatomic,retain) NSString *globalLocInfo;

//view only
@property (nonatomic,retain) NSString *globalViewOnlyNoteID;
@property (nonatomic,retain) NSString *globalReceivedNoteViewOnlyStr;
@property (nonatomic,retain) NSString *globalReceivedNoteViewOnlyBackgroundImageStr;
@property (nonatomic,retain) NSString *globalReceivedNoteViewOnlyStatus;

//webview
@property (nonatomic,retain) WebViewController *wvc;

//log
@property (nonatomic,retain) LogController *logCon;

//Subject
@property (nonatomic,retain) NSArray *TOPIC_LIST;
@property (nonatomic,retain) NSDictionary *SUB_TOPIC_LIST;

+(id) getInstance;

//Retina Display Resize Image Ref: iCab Blog - Scaling images and creating thumbnails from UIViews
+ (void)beginImageContextWithSize:(CGSize)size;
+ (void)endImageContext;
+ (UIImage*)imageFromView:(UIView*)view;
+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;

+ (NSMutableDictionary *)jsonPostMultipleNSStringTo:(NSString *)domain andSubLink:(NSString *)sublink andDataInput:(NSMutableDictionary *)dataInput;
+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size;
+ (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag;
+ (void) startLoading:(UIView *)myView;
+ (void) startLoadingForScrollView:(UIView *)myView withOffSetY:(int)offsetY;
+ (void) endLoading:(UIView *)myView andSuccess:(bool)success;
+ (void) endLoadingForScrollView:(UIView *)myView andSuccess:(bool)success withOffSetY:(int)offsetY;
+ (NSString *) getTimeStr;

+ (NSString *)encodeToBase64String:(UIImage *)image;
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;
+ (NSMutableDictionary *) putTwoArraysIntoDict:(NSArray *)key andData:(NSArray *)data;

//server info
extern NSString * const SERVER_ADDRESS;

//app type 0 = teacher(17+) , 1 = student (4+)
extern const int APP_TYPE;

extern const int R_LENGTH;
extern const int MIN_FRAME_LENGTH;
extern const int MAX_TF_CHAR;
extern const int MAX_TF_WIDTH;
extern const int MAX_TF_HEIGHT;
extern const int MIN_TF_WIDTH;
extern const int DEFAULT_TF_HEIGHT;
extern const int DEFAULT_TF_WIDTH;
extern const int KEYBOARD_MEET_SCROLL_Y;
extern const int MAX_OBJECT_IN_NOTE;

extern const int TOOLBAR_HEIGHT;

@end