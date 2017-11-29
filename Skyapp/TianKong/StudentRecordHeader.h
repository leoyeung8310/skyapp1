//
//  StudentRecordHeader.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentRecordHeader : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *actHeadLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentLabel;
@property (weak, nonatomic) IBOutlet UILabel *marksLabel;
@property (weak, nonatomic) IBOutlet UILabel *feelingLabel;
@property (weak, nonatomic) IBOutlet UILabel *trialsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTakenLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *readLabel;

@end
