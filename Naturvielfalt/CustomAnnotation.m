//
//  CustomAnnotation.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 18.04.13.
//
//

#import "CustomAnnotation.h"
#import "Area.h"

@implementation CustomAnnotation
@synthesize annotationType, persisted, coordinate = _coordinate, title, subtitle, area, overlay;

- (id) initWithWithCoordinate:(CLLocationCoordinate2D) coo type:(DrawMode)type area:(Area*)a {
    
    if(self = [super init]) {
        persisted = NO;
        annotationType = type;
        _coordinate = coo;
        area = a;
    }
    return self;
}

- (NSString*)title {
   return area.name;
}

- (NSString*)subtitle {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *nowString = [dateFormatter stringFromDate:area.date];
    
    return nowString;
}
@end
