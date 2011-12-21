//
//  LocationHelper.m
//  Naturvielfalt
//
//  Created by Robin Oster on 10.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationHelper.h"

@implementation LocationHelper

- (CLLocationManager *)getLocationManager
{
    static CLLocationManager *locationManager;

    @synchronized(self)
    {
        // Create the instance if it isn't already created
        if (!locationManager) {
            locationManager = [[CLLocationManager alloc] init];
        }
        
        return locationManager;
    }
}


@end
