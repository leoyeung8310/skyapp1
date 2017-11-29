//
//  DragLabel.m
//  skyapp
//
//  Created by Leo Yeung on 30/6/14.
//
//

#import <UIKit/UIKit.h>
#import "DragLabel.h"
#import "UIView-Transform.h"
#import "MySingleton.h"

const int MAX_LABEL_WIDTH = 390;

@implementation DragLabel

- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andLink:(NSString*)myLink andTitle:(NSString*)myTitle isBookMark:(bool)myIsBookMark offsetH:(int)myH;
{
    //min size
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        //bookmark
        isBookMark = myIsBookMark;
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.attributedText = myStr;
        
        [self refreshFrame];
        
        //increase y by scrollview offset
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y+myH, self.frame.size.width, self.frame.size.height);
        
        //init
        isAns = false;
        ansStatus = @"showAns";
        
        MySingleton* singleton = [MySingleton getInstance];
        bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
        bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
        if (isPre || isPost){
            ansStatus = @"studentInput";
        }
        
        [self viewDefaultSetting];
        
        //testing
        [self showDetail];
        
        return self;
        
    }
    return self;

}

- (id)initWithFrame:(CGRect)frame inputStr:(NSAttributedString *)myStr andFrame:(CGRect)rect andBounds:(CGRect)myBounds andLink:(NSString*)myLink andTitle:(NSString*)myTitle andScale:(CGFloat)myScale andTheta:(CGFloat)myTheta isBookMark:(bool)myIsBookMark andAnsStatus:(NSString*)myAnsStatus andIsAns:(bool)myIsAns
{
    self = [super initWithFrame:myBounds];
    //self = [super initWithFrame:rect];
    
    if (self) {
        //setup textLabel
        title = [[NSString alloc] initWithFormat:@"%@", myTitle];
        link = [[NSString alloc] initWithFormat:@"%@", myLink];
        
        //ans info
        ansStatus = myAnsStatus;
        isAns = myIsAns;
        
        //bookmark
        isBookMark = myIsBookMark;
        
        // Reset geometry to identities
        self.transform = CGAffineTransformIdentity;
        tx = 0.0f; ty = 0.0f; scale = 1.0f;	theta = 0.0f;
        
        self.attributedText = myStr;
        
        // transform view to original place
        self.frame = CGRectMake(rect.origin.x, rect.origin.y, self.frame.size.width, self.frame.size.height);
        //self.frame = rect;
        
        //gesture setup
        [self viewDefaultSetting];
        
        //testing
        [self showDetail];
        
        return self;
    }
    return self;
}

- (void) refreshFrame{
    //min width and max width
    NSLog(@"refreshFrame - self.frame.size.width = %f", self.frame.size.width);
    [self sizeToFit];
    if (self.frame.size.width < MIN_FRAME_LENGTH){
        [self sizeToFitFixedWidth:MIN_FRAME_LENGTH];
    }else if (self.frame.size.width > MAX_LABEL_WIDTH){
        [self sizeToFitFixedWidth:MAX_LABEL_WIDTH];
    }else{
        [self sizeToFitFixedWidth:self.frame.size.width];
    }
}


- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    [self sizeToFit];
    
    //ensure the height is not too small
    if (self.frame.size.height <MIN_FRAME_LENGTH){
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, MIN_FRAME_LENGTH);
    }else{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, self.frame.size.height);
    }
}

- (void) viewDefaultSetting{
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    
    // Initialization code
    self.userInteractionEnabled = YES;
    
    // Add gesture recognizer suite
    MySingleton* singleton = [MySingleton getInstance];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    bool isStudentInput = [ansStatus  isEqual: @"studentInput"];
    bool isNoLink = [link  isEqual: @"noCallLink"];
    
    if ((isPre || isPost) && !isStudentInput && !isNoLink){
        UITapGestureRecognizer *singletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLinkForTeacherLink:)];
        self.gestureRecognizers = @[singletapGesture];
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    }else{
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        UITapGestureRecognizer *singletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTapGesture:)];
        singletapGesture.numberOfTapsRequired = 1;
        UITapGestureRecognizer *doubletapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
        doubletapGesture.numberOfTapsRequired = 2;
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        self.gestureRecognizers = @[pan, singletapGesture, doubletapGesture, longPressGesture];
        for (UIGestureRecognizer *recognizer in self.gestureRecognizers) recognizer.delegate = self;
    }
    //init selecting dash border
    dashBorder = [CAShapeLayer layer];
    dashBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    dashBorder.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    dashBorder.fillColor = nil;
    dashBorder.lineDashPattern = @[@4, @2];
    dashBorder.frame = self.bounds;
    
    //init red dash border
    redLineBorder = [CAShapeLayer layer];
    redLineBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    redLineBorder.strokeColor = [UIColor redColor].CGColor;
    redLineBorder.fillColor = nil;
    redLineBorder.lineDashPattern = @[@4, @2];
    redLineBorder.frame = self.bounds;
    
    //init coverLayer
    coverLayer = [CALayer layer];
    coverLayer.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0].CGColor;
    coverLayer.borderWidth = 2.0;
    coverLayer.cornerRadius = 8.0;
    coverLayer.frame = self.bounds;
    
    //init
    status = @"normal";
    [self.layer addSublayer:dashBorder];
    [self.layer addSublayer:redLineBorder];
    [self.layer addSublayer:coverLayer];
    [self refreshBorder];
}

- (NSString *) getLINK{
    return link;
}
- (NSString *) getTITLE{
    return title;
}

- (CGFloat) getSCALE{
    return scale;
}

- (CGFloat) getTHETA{
    return theta;
}

- (NSAttributedString *) getAttStr{
    return self.attributedText;
}
- (NSString *) getANSSTATUS{
    return ansStatus;
}

- (void) setANSSTATUS :(NSString *)myStatus{
    ansStatus = myStatus;
}

- (bool) getIsAns{
    return isAns;
}

- (void) setISAns : (bool)myIsAns{
    isAns = myIsAns;
}

- (bool) getBOOKMARK{
    return isBookMark;
}

- (void) changeBookMarkBGIfNeed{
    if (isBookMark){
        UIImage *img = [UIImage imageNamed:@"bookmark_half.png"];
        CGSize imgSize = self.frame.size;
        UIGraphicsBeginImageContext( imgSize );
        [img drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.backgroundColor = [UIColor colorWithPatternImage:newImage];
        
        //center text
        self.textAlignment = NSTextAlignmentCenter;
    }else{
        //left placed the text
        self.textAlignment = NSTextAlignmentNatural;
    }
}

- (void)updateText:(NSMutableAttributedString *)mutStr{
    self.attributedText = mutStr;
    self.userInteractionEnabled = YES;
}

-(void) restoreOriginal
{
    status = @"normal";
}

- (void) refreshBorder{
    //bookmark
    [self changeBookMarkBGIfNeed];
    
    //refresh border and cover frame size
    dashBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    dashBorder.frame = self.bounds;
    redLineBorder.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    redLineBorder.frame = self.bounds;
    coverLayer.frame = self.bounds;
    
    MySingleton* singleton = [MySingleton getInstance];
    bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
    bool isStudent = [singleton.globalUserType isEqual: @"student"];
    bool isNormal = [singleton.globalReceivedNoteStatus isEqual: @"normal"];
    bool isExercise = [singleton.globalReceivedNoteStatus isEqual: @"exercise"];
    bool isTest = [singleton.globalReceivedNoteStatus isEqual: @"test"];
    bool isCompetition = [singleton.globalReceivedNoteStatus isEqual: @"competition"];
    bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
    bool isAnswer = isAns;
    bool isShowingAnswer = [ansStatus isEqual: @"showAns"];
    bool isHidingAnswer = [ansStatus isEqual: @"hideAns"];
    bool isStudentInput = [ansStatus isEqual: @"studentInput"];
    bool isStatusNormal = [status isEqual: @"normal"];
    //bool isStatusInMenu = [status isEqual: @"inmenu"];
    bool isStatusReadyForDrag = [status isEqual: @"readyForDrag"];
    
    if (isTeacher && (isNormal || isExercise || isTest || isCompetition)){
        if(isAnswer){
            dashBorder.hidden = true;
            if(isShowingAnswer){
                coverLayer.hidden=true;
                redLineBorder.hidden=false;
            }else if (isHidingAnswer){
                if (isStatusReadyForDrag) {
                    coverLayer.hidden=true;
                    redLineBorder.hidden=false;
                }else{
                    coverLayer.hidden=false;
                    redLineBorder.hidden=true;
                }
            }
        }else{
            //same here
            redLineBorder.hidden=true;
            if(isStatusNormal){
                dashBorder.hidden = true;
            }else{
                dashBorder.hidden = false;
            }
            coverLayer.hidden=true;
        }
    }else if(isStudent && (isPre || isPost)){
        if (isStudentInput){
            //same here
            redLineBorder.hidden=true;
            if(isStatusNormal){
                dashBorder.hidden = true;
            }else{
                dashBorder.hidden = false;
            }
            coverLayer.hidden=true;
        }else{
            if (isAns){
                self.hidden=true;
            }else{
                self.hidden=false;
            }
            redLineBorder.hidden=true;
            dashBorder.hidden=true;
            coverLayer.hidden=true;
        }
    }else{
        //same here
        redLineBorder.hidden=true;
        if(isStatusNormal){
            dashBorder.hidden = true;
        }else{
            dashBorder.hidden = false;
        }
        coverLayer.hidden=true;
    }
}

//Gesture for drag
- (void) handleLinkForTeacherLink: (UITapGestureRecognizer*)tapPress
{
    NSLog(@"handleLinkForTeacherLink");
    if (tapPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"single Press Ended .................status = %@", status);
        [self openLink];
    }
}


//Gesture for drag
- (void) handlePan: (UIPanGestureRecognizer *) recognizer
{
    if ([status isEqual: @"readyForDrag"]){
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];

        CGPoint translation = [recognizer translationInView:self.superview];
        CGPoint newPT = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
        
        //only move if center does not exceed containView
        if (CGRectContainsPoint(self.superview.frame, newPT)){
            recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                                 recognizer.view.center.y + translation.y);
            
            [recognizer setTranslation:CGPointMake(0, 0) inView:self.superview];
        }
        
        [self performSelector:@selector(noticeDragging) withObject:nil afterDelay:0.001];
   
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            NSLog(@"End Pan");
        }
    }
}

//Gesture update
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

//Gesture for tab, shows menu
- (void)handleSingleTapGesture:(UITapGestureRecognizer*)tapPress {
    if (tapPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"single Press Ended .................status = %@", status);
        if ([status isEqual: @"normal"]){
            [self performSelector:@selector(noticeOnSelected) withObject:nil];
            [[UIMenuController sharedMenuController] setMenuVisible:NO animated:NO];
            status = @"readyForDrag";
            [self refreshBorder];
        }
    }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer*)tapPress {
    if (tapPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"double Press  Ended .................status = %@", status);
        [self showMenu];
    }
}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)longPress {
    if (longPress.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long press Ended .................status = %@", status);
        [self showMenu];
    }
}

- (void) showMenu{
    MySingleton* singleton = [MySingleton getInstance];
    bool isTeacher = [singleton.globalUserType isEqual: @"teacher"];
    bool isNormal = [singleton.globalReceivedNoteStatus isEqual: @"normal"];
    bool isExercise = [singleton.globalReceivedNoteStatus isEqual: @"exercise"];
    bool isTest = [singleton.globalReceivedNoteStatus isEqual: @"test"];
    bool isCompetition = [singleton.globalReceivedNoteStatus isEqual: @"competition"];
    
    NSString* editText = NSLocalizedStringFromTableInBundle(@"editText", nil, singleton.globalLocaleBundle, nil);
    NSString* linkText = NSLocalizedStringFromTableInBundle(@"linkText", nil, singleton.globalLocaleBundle, nil);
    NSString* topText = NSLocalizedStringFromTableInBundle(@"topText", nil, singleton.globalLocaleBundle, nil);
    NSString* upText = NSLocalizedStringFromTableInBundle(@"upText", nil, singleton.globalLocaleBundle, nil);
    NSString* downText = NSLocalizedStringFromTableInBundle(@"downText", nil, singleton.globalLocaleBundle, nil);
    NSString* bottomText = NSLocalizedStringFromTableInBundle(@"bottomText", nil, singleton.globalLocaleBundle, nil);
    NSString* deleteText = NSLocalizedStringFromTableInBundle(@"deleteText", nil, singleton.globalLocaleBundle, nil);
    
    //ans related text
    NSString* isAnsText = NSLocalizedStringFromTableInBundle(@"isAns", nil, singleton.globalLocaleBundle, nil);
    NSString* isQusText = NSLocalizedStringFromTableInBundle(@"isQus", nil, singleton.globalLocaleBundle, nil);
    NSString* showAnsText = NSLocalizedStringFromTableInBundle(@"showAns", nil, singleton.globalLocaleBundle, nil);
    NSString* hideAnsText = NSLocalizedStringFromTableInBundle(@"hideAns", nil, singleton.globalLocaleBundle, nil);
    
    if ([status isEqual: @"normal"] || [status isEqual: @"readyForDrag"]){
        //if it is originally in readyForDrag
        [self performSelector:@selector(cancelAllViewSelections) withObject:nil];
        
        status = @"inMenu";
        [self refreshBorder];
        
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        
        //answer identification
        UIMenuItem *itemIsAns = [[UIMenuItem alloc] initWithTitle:isAnsText action:@selector(toAns)];
        UIMenuItem *itemIsQus = [[UIMenuItem alloc] initWithTitle:isQusText action:@selector(toQus)];
        UIMenuItem *itemShowAns = [[UIMenuItem alloc] initWithTitle:showAnsText action:@selector(handleShowAns)];
        UIMenuItem *itemHideAns = [[UIMenuItem alloc] initWithTitle:hideAnsText action:@selector(handleHideAns)];
        
        if (isTeacher && (isNormal || isExercise || isTest || isCompetition)){
            //teacher
            if (isAns){
                [options addObject:itemIsQus];
                if ([ansStatus  isEqual: @"hideAns"]){
                    [options addObject:itemShowAns];
                }else{
                    [options addObject:itemHideAns];
                }
            }else{
                [options addObject:itemIsAns];
            }
        }
        
        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:editText action:@selector(edit)];
        [options addObject:item1];
        UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:linkText action:@selector(openLink)];
        if (![link  isEqual: @"noCallLink"])
            [options addObject:item2];
        
        //layering
        UIMenuItem *itemLayerTop = [[UIMenuItem alloc] initWithTitle:topText action:@selector(toLayerTop)];
        UIMenuItem *itemLayerUp = [[UIMenuItem alloc] initWithTitle:upText action:@selector(toLayerUp)];
        UIMenuItem *itemLayerDown = [[UIMenuItem alloc] initWithTitle:downText action:@selector(toLayerDown)];
        UIMenuItem *itemLayerBottom = [[UIMenuItem alloc] initWithTitle:bottomText action:@selector(toLayerBottom)];
        [options addObject:itemLayerTop];
        [options addObject:itemLayerUp];
        [options addObject:itemLayerDown];
        [options addObject:itemLayerBottom];
        
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

//For share menu
- (BOOL)canBecomeFirstResponder {
    return YES;
}

//For share menu
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL result = NO;
    if(@selector(edit) == action || @selector(delete) == action || @selector(openLink) == action || @selector(toLayerTop) == action || @selector(toLayerUp) == action || @selector(toLayerDown) == action || @selector(toLayerBottom) == action || @selector(toAns) == action || @selector(toQus) == action || @selector(handleShowAns) == action || @selector(handleHideAns) == action) {
        result = YES;
    }
    return result;
}


//For share menu - it is called when the menu is open.
- (BOOL)becomeFirstResponder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignFirstResponder) name:UIMenuControllerDidHideMenuNotification object:nil];
    
    return [super becomeFirstResponder];
}

//For share menu - it is called when the menu is closed.
- (BOOL)resignFirstResponder
{
    NSLog(@"resignFirstResponder");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerDidHideMenuNotification object:nil];
    // custom cleanup code here (e.g. deselection)
    if ([status isEqual: @"inMenu"]){
        [self restoreOriginal];
    }
    return [super resignFirstResponder];
}

-(void) edit
{
    NSLog(@"edit");
    [self restoreOriginal];
    [self cancelAllViewSelections];
    [self performSelector:@selector(callEditTextViewController) withObject:self afterDelay:0.001];
}


-(void) openLink
{
    //[self.delegate callPopOverWebViewControllerByDragLabel:self];
    [self restoreOriginal];
    [self cancelAllViewSelections];
    [self performSelector:@selector(callWebViewController) withObject:self afterDelay:0.001];
    
}

-(void) toLayerTop
{
    [self.superview bringSubviewToFront:self];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) toLayerUp
{
    [self.superview insertSubview:self atIndex:[self.superview.subviews indexOfObject:self]+1];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) toLayerDown
{
    [self.superview insertSubview:self atIndex:[self.superview.subviews indexOfObject:self]-1];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) toLayerBottom
{
    [self.superview sendSubviewToBack:self];
    [self restoreOriginal];
    [self cancelAllViewSelections];
}

-(void) delete
{
    NSLog(@"delete");
    [self cancelAllViewSelections];
    self.hidden = YES;
    [self performSelector:@selector(noticeRemove) withObject:nil afterDelay:0.001];
}

-(void) toAns{
    isAns = true;
    [self restoreOriginal];
    [self cancelAllViewSelections];
    [self performSelector:@selector(refreshNoteButtons) withObject:nil afterDelay:0.001];
}

-(void) toQus{
    isAns = false;
    [self restoreOriginal];
    [self cancelAllViewSelections];
    [self performSelector:@selector(refreshNoteButtons) withObject:nil afterDelay:0.001];
}

-(void) handleShowAns
{
    if (isAns){
        ansStatus = @"showAns";
        [self restoreOriginal];
        [self cancelAllViewSelections];
    }
}

-(void) handleHideAns
{
    if (isAns){
        ansStatus = @"hideAns";
        [self restoreOriginal];
        [self cancelAllViewSelections];
    }
}

//for testing
-(void) showDetail{
    NSLog(@"My view frame: %@", NSStringFromCGRect(self.frame));
    NSLog(@"My view bounds: %@", NSStringFromCGRect(self.bounds));
}

//post notifications
-(void)callEditTextViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callEditTextViewController"   //callEditTextViewController
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeRemove{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewRemoved"   //ViewRemoved
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeOnSelected{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeOnSelectedFromObj"    //ReadyForResize
                                                        object:self
                                                      userInfo:nil];
}

-(void)noticeDragging{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"noticeDraggingFromObj" //RefreshControlBtnPosition
                                                        object:self
                                                      userInfo:nil];
}

-(void)cancelAllViewSelections{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelAllViewSelections" //NotTouched
                                                        object:self
                                                      userInfo:nil];
}

-(void)callWebViewController{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callWebViewController" //NotTouched
                                                        object:self
                                                      userInfo:nil];
}

-(void)refreshNoteButtons{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshNoteButtons" //NotTouched
                                                        object:self
                                                      userInfo:nil];
}



@end
