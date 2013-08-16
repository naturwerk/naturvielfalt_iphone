//
//  ObservationUploadHelper.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import "ObservationUploadHelper.h"
#import "ObservationImage.h"

@implementation ObservationUploadHelper

- (id) init {
    if (self = [super init]) {
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

- (void)submit:(NSObject *)object withRecursion:(BOOL)recursion {
    if (object.class != [Observation class]) {
        return;
    }
    observation = (Observation *) object;
    
    if (!observation.submitted) {
        //new portal
        NSURL *url = [NSURL URLWithString:@"https://naturvielfalt.ch/webservice/api/observation"];
        
        // Get username and password from the UserDefaults
        NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
        
        NSString *username = @"";
        NSString *password = @"";
        
        username = [appSettings stringForKey:@"username"];
        password = [appSettings stringForKey:@"password"];
        
        request = [ASIFormDataRequest requestWithURL:url];
        [request setUsername:username];
        [request setPassword:password];
        [request setValidatesSecureCertificate: YES];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *dateString = [dateFormatter stringFromDate:observation.date];
        
        dateFormatter.dateFormat = @"HH:mm";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *timeString = [dateFormatter stringFromDate:observation.date];
        
        // Prepare data
        NSString *guid = [NSString stringWithFormat:@"%d", observation.guid];
        NSString *inventoryGuid = [NSString stringWithFormat:@"%d", observation.inventory.guid];
        NSString *organism = [NSString stringWithFormat:@"%d", observation.organism.organismId];
        NSString *organismGroupId = [NSString stringWithFormat:@"%d", observation.organism.organismGroupId];
        NSString *count = [NSString stringWithFormat:@"%@", observation.amount];
        NSString *date = [NSString stringWithFormat:@"%@", dateString];
        NSString *time = [NSString stringWithFormat:@"%@", timeString];
        NSString *accuracy = [NSString stringWithFormat:@"%d", observation.accuracy];
        NSString *author = [NSString stringWithString:observation.author];
        NSString *longitude = [NSString stringWithFormat:@"%f", observation.location.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%f", observation.location.coordinate.latitude];
        NSString *comment = [NSString stringWithFormat:@"%@", observation.comment];
        
        // Upload image
        if([observation.pictures count] > 0) {
            for (ObservationImage *obsImg in observation.pictures) {
                if (!obsImg.submitted) {
                    // Create PNG image
                    NSData *imageData = UIImagePNGRepresentation(obsImg.image);
                    
                    // And add the png image into the request
                    [request addData:imageData withFileName:@"iphoneimage.png" andContentType:@"image/png" forKey:@"files[]"];
                }
            }
        }
        [request setPostValue:guid forKey:@"guid"];
        [request setPostValue:inventoryGuid forKey:@"inventory_id"];
        [request setPostValue:organism forKey:@"organism_id"];
        [request setPostValue:organismGroupId forKey:@"organism_artgroup_id"];
        [request setPostValue:count forKey:@"count"];
        [request setPostValue:date forKey:@"date"];
        [request setPostValue:time forKey:@"time"];
        [request setPostValue:accuracy forKey:@"accuracy"];
        [request setPostValue:author forKey:@"observer"];
        [request setPostValue:longitude forKey:@"longitude"];
        [request setPostValue:latitude forKey:@"latitude"];
        [request setPostValue:comment forKey:@"comment"];
        
        asyncRequestDelegate = [[AsyncRequestDelegate alloc] initWithObject:observation];
        [asyncRequestDelegate registerListener:self];
        request.delegate = asyncRequestDelegate;
        [request startAsynchronous];
    } else {
        [listener notifyListener:observation response:@"success=1" observer:self];
    }
}

- (void)update:(NSObject *)object {
    observation = (Observation *)object;
    
    //start async request
}

- (void) registerListener:(id<Listener>)l {
    listener = l;
}

- (void) unregisterListener {
    listener = nil;
}

- (void)registerCollectionListener:(id<Listener>)l {
    collectionListener = l;
}

- (void)unregisterCollectionListener {
    collectionListener = nil;
}

- (void) cancel {
 // Do nothing
    [listener notifyListener:observation response:@"cancel" observer:self];
    [collectionListener notifyCollectionListener:YES observer:self];
}

- (void)notifyListener:(NSObject *)object response:(NSString *)response observer:(id<Observer>)observer{
    [observer unregisterListener];
    if (object.class != [Observation class]) {
        return;
    }
    
    //Save received guid in object, not persisted yet
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"success=[0 || 1]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
    NSString *successString;
    if ([matches count] > 0) {
        successString = [response substringWithRange:[[matches objectAtIndex:0] range]];
    } else {
        NSLog(@"ERROR: NO GUID received!! response: %@", response);
    }

    if ([successString isEqualToString:@"success=1"]) {
        
        //Set submitted flag of all observation images
        for (ObservationImage *obsImg in observation.pictures) {
            obsImg.submitted = YES;
        }
        
        //Save received guid in object, not persisted yet
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"guid=[0-9]*" options:0 error:nil];
        NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
        if ([matches count] > 0) {
            NSString *guidString = [response substringWithRange:[[matches objectAtIndex:0] range]];
            NSArray *guidSplitted = [guidString componentsSeparatedByString:@"="];
            NSString *guid = [guidSplitted objectAtIndex:1];
            observation.guid = [guid intValue];
            observation.submitted = YES;
            NSLog(@"received observation guid: %@", guidString);
            
            // update observation (guid)
            @synchronized ([[UIApplication sharedApplication] delegate]) {
                [persistenceManager establishConnection];
                [persistenceManager updateObservation:observation];
                [persistenceManager closeConnection];
            }
        } else {
            NSLog(@"ERROR: NO GUID received!! response: %@", response);
        }
    } else {
        [collectionListener notifyCollectionListener:YES observer:self];
    }
    [listener notifyListener:observation response:response observer:self];
}

@end
