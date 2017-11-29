//
//  GalleryViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 19/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "GalleryViewController.h"
#import "MySingleton.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVMediaFormat.h"

const int PIC_MAX_LENGTH = 600;

@interface GalleryViewController ()

@end

@implementation GalleryViewController

@synthesize imagePicker;
@synthesize selectedImage;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedImage = nil;
    pickerTypeIsCamera = false;
    pickerTypeIsGallery = false;
    [self preparePicker];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!pickerTypeIsCamera && !pickerTypeIsGallery){
        NSLog(@"close view");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (pickerTypeIsCamera){
        [self handleCamera];
        pickerTypeIsCamera = false;
    }
    if (pickerTypeIsGallery){
        [self handleAdd];
        pickerTypeIsGallery = false;
    }
    

}

- (void)setTypeToCamera{
    pickerTypeIsCamera = true;
}

- (void)setTypeToGallery{
    pickerTypeIsGallery = true;
}

- (void)preparePicker {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext; // For Full Screen - UIModalPresentationFullScreen UIModalPresentationCurrentContext    picker.allowsEditing = YES;
    imagePicker = picker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)handleCamera{
    NSLog(@"handleCamera");
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationOverCurrentContext; // For Full Screen - UIModalPresentationFullScreen
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker = picker;
    }
    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentViewController:imagePicker animated:YES completion:nil];
    });
}

- (void)handleAdd {
    NSLog(@"handleAdd");
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        NSLog(@"do here");
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.modalPresentationStyle = UIModalPresentationOverCurrentContext; // For Full Screen - UIModalPresentationFullScreen
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker = picker;
    }

    double delayInSeconds = 0.01;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self presentViewController:imagePicker animated:YES completion:nil];
    });
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"finish picking photo");
    
    // Code here to work with media
    
    selectedImage = info[UIImagePickerControllerOriginalImage];
    //NSLog(@"chosenImage size = %@",NSStringFromCGSize(selectedImage.size));
    selectedImage = [self scaleImage:selectedImage toResolution:PIC_MAX_LENGTH];
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalImageData = UIImagePNGRepresentation(selectedImage);
    
    //tell Gallery get the image and close this popup
    [self performSelector:@selector(noticeDismiss) withObject:self];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    NSLog(@"clicked cancel");
    
    [self performSelector:@selector(noticeDismiss) withObject:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//to scale images without changing aspect ratio
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {
    
    float width = newSize.width;
    float height = newSize.height;
    
    UIGraphicsBeginImageContext(newSize);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    float widthRatio = image.size.width / width;
    float heightRatio = image.size.height / height;
    float divisor = widthRatio > heightRatio ? widthRatio : heightRatio;
    
    width = image.size.width / divisor;
    height = image.size.height / divisor;
    
    rect.size.width  = width;
    rect.size.height = height;
    
    //indent in case of width or height difference
    float offset = (width - height) / 2;
    if (offset > 0) {
        rect.origin.y = offset;
    }
    else {
        rect.origin.x = -offset;
    }
    
    [image drawInRect: rect];
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return smallImage;
    
}

- (UIImage *)scaleImage:(UIImage*)image toResolution:(int)resolution {
    
    CGImageRef imgRef = [image CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //if already at the minimum resolution, return the orginal image, otherwise scale
    if (width <= resolution && height <= resolution) {
        return image;
        
    } else {
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            bounds.size.width = resolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = resolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}


-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GalleryViewControllerDismissed"
                                                        object:self
                                                      userInfo:nil];
}


@end
