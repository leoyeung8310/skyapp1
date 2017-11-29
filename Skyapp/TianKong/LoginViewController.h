//
//  ViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 9/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UITextField *passInput;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *langSelect;
@property (weak, nonatomic) IBOutlet UILabel *appTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

- (IBAction)handleLoginClick:(id)sender;

-(void)didDismissMainViewController;


@end

