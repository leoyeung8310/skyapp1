//
//  DragTextField.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 4/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragTextField: UITextField <UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    //Ready for future development
    CGFloat tx; // x translation
    CGFloat ty; // y translation
    CGFloat scale; // zoom scale
    CGFloat theta; // rotation angle
    
    NSMutableAttributedString *myAttributedText;
    
    //status for drag and menu
    NSString * status;
    NSString * link; //related to URL
    
    //status for ans box
    NSString * ansText;
    NSString * ansStatus;
    NSString * title; // related to tmpAns

    //gesture
    UIPanGestureRecognizer *pan;
    UITapGestureRecognizer *singletapGesture;
    UITapGestureRecognizer *doubletapGesture;
    UILongPressGestureRecognizer *longPressGesture;
}

- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle offsetH:(int)myH;
- (id)initWithFrame:(CGRect)frame inputStr:(NSString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta andAnsText:(NSString *)myAnsText andAnsStatus:(NSString *)myAnsStatus;

- (NSString *) getLINK;
- (NSString *) getTITLE;
- (CGFloat) getSCALE;
- (CGFloat) getTHETA;
- (NSString *) getSTR;
- (NSString *) getSTATUS;
- (NSString *) getANSSTATUS;
- (NSString *) getANSTEXT;
- (void) setANSSTATUS :(NSString *)myStatus;
- (void) setTITLE :(NSString *)myAnswer;

//for everytime refresh
- (void) toLayerTop;

- (void) refreshBorder;
- (void) restoreOriginal;

//method for ans box
- (void) handleShowAns;
- (void) handleHideAns;
- (void) handleWaitAns;
- (void) handleShowCorrectAns;

//highlight wrong or empty ans
- (void) highlightBox;
- (void) dehighlightBox;

@end
