//
//  DragTextField.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 4/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragTextField.h"
#import "UIView-Transform.h"
#import "MySingleton.h"

const int KEYBOARD_Y_POS = 250;
const int TF_SUGGESTED_POS_BY_KEYBOARD = 200;

@implementation DragTextField

- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle offsetH:(int)myH
{
    //min size
    self = [super initWithFrame:frame];
    
    if (self) {
        //reset share menu
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        [menu setMenuItems:options];
        
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.text = myStr;
        
        //increase y by scrollview offset
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y+myH, self.frame.size.width, self.frame.size.height);

        //testing
        [self showDetail];
        
        //init
        ansText = @"";
        ansStatus = @"showAns";
        
        [self viewDefaultSetting];
    
        return self;
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta andAnsText:(NSString *)myAnsText andAnsStatus:(NSString *)myAnsStatus
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //reset share menu
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        [menu setMenuItems:options];
        
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.text = myStr;

        //testing
        [self showDetail];
        
        //answBox [testing]
        ansText = [[NSString alloc] initWithFormat:@"%@", myAnsText];
        ansStatus = [[NSString alloc] initWithFormat:@"%@", myAnsStatus];
        
        [self viewDefaultSetting];
        
        //if answer is numerical, change keyboard to decimal
        NSCharacterSet *numericOnly = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:ansText];
        
        if ([numericOnly isSupersetOfSet: myStringSet]){
            //String entirely contains decimal numbers only.
            self.keyboardType = UIKeyboardTypeDecimalPad;
        }
        return self;
    }
    return self;
}

- (void) viewDefaultSetting{
    //keyboard init
    self.delegate = self;
    
    //TextField Setting here
    self.borderStyle = UITextBorderStyleRoundedRect;
    self.font = [UIFont systemFontOfSize:14];//**
    self.adjustsFontSizeToFitWidth = false;//**
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeyDone;
    self.clearButtonMode = UITextFieldViewModeNever;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textAlignment = NSTextAlignmentCenter;
    
    //change border color
    self.layer.cornerRadius=8.0f;
    self.layer.masksToBounds=YES;
    self.layer.borderColor=[[UIColor blackColor]CGColor];
    self.layer.borderWidth= 1.0f;
    
    // Initialization code
    self.userInteractionEnabled = YES;
    
    // Add gesture recognizer suite
    pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    singletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
    singletapGesture.numberOfTapsRequired = 1;
    doubletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubletapGesture.numberOfTapsRequired = 2;
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.gestureRecognizers = @[pan, singletapGesture, doubletapGesture, longPressGesture];
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    
    //init
    status = @"normal";
    [self offHighLight];
    [self refreshBorder];
    [self refreshPlaceHolder];
    
    //btn always on top
    [self toLayerTop];
    
    
}

//disable magnifying glass
-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    //Prevent zooming but not panning
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}


- (NSString *) getLINK{
    return link;
}
- (NSString *) getTITLE{
    return title;
}

- (CGFloat) getSCALE{
    return scale;
}

- (CGFloat) getTHETA{
    return theta;
}

- (NSString *) getSTR{
    return self.text;
}

- (NSString *) getSTATUS{
    return status;
}

- (NSString *) getANSSTATUS{
    return ansStatus;
}

- (void) setANSSTATUS :(NSString *)myStatus{
    ansStatus = myStatus;
}

- (void) setSTATUS:(NSString *)myStatus{
    status = myStatus;
}

- (void) setTITLE :(NSString *)myAnswer{
    title = myAnswer;
}

- (NSString *) getANSTEXT{
    return ansText;
}

-(void) restoreOriginal
{
    [self offHighLight];
    status = @"normal";
}

- (void) refreshBorder{
    //refresh border
    /*
    dashBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    dashBorder.frame = self.bounds;
    */
}

- (void) onHighLight{
    [self refreshBorder];
    //on border
    //dashBorder.hidden = false;
}

- (void) offHighLight{
    //dashBorder.hidden = true;
}

//Gesture for drag
- (void) handlePan: (UIPanGestureRecognizer *) recognizer
{
    //NSLog (@"handlePan = %@", status );
    if ([status isEqual: @"readyForDrag"]){
        [self onHighLight];
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
        
        CGPoint translation = [recognizer translationInView:self.superview];
        CGPoint newPT = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        
        //only move if center does not exceed containView
        if (CGRectContainsPoint(self.superview.frame, newPT)){
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y + translation.y);
            
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        }
        
        [self performSelector:@selector(noticeDragging) withObject:nil afterDelay:0.001];
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            NSLog(@"End Pan");
            //[self restoreOriginal];
            //[self performSelector:@selector(cancelAllViewSelections) withObject:nil];
        }
    }
}

//Gesture update
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//Gesture for tab, shows menu
- (void)handleSingleTapGesture:(UITapGestureRecognizer*)tapPress {
    if (tapPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"single press Ended ................. status = %@", status);
        
        if ([status isEqual: @"normal"]){
            //btn always on top
            [self toLayerTop];
            
            MySingleton* singleton = [MySingleton getInstance];
            bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
            bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
            //bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
            bool isStudent = [singleton.globalUserType isEqual: @"student"];
            bool simExercise = [singleton.globalReceivedNoteStatus rangeOfString:@"exercise"].location != NSNotFound;
            bool simTest = [singleton.globalReceivedNoteStatus rangeOfString:@"test"].location != NSNotFound;
            bool simCompetition = [singleton.globalReceivedNoteStatus rangeOfString:@"competition"].location != NSNotFound;
            
            if (isStudent && isPre){
                //student
                [self cancelAllViewSelections];
                status = @"inMenu";
                [self becomeFirstResponder];
                
            }else if (isStudent && isPost){
                if (simExercise || simTest || simCompetition){
                    if ([ansStatus isEqual: @"waitAns"]){
                        [self handleShowCorrectAns];
                    }else if ([ansStatus isEqual: @"showCorrectAns"]){
                        [self handleWaitAns];
                    }
                }
            }else{
                //teacher
                [self performSelector:@selector(noticeOnSelected) withObject:nil];
                [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
                [self onHighLight];
                status = @"readyForDrag";
            }
        }
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer*)tapPress {
    MySingleton* singleton = [MySingleton getInstance];
    singleton.activeField = self;
    
    bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
    
    if (tapPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"double press Ended ................. status = %@", status);
        if (isTeacher && ([status isEqual: @"normal"] || [status isEqual: @"readyForDrag"])){
            //btn always on top
            [self toLayerTop];
            [self cancelAllViewSelections];
            status = @"inMenu";
            
            [self becomeFirstResponder];
        }
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)longPress {
    MySingleton* singleton = [MySingleton getInstance];
    singleton.activeField = self;
    
    bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
    
    if (longPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long press Ended .................status = %@", status);
        if (isTeacher && ([status isEqual: @"normal"] || [status isEqual: @"readyForDrag"])){
            //btn always on top
            [self toLayerTop];
            [self cancelAllViewSelections];
            status = @"inMenu";
            
            [self becomeFirstResponder];
        }
    }
}

- (void) showMenu {
    NSLog(@"showMenu - status = %@", status);
    MySingleton* singleton = [MySingleton getInstance];
    NSString* linkText = NSLocalizedStringFromTableInBundle(@"linkText", nil, singleton.globalLocaleBundle, nil);
    NSString* deleteText = NSLocalizedStringFromTableInBundle(@"deleteText", nil, singleton.globalLocaleBundle, nil);
    NSString* showAnsText = NSLocalizedStringFromTableInBundle(@"showAnsText", nil, singleton.globalLocaleBundle, nil);
    NSString* hideAnsText = NSLocalizedStringFromTableInBundle(@"hideAnsText", nil, singleton.globalLocaleBundle, nil);
    
    UIMenuController * menu = [UIMenuController sharedMenuController];
    NSMutableArray *options = nil;
    [menu setMenuItems:options];
    
    options = [NSMutableArray array];
    UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:linkText action:@selector(openLink)];
    if (![link  isEqual: @"noCallLink"])
        [options addObject:item2];
    
    //answer box
    UIMenuItem *itemShowAns = [[UIMenuItem alloc] initWithTitle:showAnsText action:@selector(handleShowAns)];
    UIMenuItem *itemHideAns = [[UIMenuItem alloc] initWithTitle:hideAnsText action:@selector(handleHideAns)];
    
    //NSLog(@"options count = %lu", (unsigned long)[options count]);
    if ([singleton.globalReceivedNoteStatus  isEqual: @"normal"] || [singleton.globalReceivedNoteStatus  isEqual: @"exercise"] || [singleton.globalReceivedNoteStatus  isEqual: @"test"] || [singleton.globalReceivedNoteStatus  isEqual: @"competition"]){
        if ([ansStatus isEqual: @"hideAns"]){
            [options addObject:itemShowAns];
        }
        if ([ansStatus isEqual: @"showAns"]){
            [options addObject:itemHideAns];
        }
        
        //delete
        UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:deleteText action:@selector(delete)];
        [options addObject:item4];
        
    }

    //NSLog(@"options count = %lu", (unsigned long)[options count]);
    [menu setMenuItems:options];
    
    //if menu not yet appears
    if ([self canBecomeFirstResponder]){
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}




//For share menu
/*
- (BOOL)canBecomeFirstResponder {
    return YES;
}
*/

//For share menu
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL result = NO;
    MySingleton* singleton = [MySingleton getInstance];
    bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
    if (isTeacher){
        if(@selector(delete) == action || @selector(openLink) == action || @selector(handleShowAns) == action || @selector(handleHideAns) == action) {
            result = YES;
        }
    }
    return result;
}


//For share menu - it is called when the menu is open.
- (BOOL)becomeFirstResponder
{
    NSLog(@"becomeFirstResponder");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    return [super becomeFirstResponder];
}

//For share menu - it is called when the menu is closed.
- (BOOL)resignFirstResponder
{
    //NSLog(@"resignFirstResponder status = %@",status);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    // custom cleanup code here (e.g. deselection)
    if ([status isEqual: @"inMenu"]){
        NSLog(@"resignFirstResponder - In menu");
        status = @"typing";
        //[self restoreOriginal];
    }else if ([status isEqual: @"typing"]){
        status = @"canClose";
        //reset share menu
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        [menu setMenuItems:options];
    }
    
    return [super resignFirstResponder];
}

-(void) openLink
{
    //[self.delegate callPopOverWebViewControllerByDragLabel:self];
    [self restoreOriginal];
    [self cancelAllViewSelections];
    
}

-(void) toLayerTop
{
    [self.superview bringSubviewToFront:self];
}

-(void) delete
{
    NSLog(@"delete");
    [self cancelAllViewSelections];
    self.hidden = YES;
    [self performSelector:@selector(noticeRemove) withObject:nil afterDelay:0.001];
}

//for testing
-(void) showDetail{
    NSLog(@"My DTF frame: %@", NSStringFromCGRect(self.frame));
    NSLog(@"My DTF bounds: %@", NSStringFromCGRect(self.bounds));
}


-(void)noticeRemove{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewRemoved"   //ViewRemoved
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeOnSelected{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeOnSelectedFromObj"    //ReadyForResize
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeDragging{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeDraggingFromObj" //RefreshControlBtnPosition
                                                        object:self
                                                      userInfo:nil];
}

-(void)cancelAllViewSelections{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelAllViewSelections" //NotTouched
                                                        object:self
                                                      userInfo:nil];
}

-(void)callStartTimerForHitAnsBox{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callStartTimerForHitAnsBox"
                                                        object:self
                                                      userInfo:nil];
}

//not work after becomefirstresponder
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldBeginEditing - status = %@", status);
    if ([status isEqual: @"inMenu"]){
        return YES;
    }
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
    //call timer
    if ([ansStatus  isEqual: @"waitAns"]){
        [self performSelector:@selector(callStartTimerForHitAnsBox) withObject:nil];
        //log
        MySingleton* singleton = [MySingleton getInstance];
        NSArray * key = @[@"text",@"objectLocationX",@"objectLocationY",@"objectLocationWidth",@"objectLocationHeight"];
        NSArray * data = @[
                           [NSString stringWithFormat:@"%@",textField.text],
                           [NSString stringWithFormat:@"%f",self.frame.origin.x],
                           [NSString stringWithFormat:@"%f",self.frame.origin.y],
                           [NSString stringWithFormat:@"%f",self.frame.size.width],
                           [NSString stringWithFormat:@"%f",self.frame.size.height]
                           ];
        //log
        NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
        [singleton.logCon setEventType:@"keyboardOnAnsBox" andEventAction:@"startTyping" andContent:content andTimeStamp:[MySingleton getTimeStr]];
        
    }else{
        if ([status isEqual: @"inMenu"]){
            [self showMenu];
        }
    }

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing = status = %@",status);
    
    if ([status isEqual: @"normal"] || [status isEqual: @"canClose"]){
        status = @"normal";
        NSLog(@"textFieldShouldEndEditing(END-YES) = status = %@ ",status);
        
        //log
        MySingleton* singleton = [MySingleton getInstance];
        NSArray * key = @[@"text",@"objectLocationX",@"objectLocationY",@"objectLocationWidth",@"objectLocationHeight"];
        NSArray * data = @[
                           [NSString stringWithFormat:@"%@",textField.text],
                           [NSString stringWithFormat:@"%f",self.frame.origin.x],
                           [NSString stringWithFormat:@"%f",self.frame.origin.y],
                           [NSString stringWithFormat:@"%f",self.frame.size.width],
                           [NSString stringWithFormat:@"%f",self.frame.size.height]
                           ];
        //log
        NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
        [singleton.logCon setEventType:@"keyboardOnAnsBox" andEventAction:@"endTyping" andContent:content andTimeStamp:[MySingleton getTimeStr]];
        return YES;
    }
    return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
    

}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"ansbox typing");
    [self showDetail];
    
    bool acceptChar = true;
    
    if(textField.text.length >= MAX_TF_CHAR && range.length == 0){
        acceptChar = false;
    }
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"currentText",@"typedCharacter",@"accept",@"objectLocationX",@"objectLocationY",@"objectLocationWidth",@"objectLocationHeight"];
    NSArray * data = @[
                       [NSString stringWithFormat:@"%@",textField.text],
                       [NSString stringWithFormat:@"%@",string],
                       [NSString stringWithFormat:@"%d",acceptChar],
                       [NSString stringWithFormat:@"%f",self.frame.origin.x],
                       [NSString stringWithFormat:@"%f",self.frame.origin.y],
                       [NSString stringWithFormat:@"%f",self.frame.size.width],
                       [NSString stringWithFormat:@"%f",self.frame.size.height]
                       ];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"keyboardOnAnsBox" andEventAction:@"type" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
    if (!acceptChar){
        return NO;
    }
    
    //for hideAns lock
    if ([ansStatus isEqual: @"hideAns"]){
        return NO;
    }
    if ([ansStatus isEqual: @"showAns"]){
        return YES;
    }

    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear");
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    status = @"canClose";
    [self endEditing:YES];
    [self resignFirstResponder];
    
    return YES;
}

//for ans box
- (void) refreshAnsBoxStatus{
    MySingleton* singleton = [MySingleton getInstance];
    bool isNormal = [singleton.globalReceivedNoteStatus isEqual: @"normal"];
    bool isExercise = [singleton.globalReceivedNoteStatus isEqual: @"exercise"];
    bool isTest = [singleton.globalReceivedNoteStatus isEqual: @"test"];
    bool isCompetition = [singleton.globalReceivedNoteStatus isEqual: @"competition"];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    
    if (isNormal || isExercise || isTest || isCompetition){
        //teacher
        if ([ansStatus isEqual: @"hideAns"] && [ansText isEqual:@""]){
            ansText = self.text;
            self.text = @"";
        }else if([ansStatus isEqual: @"showAns"] && [self.text isEqual:@""]){
            self.text = ansText;
            ansText = @"";
        }
    
    }else if (isPre || isPost){
        //student
        if([ansStatus isEqual: @"waitAns"]){
            self.textColor = [UIColor blackColor];
            self.text = title;
        }else if([ansStatus isEqual: @"showCorrectAns"]){
            title = self.text;
            self.textColor = [UIColor redColor];
            self.text = ansText;
        }
    }
}

- (void) refreshPlaceHolder{
    MySingleton* singleton = [MySingleton getInstance];
    //for hideAns lock
    if ([ansStatus isEqual: @"hideAns"]){
        NSString* lockedText = NSLocalizedStringFromTableInBundle(@"lockedText", nil, singleton.globalLocaleBundle, nil);
        self.placeholder = lockedText;
        
        //change placeholder color
        UIColor *placeHolderColor = [UIColor redColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
    }else if ([ansStatus isEqual: @"showAns"]){
        NSString* askInputText = NSLocalizedStringFromTableInBundle(@"askInputText", nil, singleton.globalLocaleBundle, nil);
        self.placeholder = askInputText;
        
        //change placeholder color
        UIColor *placeHolderColor = [UIColor lightGrayColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
    }else if ([ansStatus isEqual: @"waitAns"]){
        NSString* askInputText = NSLocalizedStringFromTableInBundle(@"askInputText", nil, singleton.globalLocaleBundle, nil);
        self.placeholder = askInputText;
        
        //change placeholder color
        UIColor *placeHolderColor = [UIColor lightGrayColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
    }else if ([ansStatus isEqual: @"showCorrectAns"]){
        NSString* askInputText = NSLocalizedStringFromTableInBundle(@"askInputText", nil, singleton.globalLocaleBundle, nil);
        self.placeholder = askInputText;
        
        //change placeholder color
        UIColor *placeHolderColor = [UIColor lightGrayColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: placeHolderColor}];
    }
}

-(void) handleShowAns
{
    ansStatus = @"showAns";
    [self refreshAnsBoxStatus];
    [self refreshPlaceHolder];
    [self endEditing:YES];
    [self resignFirstResponder];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) handleHideAns
{
    ansStatus = @"hideAns";
    [self refreshAnsBoxStatus];
    [self refreshPlaceHolder];
    [self endEditing:YES];
    [self resignFirstResponder];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) handleWaitAns
{
    NSLog(@"handleWaitAns");
    ansStatus = @"waitAns";
    [self refreshAnsBoxStatus];
    [self refreshPlaceHolder];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) handleShowCorrectAns
{
    NSLog(@"handleShowCorrectAns");
    ansStatus = @"showCorrectAns";
    [self refreshAnsBoxStatus];
    [self refreshPlaceHolder];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) highlightBox{
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor redColor] CGColor];
    self.clipsToBounds = YES;
}


-(void) dehighlightBox{
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.clipsToBounds = YES;
}


@end
