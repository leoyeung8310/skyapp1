//
//  DragQuestionLine.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 17/12/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import "DragQuestionLine.h"
#import "MySingleton.h"

const int CONTROL_HEIGHT = 15;

@implementation DragQuestionLine

- (id)initWithY:(float)y andWidth:(float)width andScrollView:(UIScrollView *)sv;
{
    // Initialize and set as touchable
    if (!(self = [super init])) return self;

    scrollView = sv;

    self.frame = CGRectMake(0, y, width, CONTROL_HEIGHT);

    //gesture setup
    [self viewDefaultSetting];
    
    return self;
}

- (id)initWithMyFrame:(CGRect)rect andScrollView:(UIScrollView *)sv{
    // Initialize and set as touchable
    if (!(self = [super init])) return self;
    
    scrollView = sv;
    
    self.frame = rect;
    
    //gesture setup
    [self viewDefaultSetting];
    
    return self;
}

- (void) viewDefaultSetting{
    self.backgroundColor = [UIColor colorWithRed:(250.0f/255.0f) green:(250.0f/255.0f) blue:(250.0f/255.0f) alpha:0.001f];
    
    onSelectedline = [CAShapeLayer layer];
    UIBezierPath *onSelectedlinePath=[UIBezierPath bezierPath];
    [onSelectedlinePath moveToPoint:CGPointMake(0, 0+CONTROL_HEIGHT/2)];
    [onSelectedlinePath addLineToPoint:CGPointMake(0+self.frame.size.width, 0+CONTROL_HEIGHT/2)];
    onSelectedline.lineWidth = 1.0;
    onSelectedline.path=onSelectedlinePath.CGPath;
    onSelectedline.strokeColor = [UIColor darkGrayColor].CGColor;
    [[self layer] addSublayer:onSelectedline];
    
    notSelectedline = [CAShapeLayer layer];
    UIBezierPath *notSelectedlinePath=[UIBezierPath bezierPath];
    [notSelectedlinePath moveToPoint:CGPointMake(0, 0+CONTROL_HEIGHT/2)];
    [notSelectedlinePath addLineToPoint:CGPointMake(0+self.frame.size.width, 0+CONTROL_HEIGHT/2)];
    notSelectedline.lineWidth = 1.0;
    notSelectedline.path=notSelectedlinePath.CGPath;
    notSelectedline.strokeColor = [UIColor redColor].CGColor;
    [[self layer] addSublayer:notSelectedline];
    
    self.userInteractionEnabled = YES;
    
    //init selecting dash border
    dashBorder = [CAShapeLayer layer];
    dashBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    dashBorder.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    dashBorder.fillColor = nil;
    dashBorder.lineDashPattern = @[@4, @2];
    dashBorder.frame = self.bounds;
    
    // Add gesture recognizer suite
    MySingleton* singleton = [MySingleton getInstance];
    bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
    
    if (isTeacher){
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        singletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
        singletapGesture.numberOfTapsRequired = 1;
        doubletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        doubletapGesture.numberOfTapsRequired = 2;
        longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        self.gestureRecognizers = @[pan, singletapGesture, doubletapGesture, longPressGesture];
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    }

    [self.layer addSublayer:dashBorder];
    
    //init
    status = @"normal";
    
    [self refreshView];
    
}

- (void) setNormal{
    status = @"normal";
}

- (void) refreshView{
    if ([status  isEqual: @"normal"]){
        onSelectedline.hidden=false;
        notSelectedline.hidden=true;
        dashBorder.hidden=true;
    }else if ([status  isEqual: @"readyForDrag"]){
        onSelectedline.hidden=true;
        notSelectedline.hidden=false;
        dashBorder.hidden=false;
    }else if ([status  isEqual: @"inMenu"]){
        onSelectedline.hidden=true;
        notSelectedline.hidden=false;
        dashBorder.hidden=false;
    }
}


//Gesture for drag
- (void) handlePan: (UIPanGestureRecognizer *) recognizer
{
    //NSLog (@"handlePan = %@", status );
    if ([status isEqual: @"readyForDrag"]){
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
        
        CGPoint translation = [recognizer translationInView:self.superview];
        CGPoint newPT = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        
        //only move if center does not exceed containView
        if (CGRectContainsPoint(self.superview.frame, newPT)){
            float newY = recognizer.view.center.y + translation.y;
            if (newY > 50 && newY < (self.superview.frame.size.height-50)){
                recognizer.view.center = CGPointMake(recognizer.view.center.x, newY);
                
                [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
            }
        }
        
        //[self performSelector:@selector(noticeDragging) withObject:nil afterDelay:0.001];
        
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            NSLog(@"End Pan");
            //[self restoreOriginal];
            //[self performSelector:@selector(cancelAllViewSelections) withObject:nil];
        }
    }
}

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
            
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
            scrollView.scrollEnabled=NO;
            
            status = @"readyForDrag";
            [self refreshView];
        }
    }
}

-(void) toLayerTop
{
    [self.superview bringSubviewToFront:self];
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer*)tapPress {
    if (tapPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"double Press  Ended .................status = %@", status);
        [self openMenu];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)longPress {
    if (longPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long press Ended .................status = %@", status);
        [self openMenu];
    }
}

- (void) openMenu{
    MySingleton* singleton = [MySingleton getInstance];
    
    NSString* deleteText = NSLocalizedStringFromTableInBundle(@"deleteText", nil, singleton.globalLocaleBundle, nil);
    
    if ([status isEqual: @"normal"] || [status isEqual: @"readyForDrag"]){
        //if it is originally in readyForDrag
        //[self performSelector:@selector(cancelAllViewSelections) withObject:nil];   //disable control buttons
        
        status = @"inMenu";
        [self refreshView];
        
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        
        //delete
        UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:deleteText action:@selector(delete)];
        [options addObject:item4];
        [menu setMenuItems:options];
        
        //if menu not yet appears
        if ([self canBecomeFirstResponder]){
            [menu setTargetRect:self.frame inView:self.superview];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}

-(void) delete
{
    NSLog(@"delete");
    //self cancelAllViewSelections];
    self.hidden = YES;
    //[self performSelector:@selector(noticeRemove) withObject:nil afterDelay:0.001];
}

//For share menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(delete) == action){
        result = YES;
    }
    return result;
}


@end
