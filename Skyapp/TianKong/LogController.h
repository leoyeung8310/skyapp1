//
//  LogController.h
//  Skyapp
//
//  Created by Cheuk yu Yeung on 16/8/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogController : NSObject{
    NSMutableArray * eventLog;  //per submit/save   (smallest)
    NSMutableDictionary * log;  //per submit/save
    NSMutableArray * groupOfLog;//per note          (largest)
    NSString * lastEventType;
    NSString * lastEventAction;
    NSString * lastTimestamp;
    int sumOfPreviousLog;
}

- (void) initActivity:(NSString *)activity andSubmitTime:(NSString *)submitTime andLocation:(NSString *)location;
- (void) setLog:(NSString *)key andEvent:(NSString *)data;
- (void) setEventType:(NSString *)eventType andEventAction:(NSString *)action andContent:(NSMutableDictionary *)contentDict andTimeStamp:(NSString *)timeStamp;
- (NSString *) transformToJsonFromat;
- (void) updateAfterSuccessSaveOrSubmit:(NSString *)eventlog;

@end
