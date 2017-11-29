//
//  IconInputController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 27/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconInputController : UICollectionViewController{
    NSArray * iconsArr;
    
    //gift access
    bool successGift;
    NSArray * giftOwnArray;
    NSInteger giftOwnArrayCount;
    NSMutableArray * boolGiftOwnArr;
}

@end
