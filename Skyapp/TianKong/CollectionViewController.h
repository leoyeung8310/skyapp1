//
//  CollectionViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 12/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewController : UIViewController{
    bool getCollectionsStatus;
    NSArray * collectionArray;
    int collectionCount;
}
@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backBtn;
- (IBAction)handleBack:(id)sender;


@end
