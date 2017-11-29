//
//  DefineQuestionView.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 14/12/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import "DefineQuestionView.h"
#import "UIView-Transform.h"
#import "MySingleton.h"
#import "DragQuestionLine.h"

@implementation DefineQuestionView
//
- (id)initWithFrame:(CGRect)frame offsetH:(int)myH setContainerView:(UIView *)cv setScrollView:(UIScrollView *)sv
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = NO;
        
        offsetH = myH;
        containerView = cv;
        scrollView = sv;
        
        //transparent background
        //self.alpha = myAlphaFloat;
        UIColor *transparentColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.05f];
        self.backgroundColor = transparentColor;
        //self.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.05f];
        self.opaque = NO;
        
        //tool bar
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.barTintColor=[UIColor lightTextColor];
        //toolbar.layer.borderWidth = 3;
        //toolbar.layer.borderColor = [[UIColor blackColor] CGColor];
        //toolbar.frame = CGRectMake(0, 0, self.frame.size.width, TOOLBAR_HEIGHT);
        toolbar.frame = self.frame;
        
        UIBarButtonItem *f1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        addQuestionLineBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add question line"] style:UIBarButtonItemStylePlain target:self action:@selector(addQuestionLine)];

        finishBtn=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"finishBtn"] style:UIBarButtonItemStylePlain target:self action:@selector(finishAction)];
        uiBtnArr = @[addQuestionLineBtn,finishBtn];

        [toolbar setItems:[[NSArray alloc] initWithObjects:addQuestionLineBtn,f1,finishBtn, nil]];
        [self addSubview:toolbar];
        
        status = @"normal";
        
        //MySingleton* singleton = [MySingleton getInstance];
        
        CGRect frame = containerView.frame; // Replacing with your dimensions
        questionView = [[QuestionView alloc] initWithFrame:frame withScrollView:scrollView];
        [containerView addSubview:questionView];
        [questionView.superview bringSubviewToFront:questionView];
        
        arrQL = [[NSMutableArray alloc] init];
        
        qvString=@"";
        qvData=nil;
        
        [self decodeAllQuestionLines];
    }
    return self;
}

-(void) encodeAllQuestionLines{
    NSMutableArray* objArray = [[NSMutableArray alloc]init];
    for (UIView *subview in questionView.subviews){
        if([subview isKindOfClass:[DragQuestionLine class]]){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            DragQuestionLine * obj = (DragQuestionLine *) subview;
            [dict setObject:@"dragQuestionLine" forKey:@"type"];       //all objects required
            [dict setObject:[NSNumber numberWithFloat:obj.frame.origin.x] forKey:@"frameX"];
            [dict setObject:[NSNumber numberWithFloat:obj.frame.origin.y] forKey:@"frameY"];
            [dict setObject:[NSNumber numberWithFloat:obj.frame.size.width] forKey:@"frameW"];
            [dict setObject:[NSNumber numberWithFloat:obj.frame.size.height] forKey:@"frameH"];
            [objArray addObject:dict];
        }
    }
    
    qvString = @"";
    NSError *error = nil;
    qvData = [NSJSONSerialization dataWithJSONObject:objArray
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!qvData) {
        NSLog(@"Got an error in jsonData: %@", error);
    } else {
        qvString = [[NSString alloc] initWithData:qvData encoding:NSUTF8StringEncoding];
    }
}

-(void) decodeAllQuestionLines{
    MySingleton* singleton = [MySingleton getInstance];
    
    //NSString *length = @"";
    NSData* myData  = nil;
    
    NSString * qlines = [NSString stringWithFormat:@"%@",singleton.globalReceivedNoteQuestionLines];
    NSLog(@"decodeAllQuestionLines - QuestionsLines = %@", qlines);
    myData = [qlines dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *e;
    NSMutableArray *myArray = [NSJSONSerialization JSONObjectWithData:myData options:kNilOptions error:&e];
    
    for (NSMutableDictionary * dict in myArray) {
        NSString * type = [dict valueForKey:@"type"];
        if ([type isEqualToString:@"dragQuestionLine"]){
            CGRect rect = CGRectMake([[dict valueForKey:@"frameX"] floatValue], [[dict valueForKey:@"frameY"] floatValue], [[dict valueForKey:@"frameW"] floatValue], [[dict valueForKey:@"frameH"] floatValue]);
            DragQuestionLine *myDQL = [[DragQuestionLine alloc] initWithMyFrame:rect andScrollView:scrollView];
            [questionView addSubview:myDQL];
        }
    }
}

- (void)refreshButtons{
    for (int i = 0; i < uiBtnArr.count; i++){
        UIBarButtonItem * myBtn = (UIBarButtonItem * )uiBtnArr[i];
        myBtn.enabled=true;
    }
}

- (void)addQuestionLine{
    CGPoint offsetPT = [scrollView contentOffset];
    int newH = offsetPT.y;
    [scrollView setContentOffset:CGPointMake(0, newH) animated:YES];
    
    int newY = newH+scrollView.frame.size.height/2;
    if (newY < containerView.frame.size.height){
        NSLog(@"Add Question Line - type 1");
        DragQuestionLine * line = [[DragQuestionLine alloc] initWithY:newY andWidth:containerView.frame.size.width andScrollView:scrollView];
        [questionView addSubview:line];
    }else{
        newY = newH+50;
        if (newY < containerView.frame.size.height){
            NSLog(@"Add Question Line - type 2");
            DragQuestionLine * line = [[DragQuestionLine alloc] initWithY:newY andWidth:containerView.frame.size.width andScrollView:scrollView];
            [questionView addSubview:line];
        }else{
            NSLog(@"Fail to add Question Line");
        }
    }
}

- (void)finishAction {
    MySingleton* singleton = [MySingleton getInstance];
    [MySingleton startLoading:scrollView];
    
    [self encodeAllQuestionLines];
    
    //ON Button
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //do function
        bool updateSuccess = [self updateQuestionLines:singleton.globalOnSelectedNoteID andUserID:singleton.globalUserID andServer:singleton.globalUserServer];
        [MySingleton endLoading:scrollView andSuccess:updateSuccess];
        
        if (updateSuccess){
            //[self dismissViewControllerAnimated:YES completion:nil];
            NSString* successShareMessage = NSLocalizedStringFromTableInBundle(@"successUpdateQuestionLinesMessage", nil, singleton.globalLocaleBundle, nil);
            NSLog(@"%@",successShareMessage);            //statusLabel.text = successShareMessage;
            //madeChange = false;
            
            [questionView removeFromSuperview];
            [self removeFromSuperview];
            [self performSelector:@selector(noticeDismiss) withObject:nil afterDelay:0.1];
            
        }else{
            //[self alertStatus:@"Share Fail Content" :@"Share Fail Heading":0];
            NSString* failShareMessage = NSLocalizedStringFromTableInBundle(@"failUpdateQuestionLinesMessage", nil, singleton.globalLocaleBundle, nil);
            NSLog(@"%@",failShareMessage);
            //statusLabel.text = failShareMessage;
        }
        
        //okBtn.enabled = YES;
        
    });

}


- (bool) updateQuestionLines:(NSString *)NoteID andUserID:(NSString *)UserID andServer:(NSString *)Server{
    MySingleton* singleton = [MySingleton getInstance];
    bool boolSuccess = false;
    
    if([NoteID isEqualToString:@""] || [UserID isEqualToString:@""] || [Server isEqualToString:@""] ) {
        //
    } else {
        NSString * new1 = [[NSString alloc] initWithString:qvString];
        
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        [dataInput setObject:[[NSString alloc] initWithString:UserID] forKey:@"UserID"]; //
        [dataInput setObject:new1 forKey:@"QuestionLines"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"updateQuestionLines.php" andDataInput:dataInput];
        
        //get result
        NSString * success = [jsonData objectForKey:@"success"];
        //NSLog(@"count = %@",[jsonData objectForKey:@"count"]);
        if ([success  isEqual: @"OK"]){
            singleton.globalReceivedNoteQuestionLines = qvString;
            NSLog(@"updateQuestionLines - QuestionsLines = %@", singleton.globalReceivedNoteQuestionLines);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DefineQuestionViewDismissed"
                                                        object:nil
                                                      userInfo:nil];
}

@end
