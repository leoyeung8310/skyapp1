//
//  DragLabel.h
//  Skyapp
//
//  Created by Leo Yeung on 30/6/14.
//
//

#import <UIKit/UIKit.h>

@interface DragLabel : UILabel <UIGestureRecognizerDelegate>
{
    //Ready for future development
    CGFloat tx; // x translation
    CGFloat ty; // y translation
    CGFloat scale; // zoom scale
    CGFloat theta; // rotation angle
    
    NSMutableAttributedString *myAttributedText;
    
    //status for ans
    bool isAns;
    NSString * ansStatus;
    
    //status for drag and menu
    NSString * status;
    NSString * link; //related to URL
    NSString * title; // related to URL
    
    CAShapeLayer * dashBorder;
    CALayer * coverLayer;
    CAShapeLayer * redLineBorder;
    
    bool isBookMark;
}

- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle isBookMark:(bool)myIsBookMark offsetH:(int)myH;
- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta isBookMark:(bool)myIsBookMark andAnsStatus:(NSString*)myAnsStatus andIsAns:(bool)myIsAns;
- (void)updateText:(NSAttributedString *)myStr;

- (NSString *) getLINK;
- (NSString *) getTITLE;
- (CGFloat) getSCALE;
- (CGFloat) getTHETA;
- (NSAttributedString *) getAttStr;
- (bool) getBOOKMARK;

- (void) refreshFrame;
- (void) refreshBorder;
- (void) restoreOriginal;

//method for ans box
- (void) handleShowAns;
- (void) handleHideAns;
- (NSString *) getANSSTATUS;
- (void) setANSSTATUS:(NSString *)myStatus;
- (bool) getIsAns;
- (void) setISAns:(bool)myIsAns;

@end



