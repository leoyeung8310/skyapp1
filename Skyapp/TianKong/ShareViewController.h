//
//  ShareViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 14/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *orderLabel;
@property (strong, nonatomic) IBOutlet UITextField *inputTF;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;
@property (strong, nonatomic) IBOutlet UILabel *noticeLabel;
- (IBAction)handleShare:(id)sender;

@end
