//
//  Settings.m
//  Naturvielfalt
//
//  Created by Robin Oster on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"

@implementation Settings
@synthesize urlWebservice, urlSubmitScript;


- (Settings *) getSettings {
    static Settings *settings;
    
    @synchronized(self)
    {
        // Create the instance if it isn't already created
        if (!settings) {
            settings = [[Settings alloc] initWithLocalhost];
        }
        
        return settings;
    }    
}

- (id)init {
    NSLog(@"Calling init");
    
    self = [super init]; 
    return (self);
}

- (id)initWithLocalhost {
    self = [super init]; 
    if (self != nil) {
        urlWebservice = [NSString stringWithString:@"http://localhost/swissmon/application/api/organismgroups/"];
        
        urlSubmitScript = [NSString stringWithString:@"http://localhost/swissmon/webservice/submitData.php"];
    } else {
        NSLog(@"Couldn't initialize object");
        return (self);
    }
}

- (id)initWithServer {
        NSLog(@"Calling init server");
    
    self = [super init]; 
    if (self != nil) {
        urlWebservice = [NSString stringWithString:@"http://devel.naturvielfalt.ch/swissmon/application/api/organismgroups/"];
        urlSubmitScript = [NSString stringWithString:@"http://devel.naturvielfalt.ch/swissmon/webservice/submitData.php"];
    } else {
        NSLog(@"Couldn't initialize object");
        return (self);
    }    
}

@end
