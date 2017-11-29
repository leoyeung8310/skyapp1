//
//  DrawView.h
//  getituseit
//
//  Created by Leo Yeung on 6/8/14.
//
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView
{
	CGFloat tx; // x translation
	CGFloat ty; // y translation
	CGFloat scale; // zoom scale
	CGFloat theta; // rotation angle
    
    int offsetH;
    
    NSMutableArray *strokes;
    NSMutableDictionary *touchPaths;
    
    NSMutableArray *colorStrokes;
    NSMutableDictionary *colorTouchPaths;
    
    bool didDraw;
    
    NSString * status;
    
    NSArray * uiBtnArr;
    UIBarButtonItem *blackBtn;
    UIBarButtonItem *redBtn;
    UIBarButtonItem *blueBtn;
    UIBarButtonItem *orangeBtn;
    UIBarButtonItem *yellowBtn;
    UIBarButtonItem *greenBtn;
    UIBarButtonItem *purpleBtn;
    UIBarButtonItem *eraserBtn;
    UIBarButtonItem *finishBtn;
}

- (id) initWithFrame:(CGRect)frame offsetH:(int)myH;

@end



