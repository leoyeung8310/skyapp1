//
//  CommentViewController.m
//  Skyapp
//
//  Created by Cheuk yu Yeung on 13/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "CommentViewController.h"
#import "MySingleton.h"

const CGFloat COMMENT_FONT_SIZE = 18;

@interface CommentViewController ()

@end

@implementation CommentViewController

@synthesize myTextView;
@synthesize mySaveBtn;
@synthesize headLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //localization
    MySingleton* singleton = [MySingleton getInstance];
    NSString* confirmText = NSLocalizedStringFromTableInBundle(@"SaveBtn", nil, singleton.globalLocaleBundle, nil);
    self.mySaveBtn.title = [NSString stringWithFormat:@"%@", confirmText];
    
    headLabel.text = NSLocalizedStringFromTableInBundle(@"commentHeadLabel", nil, singleton.globalLocaleBundle, nil);
    
    // Do any additional setup after loading the view.
    mySaveBtn.enabled=false;  //until it is not empty
    
    //reset share menu
    UIMenuController * menu = [UIMenuController sharedMenuController];
    NSMutableArray *options = [NSMutableArray array];
    [menu setMenuItems:options];
    
    //textView delegate
    myTextView.delegate=self;
    
    //original text and font
    UIFont *regularFont = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    myTextView.font = regularFont;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MySingleton* singleton = [MySingleton getInstance];
    //load comment from DB
    
    [MySingleton startLoading:self.view];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        bool success = [self loadCommentBy:singleton.globalOnSelectedNoteID andServer:singleton.globalUserServer];
        [MySingleton endLoading:self.view andSuccess:success];
        if (success){
            [myTextView becomeFirstResponder];
        }else{
            NSLog(@"CVC leave");
            //[self performSelector:@selector(noticeDismiss) withObject:self afterDelay:0.001];
        }
    });
}

- (bool)loadCommentBy:(NSString *)NoteID andServer:(NSString *)Server{
    bool boolSuccess = false;
    NSLog(@"loadCommentBy");
    
    if([NoteID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"loadComment.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        if ([success  isEqual: @"OK"]){
            NSString * myCom = [NSString stringWithFormat:@"%@",[[[jsonData objectForKey:@"data"] objectAtIndex:0] objectForKey:@"Comments"]];  //*
            self.myTextView.text = [NSString stringWithFormat:@"%@",myCom];
            //NSString *responseData = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"responseData - %@",responseData);
            //stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
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


- (void) addText:(NSString *)myOriStr{
    self.myTextView.text = myOriStr;
    mySaveBtn.enabled = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleSave:(id)sender {
    //[self performSelector:@selector(noticeDismiss) withObject:self afterDelay:0.001];
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"CVC SAVE noteID = %@", singleton.globalOnSelectedNoteID);
    mySaveBtn.enabled=false;
    
    [MySingleton startLoading:self.view];
    
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        bool success = [self saveCommentBy:singleton.globalOnSelectedNoteID andServer:singleton.globalUserServer];
        [MySingleton endLoading:self.view andSuccess:success];
    });
}


-(bool)saveCommentBy:(NSString *)NoteID andServer:(NSString *)Server{
    bool boolSuccess = false;
    
    if([NoteID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:self.myTextView.text] forKey:@"Comments"]; //
        NSLog(@"self.textView.text = %@",self.myTextView.text);
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"saveComment.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
        if ([success  isEqual: @"OK"]){
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

-(void)noticeDismiss{
    /*
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentViewControllerDismissed"
                                                        object:self
                                                      userInfo:nil];
    */
}

//delegate UITextViewDelegate for selection change
- (void) textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"CVC Fire change selection.");
}

//delegate UITextViewDelegate for textview text change
- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"CVC Fire text change.");
    
    NSString *trimmedString = [self.myTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedString isEqual: @""]){
        mySaveBtn.enabled=false;
    }else{
        mySaveBtn.enabled=true;
    }
}

@end
