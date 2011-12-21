//
//  SwissCoordinates.m
//  Naturvielfalt
//
//  Created by Robin Oster on 30.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SwissCoordinates.h"

@implementation SwissCoordinates

- (NSArray *) calculate:(double)longitude latitude:(double)latitude 
{
    // PHI      -> LATITUDE
    // LAMBDA    -> LONGITUDE
    // Calculation based on: http://de.wikipedia.org/wiki/Schweizer_Landeskoordinaten
    
    // LONGITUDE
    double longitudeDegrees = (int)longitude;
    double longitudeMinutes = (int)((longitude - longitudeDegrees) * 60.0);
    double longitudeSeconds = (((longitude - longitudeDegrees) * 60.0) - longitudeMinutes) * 60;
    
    double lambda = (longitudeDegrees * 3600.0) + (longitudeMinutes * 60.0) + longitudeSeconds;

    // LATITUDE
    double latitudeDegrees = (int)latitude;
    double latitudeMinutes = (int)((latitude - latitudeDegrees) * 60.0);
    double latitudeSeconds = (((latitude - latitudeDegrees) * 60.0) - latitudeMinutes) * 60;

    double phi = (latitudeDegrees * 3600.0) + (latitudeMinutes * 60.0) + latitudeSeconds;
  
    // CALCULATIONS
    double phiT = (phi - 169028.66)/10000.0;
    double lambdaT = (lambda - 26782.5) / 10000.0;
    
    
    // Calculate swiss coordinates
    double x = 200147.07 + 308807.95 * phiT + 3745.25 * lambdaT*lambdaT + 76.63 * phiT*phiT + 119.79 * phiT*phiT*phiT - 194.56 * lambdaT*lambdaT * phiT;
    double y = 600072.37 + 211455.93 * lambdaT - 10938.51 * lambdaT * phiT - 0.36 * lambdaT * phiT*phiT - 44.54 * lambdaT*lambdaT*lambdaT;
    
    NSNumber *latitudeNumber = [NSNumber numberWithDouble:x];
    NSNumber *longitudeNumber = [NSNumber numberWithDouble:y];

    // Pack the return values in an array
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    [returnArray addObject:longitudeNumber];
    [returnArray addObject:latitudeNumber];
    
    return returnArray;
}

@end
