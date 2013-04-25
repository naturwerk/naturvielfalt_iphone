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
#define lHeight 30
#define lWidth  30
#define sHeight  9
#define sWidth   9
#define sBorder  2

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier navigationController:(UINavigationController*) naviController{
    
    customAnnotation = (CustomAnnotation*)annotation;
    navigationController = naviController;
    
    switch (customAnnotation.annotationType) {
        case POINT:
        {
            self = [super initWithAnnotation:customAnnotation reuseIdentifier:reuseIdentifier];
            
            if (!customAnnotation.persisted) {
                MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:customAnnotation reuseIdentifier:reuseIdentifier];
                pinView.pinColor = MKPinAnnotationColorGreen;
                pinView.animatesDrop = YES;
                
                return (CustomAnnotationView*) pinView;
            } else {
                

                
                self.frame = CGRectMake(0, 0, pWidth, pHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-pin.png"]];
                imageView.frame = CGRectMake(0, 0, pWidth, pHeight);
                
                self.backgroundColor = [UIColor clearColor];
                [self addSubview:imageView];
                
                UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-pin.png"]];
                leftIconView.frame = CGRectMake(0, 0, lWidth, lHeight);
                self.leftCalloutAccessoryView = leftIconView;
                
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [rightButton addTarget:self action:@selector(showSettingsPressed:) forControlEvents:UIControlEventTouchUpInside];
                self.rightCalloutAccessoryView = rightButton;
                
                self.canShowCallout = YES;
            }
            break;
        }
            
        case LINE:
        {
            self = [super initWithAnnotation:customAnnotation reuseIdentifier:reuseIdentifier];
            
            if (!customAnnotation.persisted) {
                self.frame = CGRectMake(0, 0, sWidth, sHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startPoint.png"]];
                imageView.frame = CGRectMake(0, 0, sWidth, sHeight);
            } else {
                self.frame = CGRectMake(0, 0, pWidth, pHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-line.png"]];
                imageView.frame = CGRectMake(0, 0, pWidth, pHeight);
                
                UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-line.png"]];
                leftIconView.frame = CGRectMake(0, 0, lWidth, lHeight);
                self.leftCalloutAccessoryView = leftIconView;
                
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [rightButton addTarget:self action:@selector(showSettingsPressed:) forControlEvents:UIControlEventTouchUpInside];
                self.rightCalloutAccessoryView = rightButton;
                
                self.canShowCallout = YES;
            }
            self.backgroundColor = [UIColor clearColor];
            [self addSubview:imageView];
            break;
        }
            
        case POLYGON:
        {
            self = [super initWithAnnotation:customAnnotation reuseIdentifier:reuseIdentifier];
            
            if (!customAnnotation.persisted) {
                self.frame = CGRectMake(0, 0, sWidth, sHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"startPoint.png"]];
                imageView.frame = CGRectMake(0, 0, sWidth, sHeight);
            } else {
                self.frame = CGRectMake(0, 0, pWidth, pHeight);
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-polygon.png"]];
                imageView.frame = CGRectMake(0, 0, pWidth, pHeight);
                
                UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-polygon.png"]];
                leftIconView.frame = CGRectMake(0, 0, lWidth, lHeight);
                self.leftCalloutAccessoryView = leftIconView;
                
                UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [rightButton addTarget:self action:@selector(showSettingsPressed:) forControlEvents:UIControlEventTouchUpInside];
                self.rightCalloutAccessoryView = rightButton;
                
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

- (IBAction)showSettingsPressed:(id)sender {
    NSLog(@"showSettingsPressed");
    
    if (!areasSubmitController) {
        areasSubmitController = [[AreasSubmitController alloc]
                                 initWithNibName:@"AreasSubmitController"
                                 bundle:[NSBundle mainBundle]];
    }
    
    if (navigationController) {
        
        areasSubmitController.area = customAnnotation.area;
        // Switch the View & Controller
        // POP
        [navigationController popViewControllerAnimated:TRUE];
        
        // PUSH
        [navigationController pushViewController:areasSubmitController animated:TRUE];
    }
}

@end
