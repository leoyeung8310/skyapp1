//
//  CommentViewController.h
//  Skyapp
//
//  Created by Cheuk yu Yeung on 13/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentViewController : UIViewController <UITextViewDelegate, UIPopoverControllerDelegate>{
    
}

@property (strong, nonatomic) IBOutlet UITextView *myTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mySaveBtn;
@property (strong, nonatomic) IBOutlet UILabel *headLabel;

- (IBAction)handleSave:(id)sender;

@end
