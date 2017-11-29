//
//  ViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 9/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "LoginViewController.h"
#import "MySingleton.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize appTypeLabel;
@synthesize passInput;
@synthesize nameInput;
@synthesize langSelect;
@synthesize loginBtn;
@synthesize versionLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //notification called when main view dismiss
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissMainViewController)
                                                 name:@"MainViewControllerDismissed"
                                               object:nil];
    
    //MyAppDelegate *delegate = (MyAppDelegate *)[UIApplication sharedApplication].delegate;
    
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"%@",singleton.globalUserID);
    
    if (APP_TYPE == 0){
        appTypeLabel.hidden=true;
    }else if (APP_TYPE == 1){
        appTypeLabel.hidden=false;
    }

    //get current app version
    versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    NSLog(@"applicationDidFinishLaunching");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"applicationWillTerminate");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleLoginClick:(id)sender {
    NSLog(@"handleLoginClick");
    
    [loginBtn setEnabled:NO];
    [nameInput endEditing:YES];
    [passInput endEditing:YES];
    
    MySingleton* singleton = [MySingleton getInstance];
    
    [MySingleton startLoading:self.view];
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        bool success = [self jsonLogin];
        [MySingleton endLoading:self.view andSuccess:success];
        if (success){
            //store global values
            singleton.globalLang = [[NSNumber alloc] initWithInt:(int)langSelect.selectedSegmentIndex]; //store Language
            
            //changel lang, by path to LocaleBundle. All localized strings can be referred to Localizable.string file.
            if (singleton.globalLang.integerValue == 0){
                NSString *path = [[NSBundle mainBundle] pathForResource:@"zh-Hant" ofType:@"lproj"];
                if (path) {
                    singleton.globalLocaleBundle = [NSBundle bundleWithPath:path];
                }
                
            }else if (singleton.globalLang.integerValue == 1){
                NSString *path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
                if (path) {
                    singleton.globalLocaleBundle = [NSBundle bundleWithPath:path];
                }
            }
            
            if ([singleton.globalUserType isEqualToString:@"teacher"] || [singleton.globalUserType isEqualToString:@"student"]){
                //Segue
                [self performSegueWithIdentifier:@"loginSegue" sender:self];
            }else if ([singleton.globalUserType isEqualToString:@"test"]){
                //Segue
                [self performSegueWithIdentifier:@"testSegue" sender:self];
            }
                 
            
        }else{
            [loginBtn setEnabled:YES];
        }
    });
}

//notification called when main view dismiss
-(void)didDismissMainViewController {
    self.nameInput.text = @"";
    self.passInput.text = @"";
    [loginBtn setEnabled:YES];
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalLang = 0;
    singleton.globalUserID = @"";
    singleton.globalUserAccount = @"";
    singleton.globalUserEmail = @"";
    singleton.globalUserSchool = @"";
    singleton.globalUserServer = @"";
    singleton.globalUserName = @"";
    singleton.globalUserType = @"";
    singleton.wvc = nil;
}

//login
- (bool)jsonLogin {
    bool boolSuccess = false;;
    
    if([self.nameInput.text isEqualToString:@""] || [self.passInput.text isEqualToString:@""] ) {
        [MySingleton alertStatus:@"請輸入帳戶及密碼 (Please enter Account and Password)" :@"登入失敗 (Sign in Failed)" :0];
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:self.nameInput.text] forKey:@"Account"]; //
        [dataInput setObject:[[NSString alloc] initWithString:self.passInput.text] forKey:@"Password"]; //
        [dataInput setObject:[[NSString alloc] initWithString:versionLabel.text] forKey:@"VersionNum"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:SERVER_ADDRESS andSubLink:@"jsonLogin.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
        if ([success  isEqual: @"OK"]){
            
            //set output key
            NSArray * inputKey = @[@"UserID", @"Account", @"Email", @"School", @"Server", @"UserName", @"UserType"];
            
            NSMutableDictionary * inputValues = [[NSMutableDictionary alloc]init];
            for (int i = 0 ; i < inputKey.count; i++){
                NSString * tmp = [NSString stringWithFormat:@"%@",[[[jsonData objectForKey:@"data"] objectAtIndex:0] objectForKey:inputKey[i]]];
                tmp = [tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [inputValues setObject:[[NSString alloc] initWithString:tmp] forKey:[[NSString alloc] initWithString:inputKey[i]]];
            }
            
            //set output values
            MySingleton* singleton = [MySingleton getInstance];
            singleton.globalUserID = [NSString stringWithFormat:@"%@",[inputValues objectForKey:@"UserID"]];
            singleton.globalUserAccount = [NSString stringWithFormat:@"%@",[inputValues objectForKey:@"Account"]];
            singleton.globalUserEmail = [NSString stringWithFormat:@"%@",[inputValues objectForKey:@"Email"]];
            singleton.globalUserSchool = [NSString stringWithFormat:@"%@",[inputValues objectForKey:@"School"]];
            singleton.globalUserServer = [NSString stringWithFormat:@"%@",[inputValues objectForKey:@"Server"]];
            singleton.globalUserName = [NSString stringWithFormat:@"%@",[inputValues objectForKey:@"UserName"]];
            singleton.globalUserType = [NSString stringWithFormat:@"%@",[inputValues objectForKey:@"UserType"]];

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


@end
