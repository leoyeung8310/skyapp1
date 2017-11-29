//
//  LogController.m
//  Skyapp
//
//  Created by Cheuk yu Yeung on 16/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "LogController.h"
#import "MySingleton.h"

const int MAX_NUMBER_OF_EVENT_LOG = 5000;

@implementation LogController

- (id)init {
    if (self = [super init]) {
        lastEventType = @"";
        lastEventAction = @"";
        lastTimestamp = @"";
        sumOfPreviousLog = 0;
        
        //init
        [self cleanAndAllocCurrentLog];
        
        //groupOfLog
        groupOfLog = nil;
        groupOfLog = [[NSMutableArray alloc] init];
        
        //update preious log (do it only when loadNote)
        [self decodePreviousEventLog];
    }
    return self;
}

//will be run after success save or submit
- (void) cleanAndAllocCurrentLog{
    eventLog = nil;
    log  = nil;
    
    eventLog = [[NSMutableArray alloc] init];
    log  = [[NSMutableDictionary alloc] init];
    
    //basic info.
    [log setValue:@"1.5" forKey:@"version"];
    [log setValue:@"IPad" forKey:@"device"];
    NSDate *startTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *startTimeStr = [dateFormatter stringFromDate:startTime];
    [log setValue:startTimeStr forKey:@"startTime"];
}

- (void) decodePreviousEventLog{
    MySingleton* singleton = [MySingleton getInstance];
    
    //NSString *length = @"";
    NSData* myData  = nil;
    
    NSString * myLog = [NSString stringWithFormat:@"%@",singleton.globalReceivedNoteEventLog];
    myData = [myLog dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *e;
    
    //add to groupOfLog
    NSMutableArray *myArray = [NSJSONSerialization JSONObjectWithData:myData options:kNilOptions error:&e];
    
    //?how to copy, mutableCopy?
    for (NSMutableDictionary * dict in myArray) {
        [groupOfLog addObject:dict];
    }
    
    [self updateSumOfPreviousLog];
}

- (void) updateSumOfPreviousLog{
    for (NSMutableDictionary * dict in groupOfLog) {
        NSString * count = [dict valueForKey:@"count"];
        sumOfPreviousLog += [count intValue];
    }
    NSLog(@"sumOfPreviousLog = %i",sumOfPreviousLog);
}

- (void) initActivity:(NSString *)activity andSubmitTime:(NSString *)submitTimeStr andLocation:(NSString *)location{
    NSLog(@"initActivity");
    NSArray * key = @[@"submitTime",@"activity",@"location", @"count"];
    NSArray * data = @[submitTimeStr, activity, location, [NSString stringWithFormat:@"%lu",(unsigned long)eventLog.count]];
    for (int i = 0; i < key.count; i++){
        if (![data[i] isEqualToString:@""]){
            [log setValue:data[i] forKey:key[i]];
        }
    }
}

- (void) setLog:(NSString *)key andEvent:(NSString *)data{
    [log setValue:data forKey:key];
}

- (void) setEventType:(NSString *)eventType andEventAction:(NSString *)action andContent:(NSMutableDictionary *)contentDict andTimeStamp:(NSString *)timeStamp{
    bool needDuplicateAvoidType = false;
    //do checking whether this type requires duplicated avoidance
    NSArray * avoidEventType = @[@"dragButton",@"refreshView"];
    NSArray * avoidAction = @[@"dragging",@"do"];
    for (int i = 0; i < avoidEventType.count; i++){
        if ([avoidEventType[i] isEqualToString:eventType] && [avoidAction[i] isEqualToString:action]){
            needDuplicateAvoidType = true;
        }
    }
    
    if (needDuplicateAvoidType && [lastEventType isEqualToString:eventType] && [lastEventAction isEqualToString:action] && [lastTimestamp isEqualToString:timeStamp]){
        //ignore
    }else{
        //not more than MAX # of log
        if (eventLog.count+sumOfPreviousLog < MAX_NUMBER_OF_EVENT_LOG){
            NSMutableDictionary * event = [[NSMutableDictionary alloc] init];
            [event setValue:eventType forKey:@"eventType"];
            [event setValue:action forKey:@"action"];
            [event setValue:contentDict forKey:@"content"];
            [event setValue:timeStamp forKey:@"timestamp"];
            [eventLog addObject:event];
            
            lastEventType = [NSString stringWithFormat:@"%@",eventType];
            lastEventAction = [NSString stringWithFormat:@"%@",action];
            lastTimestamp = [NSString stringWithFormat:@"%@",timeStamp];
        }else{
            NSLog(@"Number of Event Log more than max. value.");
        }
    }
}

- (NSString *) transformToJsonFromat{
    NSLog(@"transformToJsonFromat");
    
    NSString *jsonString = @"";
    [log setValue:eventLog forKey:@"events"];
    NSLog(@"new log = %@",log);

    //?how to copy, mutableCopy?
    NSMutableArray * tempGroupOfLog = [[NSMutableArray alloc] init];
    for (NSMutableDictionary * dict in groupOfLog) {
        [tempGroupOfLog addObject:dict];
    }
    
    [tempGroupOfLog addObject:log];
    NSLog(@"new log is added to tempGroupOfLog");
    [self testingCheckLogCount:tempGroupOfLog];

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempGroupOfLog
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Got an error in jsonData: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

- (void) updateAfterSuccessSaveOrSubmit:(NSString *)eventlog{
    MySingleton* singleton = [MySingleton getInstance];
    singleton.globalReceivedNoteEventLog = [NSString stringWithFormat:@"%@",eventlog];
    [groupOfLog addObject:log];
    [self updateSumOfPreviousLog];
    [self cleanAndAllocCurrentLog];
}

- (void) testingCheckLogCount:(NSMutableArray *) tempGroupOfLog{
    int sum = 0;
    for (NSMutableDictionary * dict in tempGroupOfLog) {
        NSString * count = [dict valueForKey:@"count"];
        sum += [count intValue];
    }
    NSLog(@"testingCheckLogCount = %i",sum);
}

@end
