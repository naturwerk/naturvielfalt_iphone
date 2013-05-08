//
//  CustomObservationAnnotationView.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 07.05.13.
//
//

#import "CustomObservationAnnotationView.h"

@implementation CustomObservationAnnotationView

#define lHeight 30
#define lWidth  30

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    observationAnnotation = (CustomObservationAnnotation *)annotation;
    
    self = [super initWithAnnotation:observationAnnotation reuseIdentifier:reuseIdentifier];
    
    switch (observationAnnotation.areaType) {

        case POINT:
        {
            self = [super initWithAnnotation:observationAnnotation reuseIdentifier:reuseIdentifier];
            self.pinColor = MKPinAnnotationColorRed;
            self.animatesDrop = NO;
            self.canShowCallout = YES;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-pin.png"]];
            imageView.frame = CGRectMake(0, 0, lWidth, lHeight);
            self.leftCalloutAccessoryView = imageView;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showSettingsPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.rightCalloutAccessoryView = rightButton;
            
            break;
        }
        case LINE:
        {
            self = [super initWithAnnotation:observationAnnotation reuseIdentifier:reuseIdentifier];
            self.pinColor = MKPinAnnotationColorPurple;
            self.animatesDrop = NO;
            self.canShowCallout = YES;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-line.png"]];
            imageView.frame = CGRectMake(0, 0, lWidth, lHeight);
            self.leftCalloutAccessoryView = imageView;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showSettingsPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.rightCalloutAccessoryView = rightButton;
            
            break;
        }
        case POLYGON:
        {
            self = [super initWithAnnotation:observationAnnotation reuseIdentifier:reuseIdentifier];
            self.pinColor = MKPinAnnotationColorGreen;
            self.animatesDrop = NO;
            self.canShowCallout = YES;
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"symbol-polygon.png"]];
            imageView.frame = CGRectMake(0, 0, lWidth, lHeight);
            self.leftCalloutAccessoryView = imageView;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showSettingsPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.rightCalloutAccessoryView = rightButton;
            
            break;
        }
            
        default:
        {
            // if it is no area observation
            self = [super initWithAnnotation:observationAnnotation reuseIdentifier:reuseIdentifier];
            self.pinColor = MKPinAnnotationColorRed;
            self.animatesDrop = NO;
            self.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showSettingsPressed:) forControlEvents:UIControlEventTouchUpInside];
            self.rightCalloutAccessoryView = rightButton;

            break;
        }
    }
    return self;
}

- (IBAction)showSettingsPressed:(id)sender {
    NSLog(@"showSettingsPressed");
    
    /*if (!areasSubmitController) {
        areasSubmitController = [[AreasSubmitController alloc]
                                 initWithNibName:@"AreasSubmitController"
                                 bundle:[NSBundle mainBundle]];
    }
    
    if (navigationController) {
        
        areasSubmitController.area = customAnnotation.area;
        areasSubmitController.review = YES;
        // Switch the View & Controller
        // POP
        [navigationController popViewControllerAnimated:TRUE];
        
        // PUSH
        [navigationController pushViewController:areasSubmitController animated:TRUE];
    }*/
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
