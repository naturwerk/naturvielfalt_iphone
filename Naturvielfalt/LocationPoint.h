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
    double longitude;
    double latitude;
}

@property (nonatomic, assign) long long int areaId;
@property (nonatomic) double longitude;
@property (nonatomic) double latitude;

@end
