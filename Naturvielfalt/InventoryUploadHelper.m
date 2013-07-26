//
//  InventoryUploadHelper.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import "InventoryUploadHelper.h"
#import "ASIFormDataRequest.h"
#import <Foundation/NSJSONSerialization.h>

@implementation InventoryUploadHelper

- (id) init {
    if (self = [super init]) {
        persistenceManager = [PersistenceManager alloc];
    }
    return self;
}

- (void)submit:(NSObject *)object withRecursion:(BOOL)recursion {
    
    withRecursion = recursion;
    if (object.class != [Inventory class]) {
        return;
    }
    inventory = (Inventory *) object;
    
    observationCounter = inventory.observations.count;
    
    if (!inventory.submitted) {
        //new portal
        NSURL *url = [NSURL URLWithString:@"https://naturvielfalt.ch/webservice/api/inventory"];
        
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
        NSString *dateString = [dateFormatter stringFromDate:inventory.date];
        
        dateFormatter.dateFormat = @"HH:mm";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *timeString = [dateFormatter stringFromDate:inventory.date];
        
        // Prepare data
        NSString *guid = [NSString stringWithFormat:@"%d", inventory.guid];
        NSString *areaGuid = [NSString stringWithFormat:@"%d", inventory.area.guid];
        NSString *name = inventory.name;
        NSString *date = [NSString stringWithFormat:@"%@", dateString];
        NSString *time = [NSString stringWithFormat:@"%@", timeString];
        NSString *author = [NSString stringWithString:inventory.author];
        NSString *description = [NSString stringWithFormat:@"%@", inventory.description];
        
        // Upload images, not implemented for inventory yet
        /*if([inventory.pictures count] > 0) {
         for (InventoryImage *ivImg in inventory.pictures) {
         // Create PNG image
         NSData *imageData = UIImagePNGRepresentation(ivImg.image);
         
         // And add the png image into the request
         [request addData:imageData withFileName:@"iphoneimage.png" andContentType:@"image/png" forKey:@"files[]"];
         }
         }*/
        
        [request setPostValue:guid forKey:@"guid"];
        [request setPostValue:areaGuid forKey:@"area_id"];
        [request setPostValue:name forKey:@"name"];
        [request setPostValue:date forKey:@"date"];
        [request setPostValue:time forKey:@"time"];
        [request setPostValue:author forKey:@"observer"];
        [request setPostValue:description forKey:@"description"];
        
        asyncRequestDelegate = [[AsyncRequestDelegate alloc] initWithObject:inventory];
        [asyncRequestDelegate registerListener:self];
        request.delegate = asyncRequestDelegate;
        [request startAsynchronous];
    } else {
        if (withRecursion) {
            if (inventory.observations.count == 0) {
                [listener notifyListener:inventory response:@"success=1" observer:self];
            }
            if (!observationUploadHelpers) {
                observationUploadHelpers = [[NSMutableArray alloc] init];
            }
            // If inventory submit was successful, start to submit the observations
            for (Observation *observation in inventory.observations) {
                ObservationUploadHelper *observationUploadHelper = [[ObservationUploadHelper alloc] init];
                [observationUploadHelper registerListener:self];
                [observationUploadHelpers addObject:observationUploadHelper];
                [observationUploadHelper submit:observation withRecursion:withRecursion];
            }
        }
    }
}

- (void)update:(NSObject *)object {
    inventory = (Inventory *)object;
    
    //start async request
}

- (void) registerListener:(id<Listener>)l {
    listener = l;
}

- (void) unregisterListener {
    listener = nil;
}

- (void) cancel {
    if (request) {
        [request cancel];
        for (ObservationUploadHelper *ouh in observationUploadHelpers) {
            [ouh cancel];
        }
    }
}

- (void)notifyListener:(NSObject *)object response:(NSString *)response observer:(id<Observer>)observer{
    [observer unregisterListener];
    if ((object.class != [Inventory class] && object.class != [Observation class])) {
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
    
    // Inventory submit response
    if (object.class == [Inventory class]) {
        if ([successString isEqualToString:@"success=1"]) {
            
            //Save received guid in object, not persisted yet
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"guid=[0-9]*" options:0 error:nil];
            NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
            NSString *guidString = [response substringWithRange:[[matches objectAtIndex:0] range]];
            NSArray *guidSplitted = [guidString componentsSeparatedByString:@"="];
            NSString *guid = [guidSplitted objectAtIndex:1];
            inventory.guid = [guid intValue];
            inventory.submitted = YES;
            NSLog(@"received inventory guid: %@", guidString);
            
            // update inventory (guid)
            @synchronized (self) {
                [persistenceManager establishConnection];
                [persistenceManager updateInventory:inventory];
                [persistenceManager closeConnection];
            }
            
            if (withRecursion) {
                if (inventory.observations.count == 0) {
                    [listener notifyListener:inventory response:response observer:self];
                }
                if (!observationUploadHelpers) {
                    observationUploadHelpers = [[NSMutableArray alloc] init];
                }
                // If inventory submit was successful, start to submit the observations
                for (Observation *observation in inventory.observations) {
                    ObservationUploadHelper *observationUploadHelper = [[ObservationUploadHelper alloc] init];
                    [observationUploadHelper registerListener:self];
                    [observationUploadHelpers addObject:observationUploadHelper];
                    [observationUploadHelper submit:observation withRecursion:withRecursion];
                }
            }else {
                [listener notifyListener:inventory response:response observer:self];
            }
        }
    } else if (object.class == [Observation class]) {
        observationCounter--;
        // If inventory submit was done, decrement counter
        if(observationCounter == 0) {
            [observationUploadHelpers removeAllObjects];
            [listener notifyListener:inventory response:response observer:self];
        }
    }
}

@end
