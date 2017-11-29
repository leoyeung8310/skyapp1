//
//  TestViewController.h
//  Skyapp
//
//  Created by Cheuk yu Yeung on 15/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController{
    int upData;
    int upSecond;
    int upNumNote;
    int errorNo;
    float avgTime;
    float lastTime;
    bool needStop;
}
@property (strong, nonatomic) IBOutlet UIButton *restartBtn;
- (IBAction)handleRestart:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutBtn;
- (IBAction)handleLogout:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *uploadData;
@property (strong, nonatomic) IBOutlet UISlider *sliderUploadData;
@property (strong, nonatomic) IBOutlet UITextField *uploadSecond;
@property (strong, nonatomic) IBOutlet UISlider *sliderUploadSecond;
@property (strong, nonatomic) IBOutlet UITextField *uploadedNote;
@property (strong, nonatomic) IBOutlet UITextField *uploadedAvgTime;
@property (strong, nonatomic) IBOutlet UITextField *uploadedLastTime;
@property (strong, nonatomic) IBOutlet UITextField *errorCaused;
@property (strong, nonatomic) IBOutlet UITextView *statusTV;



@end
