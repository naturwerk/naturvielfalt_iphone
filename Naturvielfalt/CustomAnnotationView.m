//
//  CustomAnnotationView.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 19.04.13.
//
//
#import "CustomAnnotationView.h"

@implementation CustomAnnotationView
@synthesize imageView;

#define pHeight 20
#define pWidth  20
#define pBorder  2
#define sHeight  9
#define sWidth   9
#define sBorder  2

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    CustomAnnotation *myAnnotation = (CustomAnnotation*)annotation;
    
    switch (myAnnotation.annotationType) {
        case POINT:
        {
            self = [super initWithAnnotation:myAnnotation reuseIdentifier:reuseIdentifier];
            
            if (!myAnnotation.persisted) {
                MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:myAnnotation reuseIdentifier:reuseIdentifier];
                pinView.pinColor = MKPinAnnotationColorGreen;
                pinView.animatesDrop = YES;
                
                return (CustomAnnotationView*) pinView;
            } else {
                self.frame = CGRectMake(0, 0, pWidth, pHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-pin.png"]];
                imageView.frame = CGRectMake(0, 0, pWidth, pHeight);
                
                self.backgroundColor = [UIColor clearColor];
                [self addSubview:imageView];
                self.canShowCallout = YES;
            }
            break;
        }
            
        case LINE:
        {
            self = [super initWithAnnotation:myAnnotation reuseIdentifier:reuseIdentifier];
            
            if (!myAnnotation.persisted) {
                self.frame = CGRectMake(0, 0, sWidth, sHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startPoint.png"]];
                imageView.frame = CGRectMake(0, 0, sWidth, sHeight);
            } else {
                self.frame = CGRectMake(0, 0, pWidth, pHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-line.png"]];
                imageView.frame = CGRectMake(0, 0, pWidth, pHeight);
                self.canShowCallout = YES;
            }
            self.backgroundColor = [UIColor clearColor];
            [self addSubview:imageView];
            break;
        }
            
        case POLYGON:
        {
            self = [super initWithAnnotation:myAnnotation reuseIdentifier:reuseIdentifier];
            
            if (!myAnnotation.persisted) {
                self.frame = CGRectMake(0, 0, sWidth, sHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startPoint.png"]];
                imageView.frame = CGRectMake(0, 0, sWidth, sHeight);
            } else {
                self.frame = CGRectMake(0, 0, pWidth, pHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-polygon.png"]];
                imageView.frame = CGRectMake(0, 0, pWidth, pHeight);
                self.canShowCallout = YES;
            }
            self.backgroundColor = [UIColor clearColor];
            [self addSubview:imageView];
            break;
        }
    }
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    
    return self;
}

@end
