//
//  CustomAnnotationView.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 19.04.13.
//
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "AreasSubmitController.h"

@interface CustomAnnotationView : MKAnnotationView
{
    UIImageView *imageView;
    AreasViewController *areasViewController;
    AreasSubmitController *areasSubmitController;
    CustomAnnotation *customAnnotation;
    UINavigationController *navigationController;
}

@property (nonatomic) UIImageView *imageView;

- (id) initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier navigationController:(UINavigationController*) naviController;

@end
