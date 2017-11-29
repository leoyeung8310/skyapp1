//
//  PickerViewController.h
//  Skyapp
//
//  Created by Cheuk yu Yeung on 12/10/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
    int selectedIndex;
    NSString * selectedStr;
    UITextField * targetTF;
    
    NSString * curSubject;
    NSString * curTopic;
    NSString * curSubTopic;
    int inputType;
}

@property (strong, nonatomic) IBOutlet UIPickerView *myPickerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *okBtn;
- (IBAction)handleOK:(id)sender;


@property(nonatomic,retain) NSArray *itemArr;
- (void) pointTF:(UITextField *)fromTF setSubject:(NSString *)mySubject setTopic:(NSString *)myTopic setSubTopic:(NSString *)mySubTopic setType:(int)inputType;

@end

