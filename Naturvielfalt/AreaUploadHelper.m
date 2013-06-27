//
//  AreaUploadHelper.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import "AreaUploadHelper.h"
#import "Area.h"
#import <Foundation/NSJSONSerialization.h>

@implementation AreaUploadHelper

- (void)submit:(NSObject *)object withRecursion:(BOOL)recursion {
    withRecursion = recursion;
    if (object.class != [Area class]) {
        return;
    }
    area = (Area *) object;
    
    //new portal
    NSURL *url = [NSURL URLWithString:@"https://naturvielfalt.ch/webservice/api/area"];
    
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
    NSString *dateString = [dateFormatter stringFromDate:area.date];
    
    dateFormatter.dateFormat = @"HH:mm";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *timeString = [dateFormatter stringFromDate:area.date];
    
    // Prepare data
    NSString *guid = [NSString stringWithFormat:@"%d", area.guid];
    NSString *name = [NSString stringWithFormat:@"%@", area.name];
    NSString *date = [NSString stringWithFormat:@"%@", dateString];
    NSString *time = [NSString stringWithFormat:@"%@", timeString];
    NSString *type;
    switch (area.typeOfArea) {
        case POINT: type = @"marker"; break;
        case LINE: type = @"polyline"; break;
        case POLYGON: type = @"polygon"; break;
    }
    NSString *author = [NSString stringWithString:area.author];
    NSString *description = [NSString stringWithFormat:@"%@", area.description];
    
    // Upload locationPoints
    NSMutableArray *coordinatesArray = [[NSMutableArray alloc] init];
    for (LocationPoint *lp in area.locationPoints) {
        NSMutableArray *coords = [[NSMutableArray alloc] init];
        [coords addObject:[NSString stringWithFormat:@"%f",lp.longitude]];
        [coords addObject:[NSString stringWithFormat:@"%f",lp.latitude]];
        [coordinatesArray addObject:coords];
    }
    // JSON format
    NSData *coordinates = [NSJSONSerialization dataWithJSONObject:coordinatesArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *coordinatesString = [[NSString alloc] initWithData:coordinates encoding:NSASCIIStringEncoding];
    [request setPostValue:coordinatesString forKey:@"coordinates"];
    NSLog(@"%@", coordinatesString);
    
    // Upload image
    if([area.pictures count] > 0) {
        for (AreaImage *areaImg in area.pictures) {
            if (!areaImg.submitted) {
                // Create PNG image
                NSData *imageData = UIImagePNGRepresentation(areaImg.image);
                
                // And add the png image into the request
                [request addData:imageData withFileName:@"iphoneimage.png" andContentType:@"image/png" forKey:@"files[]"];
            }
        }
    }
    [request setPostValue:guid forKey:@"guid"];
    [request setPostValue:name forKey:@"name"];
    [request setPostValue:date forKey:@"date"];
    [request setPostValue:time forKey:@"time"];
    [request setPostValue:type forKey:@"type"];
    [request setPostValue:author forKey:@"observer"];
    [request setPostValue:description forKey:@"description"];

    asyncRequestDelegate = [[AsyncRequestDelegate alloc] initWithObject:area];
    [asyncRequestDelegate registerListener:self];
    request.delegate = asyncRequestDelegate;
    [request startAsynchronous];
}

- (void)update:(NSObject *)object {
    area = (Area *)object;
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
        for (InventoryUploadHelper *iuh in inventoryUploadHelpers) {
            [iuh cancel];
        }
    }
}

- (void) notifyListener:(NSObject *)object response:(NSString *)response observer:(id<Observer>)observer {
    [observer unregisterListener];
    if ((object.class != [Area class] && object.class != [Inventory class])) {
        return;
    }
    
    
    //Save received guid in object, not persisted yet
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"success=[0 || 1]" options:0 error:nil];
    NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
    NSString *successString;
    if ([matches count] > 0) {
        successString = [response substringWithRange:[[matches objectAtIndex:0] range]];
    } else {
        NSLog(@"ERROR: NO GUID received!!");
    }
    
    // Area submit response
    if (object.class == [Area class]) {
        if ([successString isEqualToString:@"success=1"]) {
            
            //Set submitted flag of all area images
            for (AreaImage *areaImg in area.pictures) {
                areaImg.submitted = YES;
            }
            
            //Save received guid in object, not persisted yet
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"guid=[0-9]*" options:0 error:nil];
            NSArray *matches = [regex matchesInString:response options:0 range:NSMakeRange(0, [response length])];
            NSString *guidString = [response substringWithRange:[[matches objectAtIndex:0] range]];
            NSArray *guidSplitted = [guidString componentsSeparatedByString:@"="];
            NSString *guid = [guidSplitted objectAtIndex:1];
            area.guid = [guid intValue];
            NSLog(@"received area guid: %@", guidString);
            
            // If area submit was successful, start to submit the inventories if recursion is true
            if (withRecursion) {
                if (area.inventories.count == 0) {
                    [listener notifyListener:area response:response observer:self];
                    return;
                }
                if (!inventoryUploadHelpers) {
                    inventoryUploadHelpers = [[NSMutableArray alloc] init];
                }
                for (Inventory *inventory in area.inventories) {
                    InventoryUploadHelper *inventoryUploadHelper = [[InventoryUploadHelper alloc] init];
                    [inventoryUploadHelper registerListener:self];
                    [inventoryUploadHelpers addObject:inventoryUploadHelper];
                    [inventoryUploadHelper submit:inventory withRecursion:withRecursion];
                }
            } else {
                area.submitted = YES;
                [listener notifyListener:area response:response observer:self];
            }
        }
    } else if (object.class == [Inventory class]) {
        inventoryCounter--;

        // If inventory submit was done, decrement counter
        if(inventoryCounter == 0) {
            area.submitted = YES;
            [inventoryUploadHelpers removeAllObjects];
            [listener notifyListener:area response:response observer:self];
        }
    }
}


@end
