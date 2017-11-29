//
//  SaveController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 2/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <CoreGraphics/CGGeometry.h>
#import <CoreLocation/CoreLocation.h>

@interface SaveController : NSObject <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    NSString * locInfo;
}

@property (nonatomic, retain) NSData* serializedData;

-(void) encodeAllObjects:(UIView*) containerView;
-(void) decodeAllObjects:(UIView*) containerView isViewOnly:(bool)myIsView;

-(bool)loadNoteBy:(NSString *)NoteID andServer:(NSString *)Server isViewOnly:(bool)myIsView;


@end
