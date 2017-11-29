//
//  MainViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 10/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate, UIPopoverControllerDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate>{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString * locInfo;
    
    int noteCount;
    NSArray* noteArray;
    NSMutableArray* noteControlBtnArray;
}

//Storyboard declared objects
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *logoutBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *collectionBtn;

@property (weak, nonatomic) IBOutlet UICollectionView *myCollView;

//Storyboard Click Action
- (IBAction)handleLogout:(id)sender;
- (IBAction)handleAdd:(id)sender;
- (IBAction)handleRefresh:(id)sender;

//Instance Objects
@property (nonatomic, retain) UIPopoverController *poc;
@property (nonatomic, assign) CGRect currentClickedRect; //for locating popover controller location
@property (nonatomic, weak) UIMenuController *menu;


-(void)didDismissCollectionViewController;



@end
