//
//  LocationPoint.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.05.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationPoint : NSObject {
    long long int areaId;
    CLLocationCoordinate2D location;
    
}

@property (nonatomic, assign) long long int areaId;
@property (nonatomic) CLLocationCoordinate2D location;

@end
