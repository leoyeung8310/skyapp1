//
//  DragQuestionLine.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 17/12/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragQuestionLine : UIView <UIGestureRecognizerDelegate>
{
    NSString * status;
    
    UIScrollView *scrollView;
    CAShapeLayer *onSelectedline;
    CAShapeLayer *notSelectedline;
    
    CAShapeLayer * dashBorder;
    
    //gesture
    UIPanGestureRecognizer *pan;
    UITapGestureRecognizer *singletapGesture;
    UITapGestureRecognizer *doubletapGesture;
    UILongPressGestureRecognizer *longPressGesture;
}

- (id)initWithY:(float)y andWidth:(float)width andScrollView:(UIScrollView *)sv;
- (id)initWithMyFrame:(CGRect)rect andScrollView:(UIScrollView *)sv;
- (void) setNormal;
- (void) refreshView;
@end
