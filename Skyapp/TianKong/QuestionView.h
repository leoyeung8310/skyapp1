//
//  QuestionView.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 18/12/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionView : UIView <UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer *singletapGesture;
    UIScrollView *scrollView;
}

- (id)initWithFrame:(CGRect)frame withScrollView:(UIScrollView *)sv;

@end
