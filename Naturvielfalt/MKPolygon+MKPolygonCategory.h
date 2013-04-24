//
//  MKPolygon+MKPolygonCategory.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 24.04.13.
//
//

#import <MapKit/MapKit.h>
#import "Area.h"

@interface MKPolygon (MKPolygonCategory)

@property (readwrite) BOOL persisted;
@property (readwrite) DrawMode type;
@property (readwrite) Area *area;

@end
