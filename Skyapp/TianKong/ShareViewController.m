#import "ShareViewController.h"
#import "MySingleton.h"
@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //get singleton
    MySingleton* singleton = [MySingleton getInstance];
    
    //localication
    NSString* orderLabelText = NSLocalizedStringFromTableInBundle(@"orderLabelText", nil, singleton.globalLocaleBundle, nil);
    self.orderLabel.text = orderLabelText;
    NSString* shareBtnText = NSLocalizedStringFromTableInBundle(@"shareBtnText", nil, singleton.globalLocaleBundle, nil);
    self.shareBtn.titleLabel.text = shareBtnText;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleShare:(id)sender {
    NSLog(@"handleShare Button Pressed");
    NSLog(@"ToAccountOrUserName: %@",self.inputTF.text);
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"FromUserID= %@", singleton.globalUserID);
    NSLog(@"FromNoteID= %@", singleton.globalOnSelectedNoteID);
    
    //OFF Button
    self.shareBtn.enabled = NO;
    UIColor *color = [UIColor lightGrayColor];
    [sender setTitleColor:color forState:UIControlStateNormal];
    
    [MySingleton startLoading:self.view];
    
    //ON Button
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //do function
        bool shareSuccess = [self shareNoteBy:singleton.globalOnSelectedNoteID andServer:singleton.globalUserServer From:singleton.globalUserID To:self.inputTF.text];
        [MySingleton endLoading:self.view andSuccess:shareSuccess];
        if (shareSuccess){
            //[self dismissViewControllerAnimated:YES completion:nil];
            NSString* successShareMessage = NSLocalizedStringFromTableInBundle(@"successShareMessage", nil, singleton.globalLocaleBundle, nil);
            self.noticeLabel.text = successShareMessage;
            [self.inputTF resignFirstResponder];
        }else{
            //[self alertStatus:@"Share Fail Content" :@"Share Fail Heading":0];
            NSString* failShareMessage = NSLocalizedStringFromTableInBundle(@"failShareMessage", nil, singleton.globalLocaleBundle, nil);
            self.noticeLabel.text = failShareMessage;
            
            self.shareBtn.enabled = YES;
            UIColor *color = [UIColor redColor];
            [sender setTitleColor:color forState:UIControlStateNormal];
        }
    });
}

-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
}

-(bool)shareNoteBy:(NSString *)FromNoteID andServer:(NSString *)Server From:(NSString *)FromUserID To:(NSString *)ToAccount{
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"shareNoteBy");
    bool boolSuccess = false;
    
    if([FromNoteID isEqualToString:@""] || [FromUserID isEqualToString:@""] || [ToAccount isEqualToString:@""]) {
        NSString* errorNoInputHead = NSLocalizedStringFromTableInBundle(@"errorNoInputHead", nil, singleton.globalLocaleBundle, nil);
        NSString* errorNoInputContent = NSLocalizedStringFromTableInBundle(@"errorNoInputContent", nil, singleton.globalLocaleBundle, nil);
        [MySingleton alertStatus:errorNoInputContent :errorNoInputHead :0];
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:FromNoteID] forKey:@"FromNoteID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:FromUserID] forKey:@"FromUserID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:ToAccount] forKey:@"ToAccount"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"shareNote.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            boolSuccess = true;
        }else if ([success  isEqual: @"ERROR"]){
            NSString * error_msg = [jsonData objectForKey:@"error_msg"];
            NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
            [MySingleton alertStatus:error_msg :@"錯誤 (Error)" :0];
            NSLog(@"system_error_msg = %@",system_error_msg);
        }
        
        /*
         NSLog(@"share error");
         NSString* error_msg = jsonData[@"error_message"];
         if([error_msg isEqualToString:@"No Input Values"]){
         NSString* errorNoInputHead = NSLocalizedStringFromTableInBundle(@"errorNoInputHead", nil, singleton.globalLocaleBundle, nil);
         NSString* errorNoInputContent = NSLocalizedStringFromTableInBundle(@"errorNoInputContent", nil, singleton.globalLocaleBundle, nil);
         [MySingleton alertStatus:errorNoInputContent :errorNoInputHead :0];
         
         }else if([error_msg isEqualToString:@"Wrong From Values"]){
         NSString* errorWrongInputHead = NSLocalizedStringFromTableInBundle(@"errorWrongInputHead", nil, singleton.globalLocaleBundle, nil);
         NSString* errorWrongInputContent = NSLocalizedStringFromTableInBundle(@"errorWrongInputContent", nil, singleton.globalLocaleBundle, nil);
         [MySingleton alertStatus:errorWrongInputContent :errorWrongInputHead :0];
         
         }else if([error_msg isEqualToString:@"Wrong To Values"]){
         NSString* errorToHead = NSLocalizedStringFromTableInBundle(@"errorToHead", nil, singleton.globalLocaleBundle, nil);
         NSString* errorToContent = NSLocalizedStringFromTableInBundle(@"errorToContent", nil, singleton.globalLocaleBundle, nil);
         [MySingleton alertStatus:errorToContent :errorToHead :0];
         
         }else if([error_msg isEqualToString:@"Fail to duplicate note"]){
         NSString* errorCantCopyHead = NSLocalizedStringFromTableInBundle(@"errorCantCopyHead", nil, singleton.globalLocaleBundle, nil);
         NSString* errorCantCopyContent = NSLocalizedStringFromTableInBundle(@"errorCantCopyContent", nil, singleton.globalLocaleBundle, nil);
         [MySingleton alertStatus:errorCantCopyContent :errorCantCopyHead :0];
         }
         */
    }
    return boolSuccess;
}


@end
