//
//  DefineQuestionView.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 14/12/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionView.h"

@interface DefineQuestionView : UIView
{
    int offsetH;
    UIView *containerView;
    UIScrollView *scrollView;
    
    NSString * status;
    
    NSArray * uiBtnArr;
    UIBarButtonItem *addQuestionLineBtn;
    UIBarButtonItem *finishBtn;
    
    QuestionView *questionView;
    
    NSMutableArray * arrQL;
    
    NSString *qvString;
    NSData *qvData;
}

- (id) initWithFrame:(CGRect)frame offsetH:(int)myH setContainerView:(UIView *)cv setScrollView:(UIView *)sv;

@end
