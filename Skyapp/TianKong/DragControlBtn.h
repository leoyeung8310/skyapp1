//
//  DragControlBtn.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 30/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragControlBtn : UIButton <UIGestureRecognizerDelegate>{
    UIView * subView;
    UIImageView * imageView;
    NSString * type;
}

- (id)initWithFrame:(CGRect)frame withType:(NSString *)type;
- (void) changeToOrigin;
- (void) changeToDown;
- (void) changeToLock;
@end
