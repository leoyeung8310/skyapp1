//
//  StudentRecordCell.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentRecordCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *classNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentLabel;
@property (weak, nonatomic) IBOutlet UILabel *marksLabel;

@property (strong, nonatomic) IBOutlet UILabel *CountCorrect;
@property (strong, nonatomic) IBOutlet UILabel *CountIncorrect;
@property (strong, nonatomic) IBOutlet UILabel *CountHappy;
@property (strong, nonatomic) IBOutlet UILabel *CountNoIdea;
@property (strong, nonatomic) IBOutlet UILabel *CountTimesUp;

@property (weak, nonatomic) IBOutlet UILabel *trialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTakenLabel;

@property (strong, nonatomic) IBOutlet UIButton *viewCommentBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@end
