//
//  WebViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 6/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "WebViewController.h"
#import "MySingleton.h"

@interface WebViewController ()
@end

@implementation WebViewController

@synthesize sbWebView;
@synthesize sbPageTitle;
@synthesize sbAddressField;

@synthesize callUpLink;
@synthesize tmpImage;
@synthesize attStr;

@synthesize navBar;
@synthesize back;
@synthesize stop;
@synthesize refresh;
@synthesize forward;
@synthesize printScreen;
@synthesize bookmark;
@synthesize pageBtn;

//check pdf
@synthesize mime;

- (void)viewDidLoad
{
    NSLog (@"WebViewController viewDidLoad");
    [super viewDidLoad];
    
    printScreen.enabled=NO;
    bookmark.enabled=NO;
    pageBtn.enabled=NO;
    
    /* check UI exists error */
    NSAssert([sbWebView isKindOfClass:[UIWebView class]], @"You webView outlet is not correctly connected.");
    NSAssert(self.back, @"Your back button outlet is not correctly connected");
    NSAssert(self.stop, @"Your stop button outlet is not correctly connected");
    NSAssert(self.refresh, @"Your refresh button outlet is not correctly connected");
    NSAssert(self.forward, @"Your forward button outlet is not correctly connected");
    NSAssert((self.back.target == sbWebView) && (self.back.action = @selector(goBack)), @"Your back button action is not connected to goBack.");
    NSAssert((self.stop.target == sbWebView) && (self.stop.action = @selector(stopLoading)), @"Your stop button action is not connected to stopLoading.");
    NSAssert((self.refresh.target == sbWebView) && (self.refresh.action = @selector(reload)), @"Your refresh button action is not connected to reload.");
    NSAssert((self.forward.target == sbWebView) && (self.forward.action = @selector(goForward)), @"Your forward button action is not connected to goForward.");
    NSAssert(sbWebView.scalesPageToFit, @"You forgot to check 'Scales Page to Fit' for your web view.");
    
    [sbAddressField addTarget:self action:@selector(loadRequestFromAddressField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    status = @"normal";
    
    //init
    needToLoadNewLink = true;
    callUpLink = @"www.google.com.hk/webhp?hl=zh-TW";
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)AddSaveTextInMenu{
    NSLog(@"AddSaveTextInMenu-start");
    /* add one more button "Save Text" on select menu*/
    UIMenuController *menu = [UIMenuController sharedMenuController];
    NSMutableArray *options = [NSMutableArray array];
    UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"Save Text" action:@selector(doSaveText)];
    [options addObject:item];
    [menu setMenuItems:options];
    [menu setTargetRect:CGRectMake(0,0,sbWebView.frame.size.width,sbWebView.frame.size.height) inView:sbWebView];
    [menu setMenuVisible:YES animated:YES];
    [[UIApplication sharedApplication] sendAction:@selector(copy:) to:nil from:sbWebView forEvent:nil];
    NSLog(@"AddSaveTextInMenu-end");
}

- (void)AddDoubleTapGesture{
    NSLog(@"AddDoubleTapGesture-start");
    /* add double Tap gesture for image selection */
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTouchesRequired = 2;
    [sbWebView addGestureRecognizer:doubleTap];
    NSLog(@"AddDoubleTapGesture-end");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear-start");
    //*********************
    //NSLog(@"WebViewBounds-%@", NSStringFromCGRect(self.webView.bounds));
    //NSLog(@"WebViewFrame-%@", NSStringFromCGRect(self.webView.frame));
    
    /* add one more button "Save Text" on select menu*/
    [self AddSaveTextInMenu];
    
    /* add double tap Gesture */
    //[self AddDoubleTapGesture];
    
    sbWebView.delegate = self;
    
    if (needToLoadNewLink){
        [sbWebView reload];
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadRequestFromString:callUpLink];
        });
    }
    NSLog(@"viewWillAppear-end");
}

- (void)loadRequestFromNewURL:(NSString*)urlString{
    NSLog(@"loadRequestFromNewURL-start");
    callUpLink = urlString;
    needToLoadNewLink = true;
    NSLog(@"loadRequestFromNewURL-end");
}

- (IBAction)pageCapture:(id)sender {
    NSLog(@"pageCapture");

    //JS
    /*
    NSString * result1 =[sbWebView stringByEvaluatingJavaScriptFromString:@"2+3"];
    NSLog(@"2+3:%ld",(long)[result1 integerValue]);
    */
    
    //save image
    UIImage * tImg = [self buildBGImage];
    
    if (tImg != nil){
        [self SaveBGImage:tImg];
    }else{
        NSLog(@"return nil background image");
    }
}


//Modifed by: http://stackoverflow.com/questions/10919075/image-of-the-first-pdf-page-ios-sdk
- (UIImage *)buildBGImage
{
    //get internet pdf
    NSURL *URL = [NSURL URLWithString:sbAddressField.text];
    //NSURL *URL = [NSURL URLWithString:nil];
    NSData *pdfData = [[NSData alloc] initWithContentsOfURL:URL];
    CFDataRef myPDFData = (__bridge CFDataRef)pdfData;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
    CGPDFDocumentRef pdfDocument = CGPDFDocumentCreateWithProvider(provider);
    
    //calculate page number (half screen need to care, this is doing the same as )
    int pdfPageCount = (int)CGPDFDocumentGetNumberOfPages(pdfDocument);
    CGFloat contentHeight = sbWebView.scrollView.contentSize.height;
    float verticalContentOffset = sbWebView.scrollView.contentOffset.y;
    float pdfPageHeight = contentHeight / pdfPageCount;
    float halfScreenHeight = (sbWebView.frame.size.height / 2);
    int pageNumber = ceilf((verticalContentOffset + halfScreenHeight) / pdfPageHeight);
    NSLog(@"pageNumber = %d",pageNumber);
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdfDocument, pageNumber);  // get the pageNumber for your thumbnail
    
    CGRect pageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
    NSLog(@"start rect = %@",NSStringFromCGRect(pageRect));
    
    float pdfScale = sbWebView.frame.size.width/pageRect.size.width;
    pageRect.size = CGSizeMake(pageRect.size.width * pdfScale, pageRect.size.height * pdfScale);
    NSLog(@"end rect = %@",NSStringFromCGRect(pageRect));
    
    //UIGraphicsBeginImageContext(pageRect.size);
    UIGraphicsBeginImageContextWithOptions(pageRect.size, YES, pdfScale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // White BG
    CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
    CGContextFillRect(context,pageRect);
    CGContextSaveGState(context);
    
    // Next 3 lines makes the rotations so that the page look in the right direction
    CGContextTranslateCTM(context, 0.0, pageRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Scale the context so that the PDF page is rendered at the
    // correct size for the zoom level.
    //CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(pdfPage, kCGPDFMediaBox, pageRect, 0, true));
    CGContextScaleCTM(context, pdfScale,pdfScale);
    CGContextDrawPDFPage(context, pdfPage);
    CGContextRestoreGState(context);
    
    UIImage *thm = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (pdfData)
        return thm;
    else
        return nil;
}


- (void)loadRequestFromAddressField:(id)myAddressField
{
    NSLog(@"loadRequestFromAddressField-start");
    NSString *urlString = [myAddressField text];
    [self loadRequestFromString:urlString];
}

- (void)loadRequestFromString:(NSString*)urlString
{
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"loadRequestFromString-start");
    NSLog(@"urlString = %@",urlString);
    
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    
    
    bool match6Digits = false;
    if ([urlString rangeOfCharacterFromSet:notDigits].location == NSNotFound){
        // newString consists only of the digits 0 through 9
        NSUInteger characterCount = [urlString length];
        if (characterCount == 6){
            // newString consists only of the digits 0 through 9
            match6Digits = true;
        }
    }
    
    if (match6Digits && [singleton.globalUserType isEqual:@"teacher"]){
        NSLog(@"match6Digits = %@", urlString);
        //**//
        [MySingleton startLoading:self.view];
        
        //ON Button
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //do function
            NSString * pdfLink = @"";
            pdfLink = [self getPDFLinkFromCode:urlString];
            if (![pdfLink  isEqual: @""]){
                //have link
                [MySingleton endLoading:self.view andSuccess:true];
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self loadLink:pdfLink];
                });
            }else{
                [MySingleton endLoading:self.view andSuccess:false];
                [self loadLink:urlString];
            }
        });
    }else{
        [self loadLink:urlString];
    }
    
    
    //log
    NSArray * key = @[@"link"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",urlString]];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"loadRequestFromString" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
    NSLog(@"loadRequestFromString-end");
    
    
}

- (void) loadLink: (NSString *)urlString{
    NSString *URLEncodedText = urlString;
    NSURL *url = [NSURL URLWithString:URLEncodedText];
    
    if(!url.scheme)
    {
        NSString* modifiedURLString = [NSString stringWithFormat:@"https://%@", URLEncodedText];
        url = [NSURL URLWithString:modifiedURLString];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil){
             [sbWebView loadRequest:urlRequest];
         }else if (error != nil){
             NSLog(@"Error: %@", error);
             //if fail, do google search
             NSString* modifiedURLString2 = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", URLEncodedText];
             NSURL * url2 = [NSURL URLWithString:modifiedURLString2];
             NSURLRequest *urlRequest2 = [NSURLRequest requestWithURL:url2];
             [sbWebView loadRequest:urlRequest2];
         }
     }];
    
    needToLoadNewLink = false;
}

- (NSString *) getPDFLinkFromCode:(NSString *) code{
    //get singleton
    NSString * returnLink = @"";
    MySingleton* singleton = [MySingleton getInstance];
    //input
    NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
    [dataInput setObject:[[NSString alloc] initWithString:code] forKey:@"code"]; //
    [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%@", singleton.globalUserID]] forKey:@"UserID"]; //

    //connect server
    NSMutableDictionary *jsonData;
    jsonData = [MySingleton jsonPostMultipleNSStringTo:singleton.globalUserServer andSubLink:@"loadPDF.php" andDataInput:dataInput];
    
    //get result
    NSString * successSTR = [jsonData objectForKey:@"success"];
    //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
    if ([successSTR  isEqual: @"OK"]){
        returnLink = [NSString stringWithFormat:@"%@",[jsonData objectForKey:@"link"]];
        NSLog(@"returnLink = %@",returnLink);
    }else if ([successSTR  isEqual: @"ERROR"]){
        NSString * error_msg = [jsonData objectForKey:@"error_msg"];
        NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
        [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
        NSLog(@"system_error_msg = %@",system_error_msg);
    }
    return returnLink;
}

#pragma mark - Updating the UI
- (void)updateButtons
{
    NSLog(@"updateButtons - start");
    //get singleton
    MySingleton* singleton = [MySingleton getInstance];
    //old
    //bool isPdf = [[[sbWebView.request.URL pathExtension] lowercaseString] isEqualToString:@"pdf"];
    
    //new
    bool isPdf = [self isDisplayingPDF];
    
    if ([singleton.globalUserType  isEqual: @"teacher"] && isPdf){
        pageBtn.enabled=YES;
    }else{
        pageBtn.enabled=NO;
    }
    self.forward.enabled = sbWebView.canGoForward;
    self.back.enabled = sbWebView.canGoBack;
    self.stop.enabled = sbWebView.loading;
    NSLog(@"updateButtons-end");
}

- (void)updateTitle:(UIWebView*)aWebView
{
    NSLog(@"updateTitle");
    NSString* myPageTitle = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString * oldTitle = [NSString stringWithFormat:@"%@",sbPageTitle.text];
    sbPageTitle.text = myPageTitle;
    NSString * newTitle = [NSString stringWithFormat:@"%@",myPageTitle];
    NSLog(@"title = %@", myPageTitle);
    //NSLog(@"updateTitle-end");
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"oldTitle",@"newTitle"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",oldTitle],[NSString stringWithFormat:@"%@",newTitle]];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"updateTitle" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}


- (void)newUpdateAddress:(NSString*)newLink
{
    NSLog(@"newUpdateAddress");
    NSString * oldLink = [NSString stringWithFormat:@"%@",sbAddressField.text];
    sbAddressField.text = newLink;
    [self logNewAddressFieldAndTitle:oldLink toNewLink:newLink];
}

- (void)updateAddress:(NSURLRequest*)request
{
    NSLog(@"updateAddress");
    NSURL* url = [request mainDocumentURL];
    NSString* absoluteString = [url absoluteString];
    //absoluteString = [absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * oldLink = [NSString stringWithFormat:@"%@",sbAddressField.text];
    sbAddressField.text = absoluteString;
    NSString * newLink = [NSString stringWithFormat:@"%@",absoluteString];
    NSLog(@"link = %@", absoluteString);
    
    NSString *currentURL = [sbWebView stringByEvaluatingJavaScriptFromString:@"window.location"];
    NSLog(@"currentURL = %@", currentURL);
    //pass back mother for address
    //[self.delegate updateCurrentWebView:self.webView];
    
    [self logNewAddressFieldAndTitle:oldLink toNewLink:newLink];
}

- (void) logNewAddressFieldAndTitle:(NSString *)oldLink toNewLink:(NSString *)newLink{
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"oldLink",@"newLink"];
    NSArray * data = @[[NSString stringWithFormat:@"%@",oldLink],[NSString stringWithFormat:@"%@",newLink]];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"webViewController" andEventAction:@"updateLink" andContent:content andTimeStamp:[MySingleton getTimeStr]];
}

#pragma mark - Error Handling
- (void)informError:(NSError *)error
{
    NSLog(@"informError-start");
    NSString* localizedDescription = [error localizedDescription];
    UIAlertView* alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Error", @"Title for error alert.")
                              message:localizedDescription delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK button in error alert.")
                              otherButtonTitles:nil];
    [alertView show];
}



#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"1-shouldStartLoadWithRequest-start");
    
    NSLog(@"request = %@", request);
    
    NSLog(@"navigationType = %ld", (long)navigationType);
    
    //---- hard code (need to fix) ----
    if (navigationType == 5){
        //5 = same domain change page
        if ([request.URL.absoluteString rangeOfString:@"google.com"].location == NSNotFound) {
            NSLog(@"string does not contain google.com");
        } else {
            NSLog(@"string contains google.com!");
            [self updateAddress:request];
        }
    }
    [self performSelector:@selector(updateButtons) withObject:self afterDelay:3.0];
    NSLog(@"1-shouldStartLoadWithRequest-end");
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"2-webViewDidStartLoad-start");
    printScreen.enabled=NO;
    bookmark.enabled=NO;
    pageBtn.enabled=NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"2-webViewDidStartLoad-end");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //refresh
    NSLog(@"3-webViewDidFinishLoad-start");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    printScreen.enabled=YES;
    bookmark.enabled=YES;
    [self updateTitle:webView];
    [self newUpdateAddress:sbWebView.request.URL.absoluteString];
    [self updateButtons];
    NSLog(@"3-webViewDidFinishLoad-end");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"4-didFailLoadWithError-start");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"4-didFailLoadWithError end: %@", error);
}

#pragma mark - Print Screen Handling
- (IBAction)doPrintScreen:(id)sender {
    NSLog(@"doPrintScreen-start");
    /*
    //early
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       //later
    });
    */

    // TAKE SCREENSHOT
    CGRect myRect = [sbWebView bounds];
    UIGraphicsBeginImageContext(myRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, myRect);
    [sbWebView.layer renderInContext:ctx];
    UIImage *sourceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //save image
    [self SaveImage:sourceImage];
    
}

#pragma mark - Bookmark, Save Link Handling
- (IBAction)doBookmark:(id)sender {
    NSLog(@"doBookmark-start");

    NSLog(@"Link=%@",sbAddressField.text);
    NSLog(@"Title=%@",sbPageTitle.text);
    
    //[self.delegate createLink:self.addressField.text withTitle:self.pageTitle.text];
    [self performSelector:@selector(webViewCreateBookmark) withObject:self];
}

#pragma mark - Save Text Handling
- (void) doSaveText{
    NSLog(@"doSaveText-start");
    NSString *textFromSelection = [sbWebView stringByEvaluatingJavaScriptFromString: @"window.getSelection().toString()"];
    if (textFromSelection != nil && textFromSelection.length!= 0){
        attStr = [[NSAttributedString alloc] initWithString:textFromSelection];
        [self performSelector:@selector(webViewCreateText) withObject:self];
    }
}


#pragma mark - Getting Image by doubleTap
-(void) doubleTap :(UITapGestureRecognizer*) sender
{
    NSLog(@"doubleTAP");
    
    /*
    
    //<Find HTML tag which was clicked by user>
    //<If tag is IMG, then get image URL and start saving>
    
    CGPoint point = [sender locationInView:self.webView];
    // convert point from view to HTML coordinate system
    
    int displayWidth = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.outerWidth"] intValue];
    CGFloat f = self.webView.frame.size.width / displayWidth;
    
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 5.) {
        point.x = point.x * f;
        point.y = point.y * f;
    } else {
        // On iOS 4 and previous, document.elementFromPoint is not taking
        // offset into account, we have to handle it
        int scrollPositionY = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
        int scrollPositionX = [[self.webView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
        point.x = point.x * f + scrollPositionY;
        point.y = point.y * f + scrollPositionX;
    }
    
    // Load the JavaScript code from the Resources and inject it into the web page
    // put js file into "Copy bundle resource" make this code work
    NSString *path;
    NSBundle *thisBundle = [NSBundle mainBundle];
    path = [thisBundle pathForResource:@"JSTools" ofType:@"js"];
    
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView stringByEvaluatingJavaScriptFromString: jsCode];
    
    
    // call js functions
    NSString *tags = [self.webView stringByEvaluatingJavaScriptFromString:
                      [NSString stringWithFormat:@"getHTMLElementsAtPoint(%li,%li);",(long)point.x,(long)point.y]];
    NSString *tagsSRC = [self.webView stringByEvaluatingJavaScriptFromString:
                         [NSString stringWithFormat:@"getLinkSRCAtPoint(%li,%li);",(long)point.x,(long)point.y]];

    if ([tags rangeOfString:@",IMG,"].location != NSNotFound) {

        NSURL *url = [NSURL URLWithString:tagsSRC];
        NSData *data = [[NSData alloc]initWithContentsOfURL:url];
        UIImage *shownImage = [UIImage imageWithData:data];
        self.tmpImage = shownImage;
        UIImageView *imgView = [[UIImageView alloc] initWithImage:shownImage];
        [imgView setFrame:CGRectMake(floor(284-100)/2.0, 47, 100*2, 150*2)];
        
        
        float widthRatio = imgView.bounds.size.width / imgView.image.size.width;
        float heightRatio = imgView.bounds.size.height / imgView.image.size.height;
        float scale = MIN(widthRatio, heightRatio);
        float imageWidth = scale * imgView.image.size.width;
        float imageHeight = scale * imgView.image.size.height;
        
        NSLog(@"imgView=%@",imgView.description);
        NSLog(@"imageWidth=%f",imageWidth);
        NSLog(@"imageHeight=%f",imageHeight);
        if (imgView==nil || isnan(imageWidth) || isnan(imageHeight)){
            NSLog(@"imgView/Width/Height is nil");
        }else{
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.frame = CGRectMake(0, 0, imageWidth, imageHeight);
            imgView.center = imgView.superview.center;
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Save This Image?" message:nil delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
            [alertView setValue:imgView forKey:@"accessoryView"];
            v.backgroundColor = [UIColor yellowColor];
            [alertView show];
        }
        
    }
     
     */
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"alertView-start");
    /*
    if (buttonIndex == 0) { // means NO button pressed
        NSLog(@"Cancel");
    }
    if(buttonIndex == 1) { // means YES button pressed
        if (self.tmpImage!=nil){
            [self SaveImage:self.tmpImage];
        }else{
            NSLog(@"Cant Save Nil Image");
        }
    }
    */
}

#pragma mark insert tag Image
- (void)SaveBGImage : (UIImage*) img{
    NSLog(@"Saved BG Image-start");
    tmpImage = img;
    [self performSelector:@selector(webViewCreateBGImage) withObject:self];
}

#pragma mark insert tag Image
- (void)SaveImage : (UIImage*) img{
    NSLog(@"Saved Image-start");
    tmpImage = img;
    [self performSelector:@selector(webViewCreateImage) withObject:self];
}

//internet text and pic is different to PDF. Need to handle differently.


-(void)webViewCreateText{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webViewCreateText"
                                                        object:self
                                                      userInfo:nil];
}

-(void)webViewCreateImage{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webViewCreateImage"
                                                        object:self
                                                      userInfo:nil];
}

-(void)webViewCreateBGImage{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webViewCreateBGImage"
                                                        object:self
                                                      userInfo:nil];
}

-(void)webViewCreateBookmark{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"webViewCreateBookmark"
                                                        object:self
                                                      userInfo:nil];
}


//check pdf
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    mime = [response MIMEType];
}

- (BOOL)isDisplayingPDF {
    NSString *extension = [[mime substringFromIndex:([mime length] - 3)] lowercaseString];
    
    return ([[[sbWebView.request.URL pathExtension] lowercaseString] isEqualToString:@"pdf"] || [extension isEqualToString:@"pdf"]);
}

- (void)loadReport{
    NSLog(@"load report");
    MySingleton* singleton = [MySingleton getInstance];

    NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
    [dataInput setObject:[[NSString alloc] initWithString:singleton.globalUserID] forKey:@"UserID"]; //
    [dataInput setObject:[[NSString alloc] initWithString:singleton.globalOnSelectedNoteID] forKey:@"NoteID"]; //
    
    [self postMultipleNSStringToWebView:singleton.globalUserServer andSubLink:@"report/index.php" andDataInput:dataInput];
}

- (void *)postMultipleNSStringToWebView:(NSString *)domain andSubLink:(NSString *)sublink andDataInput:(NSMutableDictionary *)dataInput{
    @try {
        NSString *serverString = domain;
        NSString *urlString = [NSString stringWithFormat:(@"%@%@"),serverString,sublink];
        NSLog (@"urlString=%@",urlString);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (NSString* key in dataInput) {
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[dataInput objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [request setHTTPBody:body];
        
        [sbWebView loadRequest: request];
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }

}

//general alert method
- (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

@end
