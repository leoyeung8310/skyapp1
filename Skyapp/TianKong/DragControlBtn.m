//
//  DragControlBtn.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 30/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "DragControlBtn.h"

@implementation DragControlBtn

- (id)initWithFrame:(CGRect)frame withType:(NSString *)myType
{
    self = [super initWithFrame:frame];
    type = myType;
    if (self) {
        int shiftPos = 24;//48
        int shiftLineWidth = 1;//2
        int totalImageLength = 40;///40
        
        UIImage *image;
        if ([type isEqual: @"topLeftBtn"]){
            subView = [[UIView alloc] initWithFrame:CGRectMake(-shiftPos,-shiftPos,totalImageLength,totalImageLength)];
            image = [UIImage imageNamed:@"left_top_ori.png"];
        }else if ([type isEqual: @"topRightBtn"]){
            subView = [[UIView alloc] initWithFrame:CGRectMake(-shiftLineWidth,-shiftLineWidth,totalImageLength,totalImageLength)];
            image = [UIImage imageNamed:@"right_top_ori.png"];
        }else if ([type isEqual: @"bottomLeftBtn"]){
            subView = [[UIView alloc] initWithFrame:CGRectMake(-shiftPos,-shiftPos,totalImageLength,totalImageLength)];
            image = [UIImage imageNamed:@"left_bottom_ori.png"];
        }else if ([type isEqual: @"bottomRightBtn"]){
            subView = [[UIView alloc] initWithFrame:CGRectMake(-shiftLineWidth,-shiftLineWidth,totalImageLength,totalImageLength)];
            image = [UIImage imageNamed:@"right_bottom_ori.png"];
        }
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = subView.bounds;
        [subView addSubview:imageView];
        [self addSubview:subView];

        //draggable
        self.userInteractionEnabled = true;
        
        [self viewDefaultSetting];
        
        [self showDetail];
        
        return self;
    }
    return self;
    
}


- (void) viewDefaultSetting{
    self.userInteractionEnabled = YES;
    
    // Add gesture recognizer suite
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.gestureRecognizers = @[pan];
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    
    [self showDetail];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch Ctrl Began");
    [self performSelector:@selector(noticeDraggingFromBtn) withObject:nil afterDelay:0.001];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    [self performSelector:@selector(noticeEndDragFromBtn) withObject:nil afterDelay:0.001];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
    [self performSelector:@selector(noticeEndDragFromBtn) withObject:nil afterDelay:0.001];
}

- (void) handlePan: (UIPanGestureRecognizer *) recognizer
{
    [self performSelector:@selector(noticeDraggingFromBtn) withObject:nil afterDelay:0.001];
    
    CGPoint translation = [recognizer translationInView:self.superview];
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);

    [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
    
    if (([recognizer state] == UIGestureRecognizerStateEnded) || ([recognizer state] == UIGestureRecognizerStateCancelled)) {
        NSLog(@"ctrl btn recognizer end ");
        [self performSelector:@selector(noticeEndDragFromBtn) withObject:nil afterDelay:0.001];
    }
    
    
    
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//for testing
-(void) showDetail{
    NSLog(@"My view frame: %@", NSStringFromCGRect(self.frame));
    NSLog(@"My view bounds: %@", NSStringFromCGRect(self.bounds));
}

- (void) changeToOrigin{
    UIImage *image;
    if ([type isEqual: @"topLeftBtn"] && imageView.image != [UIImage imageNamed:@"left_top_ori.png"]){
        image = [UIImage imageNamed:@"left_top_ori.png"];
        imageView.image = image;
    }else if ([type isEqual: @"topRightBtn"] && imageView.image != [UIImage imageNamed:@"right_top_ori.png"]){     //just use down instead of lock
        image = [UIImage imageNamed:@"right_top_ori.png"];
        imageView.image = image;
    }else if ([type isEqual: @"bottomLeftBtn"] && imageView.image != [UIImage imageNamed:@"left_bottom_ori.png"]){ //just use down instead of lock
        image = [UIImage imageNamed:@"left_bottom_ori.png"];
        imageView.image = image;
    }else if ([type isEqual: @"bottomRightBtn"] && imageView.image != [UIImage imageNamed:@"right_bottom_ori.png"]){
        image = [UIImage imageNamed:@"right_bottom_ori.png"];
        imageView.image = image;
    }
}

-(void) changeToDown{
    UIImage *image;
    if ([type isEqual: @"topLeftBtn"] && imageView.image != [UIImage imageNamed:@"left_top_down.png"]){
        image = [UIImage imageNamed:@"left_top_down.png"];
        imageView.image = image;
    }else if ([type isEqual: @"topRightBtn"] && imageView.image != [UIImage imageNamed:@"right_top_down.png"]){
        image = [UIImage imageNamed:@"right_top_down.png"];
        imageView.image = image;
    }else if ([type isEqual: @"bottomLeftBtn"] && imageView.image != [UIImage imageNamed:@"left_bottom_down.png"]){
        image = [UIImage imageNamed:@"left_bottom_down.png"];
        imageView.image = image;
    }else if ([type isEqual: @"bottomRightBtn"] && imageView.image != [UIImage imageNamed:@"right_bottom_down.png"]){
        image = [UIImage imageNamed:@"right_bottom_down.png"];
        imageView.image = image;
    }
}

- (void) changeToLock{
    UIImage *image;
    if ([type isEqual: @"topLeftBtn"] && imageView.image != [UIImage imageNamed:@"left_top_lock.png"]){
        image = [UIImage imageNamed:@"left_top_lock.png"];
        imageView.image = image;
    }else if ([type isEqual: @"topRightBtn"] && imageView.image != [UIImage imageNamed:@"right_top_down.png"]){     //just use down instead of lock
        image = [UIImage imageNamed:@"right_top_down.png"];
        imageView.image = image;
    }else if ([type isEqual: @"bottomLeftBtn"] && imageView.image != [UIImage imageNamed:@"left_bottom_down.png"]){ //just use down instead of lock
        image = [UIImage imageNamed:@"left_bottom_down.png"];
        imageView.image = image;
    }else if ([type isEqual: @"bottomRightBtn"] && imageView.image != [UIImage imageNamed:@"right_bottom_lock.png"]){
        image = [UIImage imageNamed:@"right_bottom_lock.png"];
        imageView.image = image;
    }
}

-(void)noticeDraggingFromBtn{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeDraggingFromBtn"
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeEndDragFromBtn{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeEndDragFromBtn"
                                                        object:self
                                                      userInfo:nil];
}


@end
