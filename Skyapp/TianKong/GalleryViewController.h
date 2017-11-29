//
//  GalleryViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 19/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface GalleryViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    bool pickerTypeIsCamera; //yes = open camera, no = do nth
    bool pickerTypeIsGallery; //yes = open gallery, no = do nth
}

- (void)setTypeToCamera;
- (void)setTypeToGallery;

@property (nonatomic) UIImage *selectedImage;
@property (nonatomic) UIImagePickerController *imagePicker;

@end

