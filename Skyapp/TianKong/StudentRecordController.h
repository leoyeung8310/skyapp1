//
//  StudentRecordController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface StudentRecordController : UICollectionViewController <MFMailComposeViewControllerDelegate>{
    NSArray * srArr;
    int srArrCount;
    bool successSR;
    NSMutableArray * srSplitArr;
    NSMutableDictionary * buttonToCommentDict;
    NSMutableDictionary * buttonToNameDict;
}

@end
