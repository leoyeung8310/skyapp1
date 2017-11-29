//
//  DrawView.m
//  getituseit
//
//  Created by Leo Yeung on 6/8/14.
//
//

#import "DrawView.h"
#import "UIView-Transform.h"
#import "MySingleton.h"

#define BLACK_PEN_COLOR [UIColor colorWithRed:0.01f green:0.01f blue:0.01f alpha:1.0f]
#define RED_PEN_COLOR [UIColor colorWithRed:0.99f green:0.20f  blue:0.01f alpha:1.0f]
#define BLUE_PEN_COLOR [UIColor colorWithRed:0.01f green:0.01f  blue:0.80f alpha:1.0f]
#define ORANGE_PEN_COLOR [UIColor colorWithRed:0.99f green:0.60f  blue:0.01f alpha:1.0f]
#define YELLOW_PEN_COLOR [UIColor colorWithRed:0.99f green:0.99f  blue:0.20f alpha:1.0f]
#define GREEN_PEN_COLOR [UIColor colorWithRed:0.01f green:0.80f blue:0.01f alpha:1.0f]
#define PURPLE_PEN_COLOR [UIColor colorWithRed:0.20f green:0.20f blue:0.60f alpha:1.0f]
#define IS_IPAD	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

const int SCALE_MIN_VIEW = 100;

@implementation DrawView
//
- (id)initWithFrame:(CGRect)frame offsetH:(int)myH
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        strokes = [NSMutableArray array];
        touchPaths = [NSMutableDictionary dictionary];
        colorStrokes = [NSMutableArray array];
        colorTouchPaths = [NSMutableDictionary dictionary];
        didDraw = NO;
        offsetH = myH;
        
        //transparent background
        //self.alpha = myAlphaFloat;
        UIColor *transparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05f];
        self.backgroundColor = transparentColor;
        self.opaque = NO;
        
        //tool bar
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.barTintColor=[UIColor lightTextColor];
        //toolbar.layer.borderWidth = 3;
        //toolbar.layer.borderColor = [[UIColor blackColor] CGColor];
        toolbar.frame = CGRectMake(0, myH, self.frame.size.width, TOOLBAR_HEIGHT);
        
        UIBarButtonItem *f1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        blackBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"blackBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(blackAction)];
        [blackBtn setTintColor:BLACK_PEN_COLOR];
        redBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"redBtn"] style:UIBarButtonItemStylePlain  target:self action:@selector(redAction)];
        [redBtn setTintColor:RED_PEN_COLOR];
        blueBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"blueBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(blueAction)];
        [blueBtn setTintColor:BLUE_PEN_COLOR];
        orangeBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"orangeBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(orangeAction)];
        [orangeBtn setTintColor:ORANGE_PEN_COLOR];
        yellowBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"yellowBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(yellowAction)];
        [yellowBtn setTintColor:YELLOW_PEN_COLOR];
        greenBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"greenBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(greenAction)];
        [greenBtn setTintColor:GREEN_PEN_COLOR];
        purpleBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"purpleBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(purpleAction)];
        [purpleBtn setTintColor:PURPLE_PEN_COLOR];
        eraserBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"eraserBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(eraserAction)];
        finishBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"finishBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(finishAction)];
        uiBtnArr = @[blackBtn,redBtn,blueBtn,orangeBtn,yellowBtn,greenBtn,purpleBtn,eraserBtn,finishBtn];
        //UIBarButtonItem *f2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [toolbar setItems:[[NSArray alloc] initWithObjects:blackBtn,redBtn,blueBtn,orangeBtn,yellowBtn,greenBtn,purpleBtn,eraserBtn,f1,finishBtn, nil]];
        [self addSubview:toolbar];
        
        status = @"black";
        
        MySingleton* singleton = [MySingleton getInstance];
        bool isNormal = [singleton.globalReceivedNoteStatus isEqual: @"normal"];
        bool isExercise = [singleton.globalReceivedNoteStatus isEqual: @"exercise"];
        bool isTest = [singleton.globalReceivedNoteStatus isEqual: @"test"];
        bool isCompetition = [singleton.globalReceivedNoteStatus isEqual: @"competition"];
        //bool isPre = [singleton.globalReceivedNoteStatus rangeOfString:@"Pre"].location != NSNotFound;
        //bool isPost = [singleton.globalReceivedNoteStatus rangeOfString:@"Post"].location != NSNotFound;
        
        if (isNormal || isExercise || isTest || isCompetition){
            status = @"black";
        }else{
            status = @"blue";
        }
        [self refreshButtons];
    }
    return self;
}

- (void) checkIfNeededToRemoveAPath: (CGPoint)pt{
    for (int i = 0; i < [strokes count]; i++){
        UIBezierPath *path = (UIBezierPath *)strokes[i];
        //NSString * color = [NSString stringWithFormat:@"%@",colorStrokes[i]];
        bool continueCheck = true;
        for (float j = -10; j <+ 10 && continueCheck; j+=0.5){
            for (float k = -10; k <+ 10 && continueCheck; k+=0.5){
                //NSLog(@"x = %f, y = %f",pt.x+j, pt.y+k);
                CGPoint checkPt = CGPointMake(pt.x+j, pt.y+k);
                if ([path containsPoint:checkPt]) {
                    NSString *removedPathStr = [NSString stringWithFormat:@"%@",path];
                    
                    //remove path
                    [strokes removeObjectAtIndex:i];
                    [colorStrokes removeObjectAtIndex:i];
                    
                    continueCheck = false;
                    
                    //log
                    MySingleton* singleton = [MySingleton getInstance];
                    NSArray * dKey = @[];
                    NSArray * data = @[];
                    
                    dKey = @[@"pointX",@"pointY",@"path"];
                    data = @[
                             [NSString stringWithFormat:@"%f",checkPt.x+j],
                             [NSString stringWithFormat:@"%f",checkPt.y+k],
                             removedPathStr
                             ];
                    
                    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:dKey andData:data];
                    [singleton.logCon setEventType:@"drawView" andEventAction:@"removedPath" andContent:content andTimeStamp:[MySingleton getTimeStr]];

                }
            }
        }
    }
}

- (void) touchesBegan:(NSSet *) touches withEvent:(UIEvent *) event
{
    for (UITouch *touch in touches)
    {
        if([status  isEqual: @"eraser"]){
            CGPoint pt = [touch locationInView:self];
            [self checkIfNeededToRemoveAPath:pt];
            [self setNeedsDisplay];
        }else{
            NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
            CGPoint pt = [touch locationInView:self];
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            path.lineWidth = IS_IPAD? 3: 1;
            path.lineCapStyle = kCGLineCapRound;
            [path moveToPoint:pt];
            
            [touchPaths setObject:path forKey:key];
            [colorTouchPaths setObject:[NSString stringWithFormat:@"%@",status] forKey:key];
            
            //log
            MySingleton* singleton = [MySingleton getInstance];
            NSArray * dKey = @[];
            NSArray * data = @[];
            
            dKey = @[@"pointX",@"pointY"];
            data = @[
                     [NSString stringWithFormat:@"%f",pt.x],
                     [NSString stringWithFormat:@"%f",pt.y]
                     ];
            
            NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:dKey andData:data];
            [singleton.logCon setEventType:@"drawView" andEventAction:@"touchBegan" andContent:content andTimeStamp:[MySingleton getTimeStr]];
        }
    }
}

- (void) touchesMoved:(NSSet *) touches withEvent:(UIEvent *) event
{
    for (UITouch *touch in touches)
    {
        if([status  isEqual: @"eraser"]){
            CGPoint pt = [touch locationInView:self];
            [self checkIfNeededToRemoveAPath:pt];
            [self setNeedsDisplay];
        }else{
            NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
            UIBezierPath *path = [touchPaths objectForKey:key];
            
            //log
            //CGPoint currentPT = path.currentPoint;
            
            if (!path) break;
            
            CGPoint pt = [touch locationInView:self];
            [path addLineToPoint:pt];
            
            //log -- removed in 1.4
            /*
            MySingleton* singleton = [MySingleton getInstance];
            NSArray * dKey = @[];
            NSArray * data = @[];
            
            dKey = @[@"pointX",@"pointY",@"currentPointX",@"currentPointY"];
            data = @[
                     [NSString stringWithFormat:@"%f",pt.x],
                     [NSString stringWithFormat:@"%f",pt.y],
                     [NSString stringWithFormat:@"%f",currentPT.x],
                     [NSString stringWithFormat:@"%f",currentPT.y]
                     ];
            
            NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:dKey andData:data];
            [singleton.logCon setEventType:@"drawView" andEventAction:@"touchMoved" andContent:content andTimeStamp:[MySingleton getTimeStr]];
            */
        }
    }
    
    [self setNeedsDisplay];
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        if([status  isEqual: @"eraser"]){
            CGPoint pt = [touch locationInView:self];
            [self checkIfNeededToRemoveAPath:pt];
            [self setNeedsDisplay];
        }else{
            NSString *key = [NSString stringWithFormat:@"%d", (int) touch];
            UIBezierPath *path = [touchPaths objectForKey:key];

            //log
            CGPoint currentPT = path.currentPoint;
            
            if (path) {
                [strokes addObject:path];
                [colorStrokes addObject:[NSString stringWithFormat:@"%@",status]];
            }
            [touchPaths removeObjectForKey:key];
            [colorTouchPaths removeObjectForKey:key];
            
            //log
            MySingleton* singleton = [MySingleton getInstance];
            NSArray * dKey = @[];
            NSArray * data = @[];
            
            dKey = @[@"pointX",@"pointY",@"path",@"color"];
            data = @[
                     [NSString stringWithFormat:@"%f",currentPT.x],
                     [NSString stringWithFormat:@"%f",currentPT.y],
                     [NSString stringWithFormat:@"%@",path],
                     [NSString stringWithFormat:@"%@",status]
                     ];
            
            NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:dKey andData:data];
            [singleton.logCon setEventType:@"drawView" andEventAction:@"touchEnded" andContent:content andTimeStamp:[MySingleton getTimeStr]];
        }
    }
    
    [self setNeedsDisplay];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //(@"touchesCancelled");
	[self touchesEnded:touches withEvent:event];
}

- (void) drawRect:(CGRect)rect
{
    didDraw = NO;
    for (int i = 0; i < [strokes count]; i++){
        didDraw = YES;
        UIBezierPath *path = (UIBezierPath *)strokes[i];
        NSString * color = [NSString stringWithFormat:@"%@",colorStrokes[i]];
        if ([color isEqualToString: @"black"]){
            [BLACK_PEN_COLOR set];
        }else if ([color  isEqualToString: @"red"]){
            [RED_PEN_COLOR set];
        }else if ([color  isEqualToString: @"blue"]){
            [BLUE_PEN_COLOR set];
        }else if ([color  isEqualToString: @"orange"]){
            [ORANGE_PEN_COLOR set];
        }else if ([color  isEqualToString: @"yellow"]){
            [YELLOW_PEN_COLOR set];
        }else if ([color  isEqualToString: @"green"]){
            [GREEN_PEN_COLOR set];
        }else if ([color isEqualToString: @"purple"]){
            [PURPLE_PEN_COLOR set];
        }
        [path stroke];
    }
    
    for (UIBezierPath *path in [touchPaths allValues]){
        //NSLog(@"touchPaths status = %@",[pathStatus objectForKey:path]);
        if ([status isEqualToString: @"black"]){
            [[BLACK_PEN_COLOR colorWithAlphaComponent:0.5f] set];
        }else if ([status  isEqualToString: @"red"]){
            [[RED_PEN_COLOR colorWithAlphaComponent:0.5f] set];
        }else if ([status  isEqualToString: @"blue"]){
            [[BLUE_PEN_COLOR colorWithAlphaComponent:0.5f] set];
        }else if ([status  isEqualToString: @"orange"]){
            [[ORANGE_PEN_COLOR colorWithAlphaComponent:0.5f] set];
        }else if ([status  isEqualToString: @"yellow"]){
            [[YELLOW_PEN_COLOR colorWithAlphaComponent:0.5f] set];
        }else if ([status  isEqualToString: @"green"]){
            [[GREEN_PEN_COLOR colorWithAlphaComponent:0.5f] set];
        }else if ([status isEqualToString: @"purple"]){
            [[PURPLE_PEN_COLOR colorWithAlphaComponent:0.5f] set];
        }
        [path stroke];
    }
}

- (void)refreshButtons{
    for (int i = 0; i < uiBtnArr.count; i++){
        UIBarButtonItem * myBtn = (UIBarButtonItem * )uiBtnArr[i];
        myBtn.enabled=true;
    }
    
    if ([status  isEqual: @"black"]){
        blackBtn.enabled = false;
    }else if ([status  isEqual: @"red"]){
        redBtn.enabled = false;
    }else if ([status  isEqual: @"blue"]){
        blueBtn.enabled = false;
    }else if ([status  isEqual: @"orange"]){
        orangeBtn.enabled = false;
    }else if ([status  isEqual: @"yellow"]){
        yellowBtn.enabled = false;
    }else if ([status  isEqual: @"green"]){
        greenBtn.enabled = false;
    }else if ([status  isEqual: @"purple"]){
        purpleBtn.enabled = false;
    }else if ([status  isEqual: @"eraser"]){
        eraserBtn.enabled = false;
    }else if ([status  isEqual: @"finish"]){
        finishBtn.enabled = false;
    }
}

- (void)blackAction {
    status = @"black";
    [self refreshButtons];
}

- (void)redAction {
    status = @"red";
    [self refreshButtons];
}

- (void)blueAction {
    status = @"blue";
    [self refreshButtons];
}

- (void)orangeAction {
    status = @"orange";
    [self refreshButtons];
}

- (void)yellowAction {
    status = @"yellow";
    [self refreshButtons];
}

- (void)greenAction {
    status = @"green";
    [self refreshButtons];
}

- (void)purpleAction {
    status = @"purple";
    [self refreshButtons];
}

- (void)eraserAction {
    status = @"eraser";
    [self refreshButtons];
}

- (void)finishAction {
    MySingleton* singleton = [MySingleton getInstance];

    //real transparent
    UIColor *realTransparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.backgroundColor = realTransparentColor;
    self.opaque = NO;
    
    //NSLog( @"%@", strokes );
    //NSLog (@"Number of Objects in Array %i", strokes.count);

    //check if user did draw something
    if (didDraw){
        //sizeToFit by myself
        
        int newMinX = 0; int newMinY = 0; int newMaxX = 0; int newMaxY =0;
        int minX = 10000; int minY = 10000; int maxX = 0; int maxY = 0;
        for (UIBezierPath *path in strokes){
            //NSLog(@"This path = %@",path);
            newMinX = CGRectGetMinX(path.bounds);
            if (newMinX > 10000)
                newMinX = 10000;
            newMinY = CGRectGetMinY(path.bounds);
            if (newMinY > 10000)
                newMinY = 10000;
            newMaxX = CGRectGetMaxX(path.bounds);
            if (newMaxX > 10000)
                newMaxX = 0;
            newMaxY = CGRectGetMaxY(path.bounds);
            if (newMaxY > 10000)
                newMaxY = 0;
            
            if (newMinX < minX)
                minX = newMinX;
            if (newMinY < minY)
                minY = newMinY;
            if (newMaxX > maxX)
                maxX = newMaxX;
            if (newMaxY > maxY)
                maxY = newMaxY;
        }
        minX = minX - 5;
        minY = minY - 5;
        maxX = maxX + 5;
        maxY = maxY + 5;
        
        if (maxX - minX < SCALE_MIN_VIEW){
            int difference = SCALE_MIN_VIEW - (maxX - minX);
            maxX = maxX + difference/2;
            minX = minX - difference/2;
        }
        
        if (maxY - minY < SCALE_MIN_VIEW){
            int difference = SCALE_MIN_VIEW - (maxY - minY);
            maxY = maxY + difference/2;
            minY = minY - difference/2;
        }
        
        //minY never smaller than 44 (toolbar's height) - TOOLBAR_HEIGHT
        if (minY < offsetH+TOOLBAR_HEIGHT+1)
            minY = offsetH+TOOLBAR_HEIGHT+1;
        
        singleton.globalImageRect = CGRectMake(self.frame.origin.x+minX, self.frame.origin.y+minY, maxX-minX, maxY-minY);
        
        CGRect screenRect = self.bounds;
        UIGraphicsBeginImageContextWithOptions(screenRect.size, NO, 0.0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        singleton.globalImageData = UIImagePNGRepresentation(img);
        
        //tell Gallery get the image and close this popup
        [self performSelector:@selector(noticeDismiss) withObject:nil afterDelay:0.1];
    }else{
        [self performSelector:@selector(noticeDismissWithNoStroke) withObject:nil afterDelay:0.1];
    }
}

-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DrawViewDismissed"
                                                        object:nil
                                                      userInfo:nil];
}

-(void)noticeDismissWithNoStroke{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DrawViewDismissedWithNoStroke"
                                                        object:nil
                                                      userInfo:nil];
}

@end
