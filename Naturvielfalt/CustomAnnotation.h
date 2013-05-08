//
//  CustomAnnotation.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 18.04.13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Area.h"


@interface CustomAnnotation : NSObject <MKAnnotation> {

    DrawMode annotationType;
    BOOL persisted;
    NSString *title;
    NSString *subtitle;
    Area *area;
    id<MKOverlay> overlay;
}

//@property (nonatomic) Area *area;

- (id) initWithWithCoordinate:(CLLocationCoordinate2D) coo type:(DrawMode)type area:(Area*)a;

@property (nonatomic) DrawMode annotationType;
@property (nonatomic) BOOL persisted;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) Area *area;
@property (nonatomic) id<MKOverlay> overlay;

@end
