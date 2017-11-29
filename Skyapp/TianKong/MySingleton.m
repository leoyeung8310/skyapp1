//
//  MySingleton.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 10/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "MySingleton.h"

@implementation MySingleton

NSString * const SERVER_ADDRESS = @"http://i.cs.hku.hk/~skyapp/tk/";
//NSString * const SERVER_ADDRESS = @"http://i.cs.hku.hk/~cyyeung/tk/";//
//NSString * const SERVER_ADDRESS = @"http://i.cs.hku.hk/fyp/2015/fyp15017/tk/";//3
//NSString * const SERVER_ADDRESS = @"http://i.cs.hku.hk/fyp/2015/fyp15018/tk/";//4
//NSString * const SERVER_ADDRESS = @"http://i.cs.hku.hk/~kccheung/tk/";//5
//NSString * const SERVER_ADDRESS = @"http://lesofts.com/tk/";

const int APP_TYPE = 0;     //0 = Full Version (Full, 17+), 1 = Student Verison (4+)

const int R_LENGTH = 15;//30
const int MIN_FRAME_LENGTH = 40;
const int MAX_TF_CHAR = 200;
const int MAX_TF_WIDTH = 770;
const int MAX_TF_HEIGHT = 250;
const int MIN_TF_WIDTH = 24;
const int DEFAULT_TF_HEIGHT = 24;
const int DEFAULT_TF_WIDTH = 65;//55

const int MAX_OBJECT_IN_NOTE = 50;
const int TOOLBAR_HEIGHT = 44;

//--
@synthesize globalLang;
@synthesize globalLocaleBundle; //Lang --> Path --> Bundle (for changing lang on fly)

@synthesize globalUserType;
@synthesize globalUserName;
@synthesize globalUserID;
@synthesize globalUserAccount;
@synthesize globalUserEmail;
@synthesize globalUserSchool;
@synthesize globalUserServer;

@synthesize globalOnSelectedNoteID;
@synthesize globalQuestionID;
@synthesize globalAnswerID;
@synthesize globalReceivedNoteStr;
@synthesize globalReceivedNoteStatus;

@synthesize globalReceivedNoteSubject;
@synthesize globalReceivedNoteTopic;
@synthesize globalReceivedNoteSubTopic;
@synthesize globalReceivedNoteKeywords;
@synthesize globalReceivedNoteRemarks;
@synthesize globalReceivedNoteDifficulty;
@synthesize globalReceivedNoteDifficultyPresentation;
@synthesize globalReceivedNoteHighlightAns;
@synthesize globalReceivedNoteGiveGift;
@synthesize globalReceivedNoteTimeLimit;
@synthesize globalReceivedNoteMaxTrial;
@synthesize globalReceivedNoteNoOfTrial;
@synthesize globalReceivedNoteBackgroundImageStr; //BackgroundImage
@synthesize globalReceivedNoteEventLog;
@synthesize globalReceivedNoteQuestionLines;

//ICONS (Emoji)
@synthesize ICON_NORMAL;
@synthesize ICON_COLLECT;

//will cancel global variables
@synthesize globalImageData;
@synthesize globalImageRect;

//for init tf frame size
@synthesize globalPreviousTFFrame;

//for keyboard scroll view
@synthesize activeField;

//location
@synthesize globalLocInfo;

//view only
@synthesize globalViewOnlyNoteID;
@synthesize globalReceivedNoteViewOnlyStr;
@synthesize globalReceivedNoteViewOnlyBackgroundImageStr;
@synthesize globalReceivedNoteViewOnlyStatus;

//webview
@synthesize wvc;

//log
@synthesize logCon;

//Subject
@synthesize TOPIC_LIST;
@synthesize SUB_TOPIC_LIST;

static UIImageView *loadingGif;

static MySingleton *singletonInstance;

+ (id)getInstance{
    static MySingleton *sharedMySingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMySingleton = [[self alloc] init];
    });
    return sharedMySingleton;
}

- (id)init {
    if (self = [super init]) {
        NSLog(@"Singleton setup");
        
        ICON_NORMAL = @[
                       @[@"tick", @"good"],
                       @[@"cross", @"bad"],
                       @[@"cat happy 1", @"good"],
                       @[@"cat unhappy 1", @"bad"],
                       @[@"cat happy 2", @"good"],
                       @[@"cat unhappy 2", @"bad"],
                       @[@"cat happy 3", @"good"],
                       @[@"cat unhappy 3", @"bad"]
                       ];
        
        ICON_COLLECT = @[
                         @[@"cat doll", @"good"],
                         @[@"scissor", @"good"],
                         @[@"full marks", @"good"],
                         @[@"boy number one", @"good"],
                         @[@"happy boy", @"good"],
                         @[@"cry girl", @"bad"],
                         @[@"king", @"good"],
                         @[@"vampire", @"normal"]
                        ];
        
        //hardcode topic and sub-topic list
        TOPIC_LIST = @[
                        @"數",
                        @"圖形與空間",
                        @"度量",
                        @"數據處理",
                        @"代數"
                        ];
        
        NSArray * const subTopicArr0 = @[
                                        @"4N1乘法(二)",
                                        @"4N2除法(二)",
                                        @"4N3現代計算工具的認識",
                                        @"4N4倍數和因數",
                                        @"4N5公倍數和公因數",
                                        @"4N6四則計算(二)",
                                        @"4N7分數(二)",
                                        @"4N8小數(一)",
                                        @"4N-E1整除性 (增潤)",
                                        @"4N-E2質數及合成數(增潤)",
                                        @"5N1多位數",
                                        @"5N2分數(三)",
                                        @"5N3小數(二)",
                                        @"5N4分數(四)",
                                        @"5N5小數(三)",
                                        @"5N-E1古代數字 (增潤)",
                                        @"5N-E2循環小數(增潤)"
                                        ];
        
        NSArray * const subTopicArr1 = @[
                                        @"4S1四邊形(三)",
                                        @"4S2圖形拼砌與分割",
                                        @"4S3對稱",
                                        @"4S-E密鋪(增潤)",
                                        @"5S1八個方向",
                                        @"5S2立體圖形(三)",
                                        @"5S-E1旋轉對稱(增潤)"
                                        ];

        NSArray * const subTopicArr2 = @[
                                        @"4M1周界(一)",
                                        @"4M2面積(一)",
                                        @"5M1面積(二)",
                                        @"5M2體積(一)"
                                        ];
        
        NSArray * const subTopicArr3 = @[
                                        @"4D1象形圖(二)",
                                        @"5D1棒形圖(二)",
                                        @"5D2平均數",
                                        @"5D3棒形圖(三)"
                                        ];
        
        NSArray * const subTopicArr4 = @[
                                        @"4D1象形圖(二)",
                                        @"5A1代數的初步認識",
                                        @"5A2簡易方程(一)"
                                        ];
        
        SUB_TOPIC_LIST = @{
                           TOPIC_LIST[0]: subTopicArr0,
                           TOPIC_LIST[1]: subTopicArr1,
                           TOPIC_LIST[2]: subTopicArr2,
                           TOPIC_LIST[3]: subTopicArr3,
                           TOPIC_LIST[4]: subTopicArr4
                        };
        
        //init value
        globalLocInfo = @"";
        globalLang = 0;
        globalUserType = @"";
        globalUserName = @"";
        globalUserID = @"";
        globalOnSelectedNoteID = @"";
        globalQuestionID = @"";
        globalAnswerID = @"";
        globalReceivedNoteStr = @"";
        globalReceivedNoteStatus  = @"";
        globalLocInfo= @"";
        globalReceivedNoteEventLog = @"";
        globalReceivedNoteQuestionLines = @"";
        globalViewOnlyNoteID = @"";

    }
    return self;
}

//Retina Display Resize Image Ref: iCab Blog - Scaling images and creating thumbnails from UIViews
+ (void)beginImageContextWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (void)endImageContext
{
    UIGraphicsEndImageContext();
}

+ (UIImage*)imageFromView:(UIView*)view
{
    [self beginImageContextWithSize:[view bounds].size];
    BOOL hidden = [view isHidden];
    [view setHidden:NO];
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    [view setHidden:hidden];
    return image;
}

+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize
{
    UIImage *image = [self imageFromView:view];
    if ([view bounds].size.width != newSize.width ||
        [view bounds].size.height != newSize.height) {
        image = [self imageWithImage:image scaledToSize:newSize];
    }
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    [self beginImageContextWithSize:newSize];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return newImage;
}

+ (NSMutableDictionary *)jsonPostMultipleNSStringTo:(NSString *)domain andSubLink:(NSString *)sublink andDataInput:(NSMutableDictionary *)dataInput{
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
            // --------------- debug usage -----------------
            NSString *responseData = [[NSString alloc]initWithData:urlData encoding:NSUTF8StringEncoding];
            NSLog(@"Response ==> %@", responseData);
            
            NSError *error = nil;
            output = [NSJSONSerialization
                                      JSONObjectWithData:urlData
                                      options:NSJSONReadingMutableContainers
                                      error:&error];
            
        }else {
            //no internet connection
            [self alertStatus:@"請確保網絡連接正常後再嘗試. \nPlease connect to the internet and try again." :@"連接失敗 (Connection Fail)" :0];
        }
    }
    @catch (NSException * e) {
        NSLog(@"Exception: %@", e);
    }
    
    
    return output;
}

//general alert method
+ (void) alertStatus:(NSString *)msg :(NSString *)title :(int) tag{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
    alertView.tag = tag;
    [alertView show];
}

+ (UIImage*) imageWithColor:(UIColor*)color size:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    UIBezierPath* rPath = [UIBezierPath bezierPathWithRect:CGRectMake(0., 0., size.width, size.height)];
    [color setFill];
    [rPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (void) startLoading:(UIView *)myView{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *imageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"load1"], [UIImage imageNamed:@"load2"], [UIImage imageNamed:@"load3"], [UIImage imageNamed:@"load4"], [UIImage imageNamed:@"load5"], [UIImage imageNamed:@"load6"], [UIImage imageNamed:@"load7"], nil];
        loadingGif = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, myView.frame.size.width, myView.frame.size.height)];
        loadingGif.animationImages = imageArray;
        loadingGif.animationDuration = 1.0;
        loadingGif.contentMode = UIViewContentModeScaleAspectFill;
        [loadingGif startAnimating];
        [myView addSubview:loadingGif];
    });
}

+ (void) startLoadingForScrollView:(UIView *)myView withOffSetY:(int)offsetY{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *imageArray = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"load1"], [UIImage imageNamed:@"load2"], [UIImage imageNamed:@"load3"], [UIImage imageNamed:@"load4"], [UIImage imageNamed:@"load5"], [UIImage imageNamed:@"load6"], [UIImage imageNamed:@"load7"], nil];
        loadingGif = [[UIImageView alloc] initWithFrame:CGRectMake(0, offsetY, myView.frame.size.width, myView.frame.size.height)];
        loadingGif.animationImages = imageArray;
        loadingGif.animationDuration = 1.0;
        loadingGif.contentMode = UIViewContentModeScaleAspectFill;
        [loadingGif startAnimating];
        [myView addSubview:loadingGif];
    });
}

+ (void) endLoading:(UIView *)myView andSuccess:(bool)success{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingGif removeFromSuperview];
        if (success){
            UIImageView *loadingTick = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadtick"]];
            loadingTick.frame = CGRectMake(0, 0, myView.frame.size.width, myView.frame.size.height);
            [myView addSubview:loadingTick];
            
            double delayAnimationInSeconds = 3.0;
            [UIView animateWithDuration:delayAnimationInSeconds animations:^(void) {
                [loadingTick setAlpha:0];
            }];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayAnimationInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [loadingTick removeFromSuperview];
            });
        }else{
            NSLog(@"not showing tick image (!success)");
        }
    });
}

+ (void) endLoadingForScrollView:(UIView *)myView andSuccess:(bool)success withOffSetY:(int)offsetY{
    dispatch_async(dispatch_get_main_queue(), ^{
        [loadingGif removeFromSuperview];
        if (success){
            UIImageView *loadingTick = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadtick"]];
            loadingTick.frame = CGRectMake(0, offsetY, myView.frame.size.width, myView.frame.size.height);
            [myView addSubview:loadingTick];
            
            double delayAnimationInSeconds = 3.0;
            [UIView animateWithDuration:delayAnimationInSeconds animations:^(void) {
                [loadingTick setAlpha:0];
            }];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayAnimationInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [loadingTick removeFromSuperview];
            });
        }else{
            NSLog(@"not showing tick image (!success)");
        }
    });
}

+ (NSString *) getTimeStr{
    NSDate *currentTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentTimeStr = [dateFormatter stringFromDate:currentTime];
    return currentTimeStr;
}

+ (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

+ (NSMutableDictionary *) putTwoArraysIntoDict:(NSArray *)key andData:(NSArray *)data{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < key.count; i++){
        if (data[i] != nil && ![data[i] isEqualToString:@""] && ![key[i] isEqualToString:@""]){
            [dict setValue:data[i] forKey:key[i]];
        }
    }
    return dict;
}

@end