//
//  StudentThumbnailController.h
//  Skyapp
//
//  Created by Cheuk yu Yeung on 7/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentThumbnailController : UICollectionViewController{
    NSArray * srArr;
    int srArrCount;
    bool successSR;
    NSMutableArray * srSplitArr;
}

@end
