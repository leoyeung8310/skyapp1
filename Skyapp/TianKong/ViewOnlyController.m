//
//  ViewOnlyController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "ViewOnlyController.h"
#import "MySingleton.h"
#import "DragTextField.h"
#import "DragView.h"
#import "DragLabel.h"

@interface ViewOnlyController ()

@end

@implementation ViewOnlyController


@synthesize scrollView;
@synthesize containerView;
@synthesize backgroundView;
@synthesize backBtn;
@synthesize drawBtn;
@synthesize viewBtn;

//for save
@synthesize mySaveController;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad note");
    
    //UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    //[self.containerView addGestureRecognizer:singleFingerTap];
    self.containerView.multipleTouchEnabled=NO;
    self.containerView.exclusiveTouch =YES;
    
    //refresh scrollView and containerView
    scrollView.contentSize=CGSizeMake(containerView.frame.size.width, containerView.frame.size.height+400);
    scrollView.showsVerticalScrollIndicator = YES;
    
    UIImage * plainGreyImage = [MySingleton imageWithColor:[UIColor lightGrayColor] size:CGSizeMake(containerView.frame.size.width,500)];
    UIImageView *  imageCoverTop = [[UIImageView alloc] initWithImage:plainGreyImage];
    imageCoverTop.frame = CGRectMake(0,-500, containerView.frame.size.width, 500);
    [scrollView addSubview:imageCoverTop];
    UIImageView *  imageCoverBot = [[UIImageView alloc] initWithImage:plainGreyImage];
    imageCoverBot.frame = CGRectMake(0,containerView.frame.size.height, containerView.frame.size.width, 500);
    [scrollView addSubview:imageCoverBot];
    
    //for save
    mySaveController = [[SaveController alloc]init];
    
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //load notecontent from DB
    MySingleton* singleton = [MySingleton getInstance];
    loadNoteSuccess = [mySaveController loadNoteBy:singleton.globalViewOnlyNoteID andServer:singleton.globalUserServer isViewOnly:true]; //this one is diff. from NoteViewController
    
    if (loadNoteSuccess){
        //check not only space
        [mySaveController decodeAllObjects:self.containerView isViewOnly:true]; //this one is diff. from NoteViewController
        
        controlStatus = @""; //view, draw
        
        //load background image
        NSString * bgContent = [NSString stringWithFormat:@"%@",singleton.globalReceivedNoteViewOnlyBackgroundImageStr]; //* avoid null value
        if (bgContent != nil && ![bgContent  isEqual: @""] && ![bgContent  isEqual: @"<null>"]){
            //NSLog(@"tnContent = %@", tnContent);
            bgContent = [bgContent stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
            //NSData * bgBase64Data = [[NSData alloc] initWithBase64EncodedString:bgContent options:0];
            //backgroundImg = [[UIImage alloc] initWithData:bgBase64Data];
            backgroundImg=[MySingleton decodeBase64ToImage:bgContent];
            [self storeBGView:backgroundImg];
        }
        
        [self refreshBackgroundViewByStatus];
    }else{
        NSLog(@"Loading note fail");
    }
    
    if (!loadNoteSuccess){
        [self handleLeave:nil]; //Diff.
    }
    NSString * status = singleton.globalReceivedNoteViewOnlyStatus; //Diff.
    bool isPre = [status rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [status rangeOfString:@"Post"].location != NSNotFound;
    
    if (isPre){
        [self doWaitingAnsSetting];
    }else if (isPost){
        [self doSubmittedAnsSetting];
    }
    
    //buttons depend on user type
    [self refreshScreen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleDraw:(id)sender {
    //[self cancelAllViewSelections];
    controlStatus = @"draw";
}

- (IBAction)handleView:(id)sender {
    controlStatus = @"view";
}

- (IBAction)handleLeave:(id)sender {
    NSLog(@"handleLeave");
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void) refreshBackgroundViewByStatus{
    MySingleton* singleton = [MySingleton getInstance];
    NSString * status = singleton.globalReceivedNoteViewOnlyStatus; //Diff from NoteViewController
    if ([status rangeOfString:@"normal"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"whiteboard"]];
    }else if ([status rangeOfString:@"exercise"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"metalboard"]];
    }else if ([status rangeOfString:@"test"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"graphboard"]];
    }else if ([status rangeOfString:@"competition"].location != NSNotFound){
        [backgroundView setImage:[UIImage imageNamed: @"corkboard"]];
    }else{
        [backgroundView setImage:[UIImage imageNamed: @"chalkboard"]];
    }
}

//Diff. From NoteViewController
- (void) doWaitingAnsSetting{
    //hide and disable button
    NSLog(@"doWaitingAnsSetting");
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * dtf = (DragTextField *) subview;
            [dtf handleWaitAns];
        }
    }
    
    //highlight wrong ans
    [self highlightWrongAnswers];
}

//Diff. From NoteViewController
- (void) doSubmittedAnsSetting{
    //hide and disable button
    NSLog(@"doSubmittedAnsSetting");
    
    //highlight wrong ans
    [self highlightWrongAnswers];
}

- (void) highlightWrongAnswers{
    for (UIView *subview in self.containerView.subviews){
        if([subview isKindOfClass:[DragTextField class]]){
            DragTextField * obj = (DragTextField *) subview;
            if (![obj.text  isEqual: [obj getANSTEXT]] || [obj.text  isEqual: @""]){
                //indicate it is wrong or empty
                [obj highlightBox];
            }else{
                NSLog(@"dehighlightBox");
                [obj dehighlightBox];
            }
        }
    }
}

- (void) refreshScreen{
    MySingleton* singleton = [MySingleton getInstance];
    
    //normal buttons
    backBtn.enabled=true;
    
    if ([controlStatus  isEqual: @"draw"]){
        self.scrollView.scrollEnabled=NO;
        drawBtn.enabled=true;
        viewBtn.enabled=false;
    }else if ([controlStatus  isEqual: @"view"]){
        self.scrollView.scrollEnabled=YES;
        drawBtn.enabled=false;
        viewBtn.enabled=true;
    }else{
        self.scrollView.scrollEnabled=YES;
        drawBtn.enabled=false;
        viewBtn.enabled=false;
    }
    
    NSString * status = singleton.globalReceivedNoteViewOnlyStatus;
    bool isPre = [status rangeOfString:@"Pre"].location != NSNotFound;
    bool isPost = [status rangeOfString:@"Post"].location != NSNotFound;
    //is non-teacher
    if (isPre || isPost){
        //user
        for (UIView *subview in self.containerView.subviews){
            if([subview isKindOfClass:[DragTextField class]]){
                subview.userInteractionEnabled=NO;
                //DragTextField * obj = (DragTextField *) subview;
                
            }else if([subview isKindOfClass:[DragView class]]){
                subview.userInteractionEnabled=NO;
                DragView * obj = (DragView *)subview;
                if ([obj getIsAns])
                    obj.hidden=true;
            }else if([subview isKindOfClass:[DragLabel class]]){
                subview.userInteractionEnabled=NO;
                DragLabel * obj = (DragLabel *)subview;
                if ([obj getIsAns])
                    obj.hidden=true;
            }
        }
    }
    
}

- (void)storeBGView:(UIImage *)image{
    NSLog(@"storeBGViewOnly");
    containerView.backgroundColor = [UIColor colorWithPatternImage:image];
}



@end
