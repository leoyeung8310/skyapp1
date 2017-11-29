//
//  StudentThumbnailCell.h
//  Skyapp
//
//  Created by Cheuk yu Yeung on 7/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentThumbnailCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *thumbnailBtn;
@property (weak, nonatomic) IBOutlet UILabel *classNoLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentLabel;
@end
