	//
//  WebViewController.h
//  TianKong
//
//  Created by Cheuk yu Yeung on 6/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>{
    bool needToLoadNewLink;
    NSString * status;
}

@property (strong, nonatomic) IBOutlet UIWebView *sbWebView;
@property (strong, nonatomic) IBOutlet UILabel *sbPageTitle;
@property (strong, nonatomic) IBOutlet UITextField *sbAddressField;

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stop;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *printScreen;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *bookmark;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pageBtn;

@property (nonatomic, retain) NSString *callUpLink;
@property (nonatomic, retain) UIImage * tmpImage;

///check pdf
@property (nonatomic, strong) NSString *mime;

//for save text
@property (nonatomic, retain) NSAttributedString *attStr;

- (void)loadRequestFromNewURL:(NSString*)urlString;
- (IBAction)pageCapture:(id)sender;
- (void)loadReport;

/*
- (void)loadRequestFromAddressField:(id)addressField;Dear JDear
- (void)loadRequestFromString:(NSString*)urlString;
- (void)updateButtons;
- (void)updateTitle:(UIWebView*)aWebView;
- (void)updateAddress:(NSURLRequest*)request;
- (void)informError:(NSError*)error;
- (void)doSaveText;
*/


@end