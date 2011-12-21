//
//  LocationHelper.h
//  Naturvielfalt
//
//  Created by Robin Oster on 10.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationHelper : NSObject <CLLocationManagerDelegate> {

}


- (CLLocationManager *)getLocationManager;

@end
