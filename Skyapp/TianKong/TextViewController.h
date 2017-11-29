//
//  TextViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewController : UIViewController <UITextViewDelegate, UIPopoverControllerDelegate>{
    bool hasCurrentLabel;
}

@property (strong, nonatomic) IBOutlet UITextView *myTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
- (IBAction)handleSave:(id)sender;

- (void) addText:(NSAttributedString *)myOriStr;
- (bool) getHasCurrentLabel;

@end
