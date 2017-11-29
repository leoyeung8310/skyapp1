//
//  TextViewController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 29/5/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "TextViewController.h"
#import "MySingleton.h"

const CGFloat FONT_SIZE = 18;

@interface TextViewController ()

@end

@implementation TextViewController

@synthesize myTextView;
@synthesize saveBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //localization
    MySingleton* singleton = [MySingleton getInstance];
    NSString* confirmText = NSLocalizedStringFromTableInBundle(@"OK", nil, singleton.globalLocaleBundle, nil);
    self.saveBtn.title = [NSString stringWithFormat:@"%@", confirmText];
    
    // Do any additional setup after loading the view.
    saveBtn.enabled=false;  //until it is not empty
    
    //reset share menu
    UIMenuController * menu = [UIMenuController sharedMenuController];
    NSMutableArray *options = [NSMutableArray array];
    [menu setMenuItems:options];
    
    //myTextView delegate
    myTextView.delegate=self;
    
    //original text and font
    UIFont *regularFont = [UIFont systemFontOfSize:FONT_SIZE];
    myTextView.font = regularFont;
    
    hasCurrentLabel = false;
    
}

- (void) addText:(NSAttributedString *)myOriStr{
    myTextView.attributedText = myOriStr;
    hasCurrentLabel = true;
    saveBtn.enabled = true;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [myTextView becomeFirstResponder];
}

- (bool) getHasCurrentLabel{
    return hasCurrentLabel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNormal {
    NSLog(@"doNormalText");
    NSRange selectedRange = myTextView.selectedRange;
    if (selectedRange.location != NSNotFound && selectedRange.length > 0) {
        UIFont *regularFont = [UIFont systemFontOfSize:FONT_SIZE];
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText = myTextView.attributedText.mutableCopy;
        [attributedText addAttribute:NSFontAttributeName
                               value:regularFont
                               range:selectedRange];
        // Set it in our UILabel and we are done!
        [myTextView setAttributedText:attributedText];
    }
}

- (void)handleBold {
    NSLog(@"doBoldText");
    NSRange selectedRange = myTextView.selectedRange;
    if (selectedRange.location != NSNotFound && selectedRange.length > 0) {
        UIFont *boldFont = [UIFont boldSystemFontOfSize:FONT_SIZE];
        
        // Create the attributed string (text + attributes)
        NSMutableAttributedString *attributedText = myTextView.attributedText.mutableCopy;
        [attributedText addAttribute:NSFontAttributeName
                               value:boldFont
                               range:selectedRange];
        // Set it in our UILabel and we are done!
        [myTextView setAttributedText:attributedText];
    }
}

- (IBAction)handleSave:(id)sender {
    NSLog(@"SAVE");
    saveBtn.enabled=false;
    [self performSelector:@selector(noticeDismiss) withObject:self afterDelay:0.001];
}

-(void)noticeDismiss{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TextViewControllerDismissed"
                                                        object:self
                                                      userInfo:nil];
}

//delegate UITextViewDelegate for selection change
- (void) textViewDidChangeSelection:(UITextView *)textView
{
    NSLog(@"Fire change selection.");
    
    //if have selected text, show menu with T and B. Otherwise, no
    NSRange selectedRange = myTextView.selectedRange;
    if (selectedRange.location != NSNotFound && selectedRange.length > 0) {
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"T" action:@selector(handleNormal)];
        [options addObject:item2];
        UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:@"B" action:@selector(handleBold)];
        [options addObject:item3];
        [menu setMenuItems:options];
    }else{
        UIMenuController * menu = [UIMenuController sharedMenuController];
        NSMutableArray *options = [NSMutableArray array];
        [menu setMenuItems:options];
    }

}

//delegate UITextViewDelegate for textview text change
- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"Fire text change.");
    
    //log
    MySingleton* singleton = [MySingleton getInstance];
    NSArray * key = @[@"text"];
    NSArray * data = @[
                       [NSString stringWithFormat:@"%@",myTextView.text]
                       ];
    //log
    NSMutableDictionary * content = [MySingleton putTwoArraysIntoDict:key andData:data];
    [singleton.logCon setEventType:@"keyboardOnTextView" andEventAction:@"textChange" andContent:content andTimeStamp:[MySingleton getTimeStr]];
    
    NSString *trimmedString = [myTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedString isEqual: @""]){
        saveBtn.enabled=false;
    }else{
        saveBtn.enabled=true;
    }
}

@end
