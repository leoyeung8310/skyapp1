//
//  SaveController.m
//  TianKong
//
//  Created by Cheuk yu Yeung on 2/6/15.
//  Copyright (c) 2015 Cheuk yu Yeung. All rights reserved.
//

#import "SaveController.h"
#import "DragLabel.h"
#import "DragView.h"
#import "DragTextField.h"
#import "MySingleton.h"

@implementation SaveController

@synthesize serializedData;

- (id)init
{
    NSLog(@"SaveController init");
    self = [super init];
    if (self) {
        //declare location manager
        geocoder = [[CLGeocoder alloc] init];
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate=self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter=kCLDistanceFilterNone;
        
        //FOR IOS 8 or later
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
            NSLog(@"IOS8.0 or later init");
            [locationManager requestWhenInUseAuthorization];
        }
        
        //[locationManager startMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];
    }
    return self;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
    //UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[errorAlert show];
    NSLog(@"Error: %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    MySingleton* singleton = [MySingleton getInstance];
    NSLog(@"didUpdateLocations");
    CLLocation *crnLoc = [locations lastObject];
    
    NSString * latitude = [NSString stringWithFormat:@"%.25f",crnLoc.coordinate.latitude];
    NSString * longitude = [NSString stringWithFormat:@"%.25f",crnLoc.coordinate.longitude];
    
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:crnLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            locInfo = [NSString stringWithFormat:@"%@ %@ %@ %@", latitude, longitude, locatedAt, placemark.subLocality];
            singleton.globalLocInfo = locInfo;
            NSLog(@"locInfo = %@", locInfo);
        } else {
            NSLog(@"%@", error.debugDescription);

        }
    } ];

    [locationManager stopUpdatingLocation];
}

- (NSData *)dataForView:(UIView *)view {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver  *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:view forKey:@"view"];
    [archiver finishEncoding];
    
    return (id)data;
}

- (UIView *)viewForData:(NSData *)data {
    NSKeyedUnarchiver  *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    UIView *view = [unarchiver decodeObjectForKey:@"view"];
    [unarchiver finishDecoding];
    
    return view;
}

-(void) encodeAllObjects:(UIView*) containerView{
    
    NSMutableArray* objArray = [[NSMutableArray alloc]init];
    for (UIView *subview in containerView.subviews){
        
        //each data handling
        
        //drag label
        if([subview isKindOfClass:[DragLabel class]]){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            DragLabel * dLabel = (DragLabel*)subview;
            [dict setObject:@"draglabel" forKey:@"type"];       //all objects required

            NSData *rtfData = [[dLabel getAttStr] dataFromRange:(NSRange){0, [[dLabel getAttStr] length]} documentAttributes:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType} error:NULL];
            NSString * rtfString = [[NSString alloc] initWithData:rtfData encoding:NSUTF8StringEncoding];
            NSLog(@"rtfString = %@",rtfString);
            
            [dict setObject:rtfString forKey:@"rtfString"];
            //[dict setObject:[dLabel getAttStr] forKey:@"string"];
            
            [dict setObject:[NSNumber numberWithFloat:subview.frame.origin.x] forKey:@"frameX"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.origin.y] forKey:@"frameY"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.size.width] forKey:@"frameW"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.size.height] forKey:@"frameH"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.origin.x] forKey:@"boundsX"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.origin.y] forKey:@"boundsY"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.size.width] forKey:@"boundsW"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.size.height] forKey:@"boundsH"];
            [dict setValue:[NSNumber numberWithFloat:[dLabel getSCALE]] forKey:@"scale"];
            [dict setValue:[NSNumber numberWithFloat:[dLabel getTHETA]] forKey:@"theta"];
            [dict setValue:[dLabel getLINK] forKey:@"link"];
            [dict setValue:[dLabel getTITLE] forKey:@"title"];
            [dict setValue:[NSNumber numberWithBool:[dLabel getBOOKMARK]] forKey:@"isBookMark"];
            [dict setValue:[dLabel getANSSTATUS] forKey:@"ansStatus"];
            [dict setValue:[NSNumber numberWithBool:[dLabel getIsAns]] forKey:@"isAns"];
            [objArray addObject:dict];
        }
        //image handling
        if([subview isKindOfClass:[DragView class]]){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            DragView * dView = (DragView*)subview;

            //NSData *myImageData = UIImagePNGRepresentation(dView.image);
            NSString * imageStr = [MySingleton encodeToBase64String:dView.image];
            imageStr = [imageStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            
            //NSLog(@" out imageStr = %@", [NSString stringWithFormat:@"%@",imageStr]);
            
            [dict setObject:@"dragview" forKey:@"type"];       //all objects required
            [dict setObject:imageStr forKey:@"data"];    //all objects required
            [dict setObject:[NSNumber numberWithFloat:subview.frame.origin.x] forKey:@"frameX"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.origin.y] forKey:@"frameY"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.size.width] forKey:@"frameW"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.size.height] forKey:@"frameH"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.origin.x] forKey:@"boundsX"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.origin.y] forKey:@"boundsY"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.size.width] forKey:@"boundsW"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.size.height] forKey:@"boundsH"];
            [dict setValue:[NSNumber numberWithFloat:[dView getSCALE]] forKey:@"scale"];
            [dict setValue:[NSNumber numberWithFloat:[dView getTHETA]] forKey:@"theta"];
            [dict setValue:[dView getLINK] forKey:@"link"];
            [dict setValue:[dView getTITLE] forKey:@"title"];
            [dict setValue:[dView getANSSTATUS] forKey:@"ansStatus"];
            [dict setValue:[NSNumber numberWithBool:[dView getIsAns]] forKey:@"isAns"];
            [dict setValue:[dView getIconStatus] forKey:@"iconStatus"];
            [dict setValue:[NSNumber numberWithBool:[dView getIsIcon]] forKey:@"isIcon"];
            [objArray addObject:dict];
        }
        //drag textfield
        if([subview isKindOfClass:[DragTextField class]]){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
            DragTextField * dtf = (DragTextField*)subview;
            
            [dict setObject:@"dragtextfield" forKey:@"type"];       //all objects required
            [dict setObject:[dtf getSTR] forKey:@"string"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.origin.x] forKey:@"frameX"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.origin.y] forKey:@"frameY"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.size.width] forKey:@"frameW"];
            [dict setObject:[NSNumber numberWithFloat:subview.frame.size.height] forKey:@"frameH"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.origin.x] forKey:@"boundsX"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.origin.y] forKey:@"boundsY"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.size.width] forKey:@"boundsW"];
            [dict setObject:[NSNumber numberWithFloat:subview.bounds.size.height] forKey:@"boundsH"];
            [dict setValue:[NSNumber numberWithFloat:[dtf getSCALE]] forKey:@"scale"];
            [dict setValue:[NSNumber numberWithFloat:[dtf getTHETA]] forKey:@"theta"];
            [dict setValue:[dtf getLINK] forKey:@"link"];
            [dict setValue:[dtf getTITLE] forKey:@"title"];
            [dict setValue:[dtf getANSTEXT] forKey:@"ansText"];
            [dict setValue:[dtf getANSSTATUS] forKey:@"ansStatus"];
            [objArray addObject:dict];  //objArray is NSMutableArray
        }
    }
    NSString *jsonString = @"";
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objArray
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error in jsonData: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    }
    
    MySingleton* singleton = [MySingleton getInstance];
    
    //self.serializedData = [NSKeyedArchiver archivedDataWithRootObject:objArray];
    //singleton.globalReceivedNoteStr = [self.serializedData base64EncodedStringWithOptions:kNilOptions];
    //this is needed since '+' cannot be transferred by POST
    //singleton.globalReceivedNoteStr = [singleton.globalReceivedNoteStr stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    singleton.globalReceivedNoteStr = jsonString;
    
    //For Testing
    //NSString *length = [NSString stringWithFormat:@"%02lu",(unsigned long)[singleton.globalReceivedNoteStr length]];
    //NSLog(@"string length is %@",length);
}

-(void) decodeAllObjects:(UIView*)containerView isViewOnly:(bool)myIsView{
    MySingleton* singleton = [MySingleton getInstance];
    
    //NSString *length = @"";
    NSData* myData  = nil;
    
    if (myIsView){
        //length = [NSString stringWithFormat:@"%02lu",(unsigned long)[singleton.globalReceivedNoteViewOnlyStr length]];
        //singleton.globalReceivedNoteViewOnlyStr = [singleton.globalReceivedNoteViewOnlyStr stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
        //myBase64Data = [[NSData alloc] initWithBase64EncodedString:singleton.globalReceivedNoteViewOnlyStr options:0];
        
        myData = [singleton.globalReceivedNoteViewOnlyStr dataUsingEncoding:NSUTF8StringEncoding];
        
    }else{
        //length = [NSString stringWithFormat:@"%02lu",(unsigned long)[singleton.globalReceivedNoteStr length]];
        //singleton.globalReceivedNoteStr = [singleton.globalReceivedNoteStr stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
        //myBase64Data = [[NSData alloc] initWithBase64EncodedString:singleton.globalReceivedNoteStr options:0];
        
        myData = [singleton.globalReceivedNoteStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSError *e;
    NSMutableArray *myArray = [NSJSONSerialization JSONObjectWithData:myData options:kNilOptions error:&e];
    
    for (NSMutableDictionary * dict in myArray) {
        NSString * type = [dict valueForKey:@"type"];
        if ([type isEqualToString:@"dragtextfield"]){
            NSString * str = (NSString *) [dict valueForKey:@"string"];
            CGRect rect = CGRectMake([[dict valueForKey:@"frameX"] floatValue], [[dict valueForKey:@"frameY"] floatValue], [[dict valueForKey:@"frameW"] floatValue], [[dict valueForKey:@"frameH"] floatValue]);
            CGRect bounds = CGRectMake([[dict valueForKey:@"boundsX"] floatValue], [[dict valueForKey:@"boundsY"] floatValue], [[dict valueForKey:@"boundsW"] floatValue], [[dict valueForKey:@"boundsH"] floatValue]);
            NSString* myLink = [dict valueForKey:@"link"];
            NSString* myTitle = [dict valueForKey:@"title"];
            CGFloat myScale = [[dict valueForKey:@"scale"] floatValue];
            CGFloat myTheta = [[dict valueForKey:@"theta"] floatValue];
            NSString* myAnsText = [dict valueForKey:@"ansText"];
            NSString* myAnsStatus = [dict valueForKey:@"ansStatus"];
            DragTextField *myDTF = [[DragTextField alloc] initWithFrame:rect inputStr:str andFrame:rect andBounds:bounds andLink:myLink andTitle:myTitle andScale:myScale andTheta:myTheta andAnsText:myAnsText andAnsStatus:myAnsStatus];
            [containerView addSubview:myDTF];
        }else if ([type isEqualToString:@"draglabel"]){
            NSString * rtfUTF8String = [dict valueForKey:@"rtfString"];
            NSData* rtfData  = [[NSData alloc] init];
            rtfData = [rtfUTF8String dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSAttributedString * mtuStr = [[NSAttributedString alloc] initWithData:rtfData
                                                                           options:@{NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType}
                                                                documentAttributes:NULL
                                                                             error:&error];
            CGRect rect = CGRectMake([[dict valueForKey:@"frameX"] floatValue], [[dict valueForKey:@"frameY"] floatValue], [[dict valueForKey:@"frameW"] floatValue], [[dict valueForKey:@"frameH"] floatValue]);
            CGRect bounds = CGRectMake([[dict valueForKey:@"boundsX"] floatValue], [[dict valueForKey:@"boundsY"] floatValue], [[dict valueForKey:@"boundsW"] floatValue], [[dict valueForKey:@"boundsH"] floatValue]);
            NSString* myLink = [dict valueForKey:@"link"];
            NSString* myTitle = [dict valueForKey:@"title"];
            CGFloat myScale = [[dict valueForKey:@"scale"] floatValue];
            CGFloat myTheta = [[dict valueForKey:@"theta"] floatValue];
            bool myIsBookMark= [[dict valueForKey:@"isBookMark"] boolValue];
            NSString* myAnsStatus = [dict valueForKey:@"ansStatus"];
            bool myIsAns= [[dict valueForKey:@"isAns"] boolValue];

            DragLabel *myLabel = [[DragLabel alloc] initWithFrame:CGRectZero inputStr:mtuStr andFrame:rect andBounds:bounds andLink:myLink andTitle:myTitle andScale:myScale andTheta:myTheta isBookMark:myIsBookMark andAnsStatus:myAnsStatus andIsAns:myIsAns];
            [containerView addSubview:myLabel];
        }
        else if ([type isEqualToString:@"dragview"]){
            //NSLog(@" in imageStr = %@", [NSString stringWithFormat:@"%@", [dict valueForKey:@"data"]] );
            
            NSString * imageStr = [[dict valueForKey:@"data"] stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
            UIImage* img=[MySingleton decodeBase64ToImage:imageStr];
            CGRect rect = CGRectMake([[dict valueForKey:@"frameX"] floatValue], [[dict valueForKey:@"frameY"] floatValue], [[dict valueForKey:@"frameW"] floatValue], [[dict valueForKey:@"frameH"] floatValue]);
            CGRect bounds = CGRectMake([[dict valueForKey:@"boundsX"] floatValue], [[dict valueForKey:@"boundsY"] floatValue], [[dict valueForKey:@"boundsW"] floatValue], [[dict valueForKey:@"boundsH"] floatValue]);
            CGFloat scale = [[dict valueForKey:@"scale"] floatValue];
            CGFloat theta = [[dict valueForKey:@"theta"] floatValue];
            NSString* myLink = [dict valueForKey:@"link"];
            NSString* myTitle = [dict valueForKey:@"title"];
            NSString* myAnsStatus = [dict valueForKey:@"ansStatus"];
            bool myIsAns= [[dict valueForKey:@"isAns"] boolValue];
            NSString* myIconStatus = [dict valueForKey:@"iconStatus"];
            bool myIsIcon= [[dict valueForKey:@"isIcon"] boolValue];
            DragView *myView = [[DragView alloc] initWithImage:img andFrame:rect andBounds:bounds andSCALE:scale andTHETA:theta andLink:myLink andTitle:myTitle andAnsStatus:myAnsStatus andIsAns:myIsAns andIconStatus:myIconStatus andIsIcon:myIsIcon];
            [containerView addSubview:myView];
        }
    }
}


-(bool)loadNoteBy:(NSString *)NoteID andServer:(NSString *)Server isViewOnly:(bool)myIsView{
    MySingleton* singleton = [MySingleton getInstance];
    if (!myIsView){
        singleton.globalReceivedNoteStr = @"";
        singleton.globalReceivedNoteBackgroundImageStr = @"";
        singleton.globalAnswerID = @"";
        singleton.globalQuestionID = @"";
        singleton.globalReceivedNoteStatus = @"";
        singleton.globalReceivedNoteSubject = @"";
        singleton.globalReceivedNoteTopic = @"";
        singleton.globalReceivedNoteSubTopic = @"";
        singleton.globalReceivedNoteKeywords = @"";
        singleton.globalReceivedNoteRemarks = @"";
        singleton.globalReceivedNoteDifficulty = @"";
        singleton.globalReceivedNoteHighlightAns = @"";
        singleton.globalReceivedNoteGiveGift = @"";
        singleton.globalReceivedNoteTimeLimit = @"";
        singleton.globalReceivedNoteMaxTrial = @"";
        singleton.globalReceivedNoteEventLog = @"";
        singleton.globalReceivedNoteQuestionLines = @"";
    }else{
        singleton.globalReceivedNoteViewOnlyStr = @"";
        singleton.globalReceivedNoteViewOnlyStatus = @"";
        singleton.globalReceivedNoteViewOnlyBackgroundImageStr = @"";
    }

    bool boolSuccess = false;
    NSLog(@"loadNoteBy - NoteID = %@",NoteID);
    
    if([NoteID isEqualToString:@""] ) {
        //
    } else {
        //input
        NSMutableDictionary *dataInput = [[NSMutableDictionary alloc]init];
        [dataInput setObject:[[NSString alloc] initWithString:NoteID] forKey:@"NoteID"]; //
        
        //connect server
        NSMutableDictionary *jsonData;
        jsonData = [MySingleton jsonPostMultipleNSStringTo:Server andSubLink:@"loadNote.php" andDataInput:dataInput];
        NSLog(@"loadNoteBy data from network");
        //get result
        NSString * success = [jsonData objectForKey:@"success"];

        if ([success  isEqual: @"OK"]){
            NSLog(@"loadNoteBy OK");
            NSDictionary * noteDict = [[jsonData objectForKey:@"data"] objectAtIndex:0];
            NSString * NoteContent = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"NoteContent"]]; //* avoid null value
            NSString * BackgroundImage = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"BackgroundImage"]]; //* avoid null value
            NSString * Status = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"Status"]]; //* avoid null value
            NSString * AnswerID = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"AnswerID"]]; //* avoid null value
            NSString * QuestionID = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"QuestionID"]]; //* avoid null value
            
            NSString * Subject = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"Subject"]]; //* avoid null value
            NSString * Topic = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"Topic"]]; //* avoid null value
            NSString * SubTopic = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"SubTopic"]]; //* avoid null value
            NSString * Keywords = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"Keywords"]]; //* avoid null value
            NSString * Remarks = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"Remarks"]]; //* avoid null value
            NSString * Difficulty = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"Difficulty"]]; //* avoid null value
            NSString * DifficultyPresentation = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"DifficultyPresentation"]]; //* avoid null value
            NSString * HighlightAns = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"HighlightAns"]]; //* avoid null value
            NSString * GiveGift = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"GiveGift"]]; //* avoid null value
            NSString * TimeLimit = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"TimeLimit"]]; //* avoid null value
            NSString * MaxTrial = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"MaxTrial"]]; //* avoid null value
            
            //from answerTable
            NSString * NoOfTrial = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"NoOfTrial"]]; //* avoid null value
            NSString * EventLog = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"EventLog"]];
            NSString * QuestionLines = [NSString stringWithFormat:@"%@",[noteDict objectForKey:@"QuestionLines"]];
            
            //for testing
            /*
             //NSLog(@"NoteContent = %@", NoteContent);
             if ([NoteContent isEqualToString:singleton.globalReceivedNoteStr]){
             NSLog(@"---SAME NOTE FOUND---");
             }else{
             
             NSLog(@"---NOT SAME---");
             
             // -- for testing
             for(int i = 0; i < (unsigned long)[singleton.globalReceivedNoteStr length]; i++){
             NSString *c1 = [NSString stringWithFormat:@"%c", [NoteContent characterAtIndex:i]];
             NSString *c2 = [NSString stringWithFormat:@"%c", [singleton.globalReceivedNoteStr characterAtIndex:i]];
             if (![c1 isEqualToString:c2]){
             NSLog(@"No at %d, %@, %@", i, c1, c2);
             }
             }
             
             }
             */
            if (!myIsView){
                singleton.globalReceivedNoteStr = NoteContent;
                singleton.globalReceivedNoteBackgroundImageStr = BackgroundImage;
                singleton.globalReceivedNoteStatus = Status;
                singleton.globalAnswerID = AnswerID;
                singleton.globalQuestionID = QuestionID;
                
                singleton.globalReceivedNoteSubject = Subject;
                singleton.globalReceivedNoteTopic = Topic;
                singleton.globalReceivedNoteSubTopic = SubTopic;
                singleton.globalReceivedNoteKeywords = Keywords;
                singleton.globalReceivedNoteRemarks = Remarks;
                singleton.globalReceivedNoteDifficulty = Difficulty;
                singleton.globalReceivedNoteDifficultyPresentation = DifficultyPresentation;
                singleton.globalReceivedNoteHighlightAns = HighlightAns;
                singleton.globalReceivedNoteGiveGift = GiveGift;
                singleton.globalReceivedNoteTimeLimit = TimeLimit;
                singleton.globalReceivedNoteMaxTrial = MaxTrial;
                singleton.globalReceivedNoteNoOfTrial = NoOfTrial;
                singleton.globalReceivedNoteEventLog = EventLog;
                singleton.globalReceivedNoteQuestionLines = QuestionLines;
            }else{
                singleton.globalReceivedNoteViewOnlyStr = NoteContent;
                singleton.globalReceivedNoteViewOnlyStatus = Status;
                singleton.globalReceivedNoteViewOnlyBackgroundImageStr = BackgroundImage;
            }
            
            //testing
            /*
             NSString *length = [NSString stringWithFormat:@"%02lu",(unsigned long)[singleton.globalReceivedNoteStr length]];
             NSLog(@"Coming string length is %@",length);
             NSLog(@"Coming Status is %@",Status);
             */
            
    
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


@end
