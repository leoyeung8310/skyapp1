//
//  PickerViewController.m
//  Skyapp
//
//  Created by Cheuk yu Yeung on 12/10/15.
//  Copyright © 2015 Cheuk yu Yeung. All rights reserved.
//

#import "PickerViewController.h"
#import "MySingleton.h"

@interface PickerViewController ()

@end

@implementation PickerViewController

@synthesize myPickerView;
@synthesize itemArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    itemArr =  [NSArray arrayWithObjects:@"Collison Damage Waive",@"Deposit Waiver",@"Excess Reduction Waiver",@"Malaysian Travel Charges Waiver",@"Penalty Waiver",nil];
    selectedIndex = 0;
    [myPickerView setDataSource:self];
    [myPickerView setDelegate:self];
    
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    MySingleton* singleton = [MySingleton getInstance];
    itemArr = nil;
    if (inputType == 0){
        if ([curSubject  isEqual: @"maths"]){
            itemArr = singleton.TOPIC_LIST;
        }
    }else if (inputType == 1){
        if ([curSubject  isEqual: @"maths"]){
            itemArr = [singleton.SUB_TOPIC_LIST objectForKey:curTopic];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [itemArr count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
{
    return [itemArr objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedIndex=(int)row;
}

- (IBAction)handleOK:(id)sender {
    //
    if (itemArr!=nil){
        selectedStr = itemArr[selectedIndex];
    }
    NSLog(@"str = %@", selectedStr);
    if (targetTF != nil && selectedStr != nil){
        targetTF.text = [NSString stringWithFormat:@"%@",selectedStr];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) pointTF:(UITextField *)fromTF setSubject:(NSString *)mySubject setTopic:(NSString *)myTopic setSubTopic:(NSString *)mySubTopic setType:(int)myType{
    targetTF = fromTF;
    curSubject = [NSString stringWithFormat:@"%@",mySubject];
    curTopic = [NSString stringWithFormat:@"%@",myTopic];
    curSubTopic = [NSString stringWithFormat:@"%@",mySubTopic];
    inputType = myType;
}

@end
