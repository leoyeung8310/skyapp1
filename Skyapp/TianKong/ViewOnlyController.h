//
//  ViewOnlyController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawView.h"
#import "SaveController.h"

@interface ViewOnlyController : UIViewController{
    bool loadNoteSuccess;
    NSString * controlStatus;
    UIImage * backgroundImg;
}

@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *drawBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *viewBtn;

- (IBAction)handleLeave:(id)sender;
- (IBAction)handleDraw:(id)sender;
- (IBAction)handleView:(id)sender;

//for save control
@property (nonatomic, retain) SaveController * mySaveController;


@end
