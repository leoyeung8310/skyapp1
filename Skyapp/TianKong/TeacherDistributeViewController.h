//
//  TeacherDistributeViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 18/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeacherDistributeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    int NoOfAnsBox;
    int NoOfAns;
    
    //gift access
    /*
    NSArray * giftRightArray;
    NSInteger giftRightArrayCount;
    NSMutableArray * showGiftIdentifierArray;
    NSMutableArray * showGiftStrArray;
    NSMutableArray * showGiftImageNameArray;
    NSString * selectedGift;
    */
    
    //group access
    bool successGroupFind;
    NSArray * groupDBArray;
    NSInteger groupDBArrayCount;
    NSString * selectedGroup;
}
@property (strong, nonatomic) IBOutlet UILabel *groupLabel;
//@property (strong, nonatomic) IBOutlet UILabel *giftLabel;
@property (strong, nonatomic) IBOutlet UIButton *distributeBtn;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;

- (IBAction)handleDistribute:(id)sender;

- (void) setNoOfAnsBox:(int)myNum;
- (void) setNoOfAns:(int)myNum;
@end
