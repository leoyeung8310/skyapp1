//
//  IconInputController.m
//  ;
//
//  Created by Cheuk yu Yeung on 27/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "IconInputController.h"
#import "IconsCell.h"
#import "IconsHeader.h"
#import "MySingleton.h"

@interface IconInputController ()

@end

@implementation IconInputController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Do any additional setup after loading the view.
    MySingleton* singleton = [MySingleton getInstance];
    //iconsArr = [NSArray arrayWithObjects:singleton.ICON_NORMAL, singleton.ICON_COLLECT, nil];
    iconsArr = [NSArray arrayWithObjects: singleton.ICON_COLLECT, nil];
    
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    
    successGift = [self getGiftOwnByUserID:singleton.globalUserID andServer:singleton.globalUserServer];
    boolGiftOwnArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < singleton.ICON_COLLECT.count; i++){
        [boolGiftOwnArr addObject:[NSNumber numberWithBool:false]];
    }
    //BOOL b = [[array objectAtIndex:i] boolValue];
        
    if (successGift){
        //change some value to true if own
        for (int i = 0; i < giftOwnArrayCount; i++){
            //giftOwnArray
            [boolGiftOwnArr replaceObjectAtIndex:[[[giftOwnArray objectAtIndex:i] objectForKey:@"GiftNo"] intValue]-1 withObject:[NSNumber numberWithBool:true]];
        }
    }else{
        NSLog(@"fail successGift");
        
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!successGift){
        [self performSelector:@selector(noticeDismiss) withObject:nil afterDelay:0.1];
    }
}


-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [iconsArr count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
   return [[iconsArr objectAtIndex:section] count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MySingleton* singleton = [MySingleton getInstance];
    
    //configure heading
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        IconsHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        NSString *title = @"";
        
        /*
        if (indexPath.section == 0){
            NSString* iconStandard = NSLocalizedStringFromTableInBundle(@"iconStandard", nil, singleton.globalLocaleBundle, nil);
            title = iconStandard;
        }else if (indexPath.section == 1){
            NSString* iconCollection = NSLocalizedStringFromTableInBundle(@"iconCollection", nil, singleton.globalLocaleBundle, nil);
            title = iconCollection;
        }
        */
        
        if (indexPath.section == 0){
            NSString* iconCollection = NSLocalizedStringFromTableInBundle(@"iconCollection", nil, singleton.globalLocaleBundle, nil);
            title = iconCollection;
        }
        
        headerView.title.text = title;
        
        
        reusableview = headerView;
    }
    
    return reusableview;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //configure cell
    IconsCell * myCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellItem" forIndexPath:indexPath];

    NSString * frontStr = [iconsArr[indexPath.section] objectAtIndex:indexPath.row][0];
    NSString * endStr = @"";
    //if  (indexPath.section == 1){
    if  (indexPath.section == 0){
        //only for collection type
        if ([[boolGiftOwnArr objectAtIndex:indexPath.row] boolValue]){
            endStr = @"_200x250";
        }else{
            endStr = @"_black";
            myCell.cellBtn.enabled=false;
        }
    }
    NSString * str = [NSString stringWithFormat:@"%@%@",frontStr,endStr];

    [myCell.cellBtn setBackgroundImage:[UIImage imageNamed:str] forState:UIControlStateNormal];
    [myCell.cellBtn addTarget:self action:@selector(CellBtnTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    myCell.cellBtn.tag = indexPath.section*10000+indexPath.row;      //assume there is not more than 10000 icons in each section
    
    return myCell;
}

-(void)CellBtnTapped:(id)sender event:(id)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"iconInputCreateIcon"
                                                        object:nil
                                                      userInfo:sender];

}


- (bool)getGiftOwnByUserID:(NSString *)UserID andServer:(NSString *)Server{
    bool boolSuccess = false;
    giftOwnArray = nil;
    giftOwnArrayCount = 0;
    
    NSLog(@"getAllNoteByUserID");
    
    if([UserID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"loadGiftOwn.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            giftOwnArrayCount = [jsonData[@"count"] integerValue];
            if (giftOwnArrayCount > 0){
                giftOwnArray = [jsonData objectForKey:@"data"];
            }
            boolSuccess = true;
            
        }else if ([success  isEqual: @"ERROR"]){
            NSString * error_msg = [jsonData objectForKey:@"error_msg"];
            NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
            [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
            NSLog(@"system_error_msg = %@",system_error_msg);
        }
    }
    return boolSuccess;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
