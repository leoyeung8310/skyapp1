//
//  DragLabel.h
//  Skyapp
//
//  Created by Leo Yeung on 30/6/14.
//
//

#import <UIKit/UIKit.h>

@interface DragView : UIImageView <UIGestureRecognizerDelegate>
{
    //Ready for future development
    CGFloat tx; // x translation
    CGFloat ty; // y translation
    CGFloat scale; // zoom scale
    CGFloat theta; // rotation angle
    
    //float minScale;
    //float maxScale;
    
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
    
    //for icons
    bool isIcon;
    NSString * iconStatus;
}

- (id) initWithImage:(UIImage *)image andLink:(NSString*)myLink andTitle:(NSString*)myTitle offsetH:(int)myH andIconStatus:(NSString*)myIconStatus andIsIcon:(bool)myIsIcon;
- (id) initWithImage:(UIImage *)image andFrame:(CGRect)rect andBounds:(CGRect)myBounds andSCALE:(CGFloat)myScale andTHETA:(CGFloat)myTheta andLink:(NSString*)myLink andTitle:(NSString*)myTitle andAnsStatus:(NSString*)myAnsStatus andIsAns:(bool)myIsAns andIconStatus:(NSString*)myIconStatus andIsIcon:(bool)myIsIcon;

- (NSString *) getLINK;
- (NSString *) getTITLE;
- (CGFloat) getSCALE;
- (CGFloat) getTHETA;
- (void) setTHETA:(CGFloat) myTheta;

- (void) refreshBorder;
- (void) restoreOriginal;


//method for ans box
- (void) handleShowAns;
- (void) handleHideAns;
- (NSString *) getANSSTATUS;
- (void) setANSSTATUS:(NSString *)myStatus;
- (bool) getIsAns;
- (void) setISAns:(bool)myIsAns;

//method for icons
- (bool) getIsIcon;
- (void) setIsIcon:(bool)myIsIcon;
- (NSString *) getIconStatus;
- (void) setIconStatus:(NSString *)myIconStatus;

@end