//
//  TestViewController.m
//  Skyapp
//
//  Created by Cheuk yu Yeung on 15/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "TestViewController.h"
#import "MySingleton.h"

const int MAXLENGTH = 1500;
const int ADJUSTEDLENGTH = 1100;

@interface TestViewController ()

@end

@implementation TestViewController
@synthesize uploadData;
@synthesize uploadSecond;
@synthesize sliderUploadData;
@synthesize sliderUploadSecond;
@synthesize uploadedNote;
@synthesize uploadedAvgTime;
@synthesize uploadedLastTime;
@synthesize statusTV;
@synthesize restartBtn;
@synthesize errorCaused;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [sliderUploadData addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    [sliderUploadSecond addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    
    upData = 0;
    upSecond = 0;
    upNumNote = 0;
    errorNo = 0;
    avgTime = 0;
    lastTime = 0;
    needStop = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshValue];
    dispatch_async(dispatch_get_global_queue(0, 0),
       ^{
           while (!needStop){
               dispatch_async(dispatch_get_global_queue(0, 0),
                              ^{
                                  [self handleAddAndUploadNote];
                              });
               [NSThread sleepForTimeInterval:upSecond];
           }
           
       });
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)handleLogout:(id)sender {
    //noticfy login page for dismissing.
    needStop = true;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MainViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sliderDidChange:(id)sender {
    [self refreshValue];
    if (sender == sliderUploadData){
        uploadData.text = [NSString stringWithFormat:@"%d",upData];
    }else if (sender == sliderUploadSecond){
        uploadSecond.text = [NSString stringWithFormat:@"%d",upSecond];
    }
}

- (void) refreshValue{
    upData = (int)sliderUploadData.value;
    upSecond = (int)sliderUploadSecond.value;
}


- (void)handleAddAndUploadNote{
    MySingleton* singleton = [MySingleton getInstance];
    [self addNewNoteBy:singleton.globalUserID andLoc:singleton.globalLocInfo andServer:singleton.globalUserServer];
}

-(bool)addNewNoteBy:(NSString *)UserID andLoc:(NSString *)Loc andServer:(NSString *)Server{
    NSLog(@"addNewNoteBy");
    NSDate *methodStart = [NSDate date];
    bool boolSuccess = false;
    
    if([UserID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:Loc] forKey:@"Location"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [self jsonPostMultipleNSStringTo:Server andSubLink:@"addNote.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        NSString * NewNoteID = [jsonData objectForKey:@"NewNoteID"];
        NSLog(@"NewNoteID = %@",NewNoteID);
        if ([success  isEqual: @"OK"]){
            boolSuccess = true;
            [self handleSave:NewNoteID ByStartTime:methodStart];
        }else if ([success  isEqual: @"ERROR"]){
            NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
            errorNo++;
            errorCaused.text = [NSString stringWithFormat:@"%d",errorNo];
            NSString * errorMsg = [NSString stringWithFormat:@"%@ - Note ID: %@ - %@",methodStart,NewNoteID,system_error_msg];
            NSLog (@"statusTV.text.length = %lu",(unsigned long)statusTV.text.length);
            if (statusTV.text.length > MAXLENGTH){
                statusTV.text = [NSString stringWithFormat:@"%@\n%@",errorMsg,[statusTV.text substringToIndex:ADJUSTEDLENGTH]];
            }else{
                statusTV.text = [NSString stringWithFormat:@"%@\n%@",errorMsg,statusTV.text];
            }
        }
    }
    return boolSuccess;
}

- (NSString*)generateRandomString:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

- (void)handleSave:(NSString *)noteID ByStartTime:(NSDate *)methodStart {
    MySingleton* singleton = [MySingleton getInstance];
    
    //count feedback icons
    int countCorrect = 0;
    int countIncorrect= 0;
    int countHappy = 0;
    int countNoIdea = 0;
    int countTimesup = 0;
    
    //check if all answer are corrects in answer box
    int correctAnswer = 0;
    
    NSString * garbageContent = [self generateRandomString:(1024*1024*upData)];
    NSString * garbageZero= @"0";
    
    if (true){
        //--------------------------------------------------simply save-------------------------------------------
        double delayInSeconds = 0.1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            bool success = false;
            if(false) {
                //
            } else {
                //input
                NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%@",noteID]] forKey:@"NoteID"]; //
                [dataInput setObject:[[NSString alloc] initWithString:garbageContent] forKey:@"NoteContent"]; //
                [dataInput setObject:[[NSString alloc] initWithString:garbageZero] forKey:@"Thumbnail"]; //

                [dataInput setObject:[[NSString alloc] initWithString:garbageZero] forKey:@"Location"]; //
                [dataInput setObject:[[NSString alloc] initWithString:garbageZero] forKey:@"AnswerID"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countCorrect]] forKey:@"CountCorrect"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countIncorrect]] forKey:@"CountIncorrect"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countHappy]] forKey:@"CountHappy"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countNoIdea]] forKey:@"CountNoIdea"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",countTimesup]] forKey:@"CountTimesup"]; //
                [dataInput setObject:[[NSString alloc] initWithString:[NSString stringWithFormat:@"%i",correctAnswer]] forKey:@"Marks"]; //
                
                //connect server
                NSMutableDictionary *jsonData;
                jsonData = [self jsonPostMultipleNSStringTo:singleton.globalUserServer andSubLink:@"saveNote.php" andDataInput:dataInput];
                
                //get result
                NSString * successSTR = [jsonData objectForKey:@"success"];
                NSDate *methodFinish = [NSDate date];
                //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
                if ([successSTR  isEqual: @"OK"]){
                    success = true;
                    
                    //Now Time & calculate used Time
                    NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                    NSLog(@"executionTime = %f", executionTime);
                    
                    //upload note update
                    lastTime = executionTime;
                    uploadedLastTime.text = [NSString stringWithFormat:@"%f",lastTime];
                    
                    avgTime = (avgTime * upNumNote + lastTime) / (upNumNote + 1);
                    uploadedAvgTime.text = [NSString stringWithFormat:@"%f",avgTime];
                    
                    upNumNote++;
                    uploadedNote.text = [NSString stringWithFormat:@"%d",upNumNote];
                    
                    NSString * successMsg = [NSString stringWithFormat:@"%@ - Note ID: %@ - Uploaded",methodFinish,noteID];
                    NSLog (@"statusTV.text.length = %lu",(unsigned long)statusTV.text.length);
                    if (statusTV.text.length > MAXLENGTH){
                        statusTV.text = [NSString stringWithFormat:@"%@\n%@",successMsg,[statusTV.text substringToIndex:ADJUSTEDLENGTH]];
                    }else{
                        statusTV.text = [NSString stringWithFormat:@"%@\n%@",successMsg,statusTV.text];
                    }
                }else if ([successSTR  isEqual: @"ERROR"]){
                    NSString * system_error_msg = [jsonData objectForKey:@"system_error_msg"];
                    errorNo++;
                    errorCaused.text = [NSString stringWithFormat:@"%d",errorNo];
                    NSString * errorMsg = [NSString stringWithFormat:@"%@ - Note ID: %@ - %@",methodFinish,noteID,system_error_msg];
                    NSLog (@"statusTV.text.length = %lu",(unsigned long)statusTV.text.length);
                    if (statusTV.text.length > MAXLENGTH){
                        statusTV.text = [NSString stringWithFormat:@"%@\n%@",errorMsg,[statusTV.text substringToIndex:ADJUSTEDLENGTH]];
                    }else{
                        statusTV.text = [NSString stringWithFormat:@"%@\n%@",errorMsg,statusTV.text];
                    }
                }
            }
        });
    }
}

- (NSMutableDictionary *)jsonPostMultipleNSStringTo:(NSString *)domain andSubLink:(NSString *)sublink andDataInput:(NSMutableDictionary *)dataInput{
    NSMutableDictionary * output;
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
        
        NSError *error = [[NSError alloc] init];
        NSHTTPURLResponse *response = nil;
        NSData *urlData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        NSLog(@"Response code: %ld", (long)[response statusCode]);
        if ([response statusCode] >= 200 && [response statusCode] < 300)
        {
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"Response ==> %@", responseData);
            
            NSError *error = nil;
            output = [NSJSONSerialization
                      JSONObjectWithData:urlData
                      options:NSJSONReadingMutableContainers
                      error:&error];
            
        }else {
            //no internet connection
            errorNo++;
            errorCaused.text = [NSString stringWithFormat:@"%d",errorNo];
            NSString * errorMsg = [NSString stringWithFormat:@"RES CODE : %ld - Please connect to the internet and try again",(long)[response statusCode]];
            NSLog (@"statusTV.text.length = %lu",(unsigned long)statusTV.text.length);
            if (statusTV.text.length > MAXLENGTH){
                statusTV.text = [NSString stringWithFormat:@"%@\n%@",errorMsg,[statusTV.text substringToIndex:ADJUSTEDLENGTH]];
            }else{
                statusTV.text = [NSString stringWithFormat:@"%@\n%@",errorMsg,statusTV.text];
            }
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
    return output;
}

- (IBAction)handleRestart:(id)sender {
    restartBtn.enabled = false;
    needStop = true;
}
@end
