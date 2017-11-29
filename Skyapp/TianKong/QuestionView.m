//
//  QuestionView.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 18/12/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import "QuestionView.h"
#import "DragQuestionLine.h"
#import "MySingleton.h"

@implementation QuestionView

- (id)initWithFrame:(CGRect)frame withScrollView:(UIScrollView *)sv
{
    self = [super initWithFrame:frame];
    if (self) {
        scrollView = sv;
        
        // Initialization code
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        
        self.backgroundColor = [UIColor colorWithRed:(220.0f/255.0f) green:(220.0f/255.0f) blue:(220.0f/255.0f) alpha:0.5f];
        
        singletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
        singletapGesture.numberOfTapsRequired = 1;
        self.gestureRecognizers = @[singletapGesture];
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;

    }
    return self;
}

//Gesture for tab, shows menu
- (void)handleSingleTapGesture:(UITapGestureRecognizer*)tapPress {
    if (tapPress.state == UIGestureRecognizerStateEnded) {
        bool letScrollViewScrollAgain = true;
        CGPoint touchPoint = [tapPress locationInView:self];
        //NSLog(@"QuestionView tapped");
        for (UIView *subview in self.subviews){
            if([subview isKindOfClass:[DragQuestionLine class]]){
                DragQuestionLine * obj = (DragQuestionLine *) subview;
                if (CGRectContainsPoint(obj.frame,touchPoint)){
                    //---if CGRectContainsPoint()
                    //NSLog(@"touch question line");
                    letScrollViewScrollAgain=false;
                }else{
                    //---else
                    [obj setNormal];
                    [obj refreshView];
                }
            }
        }
        if (letScrollViewScrollAgain){
            scrollView.scrollEnabled = true;
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
