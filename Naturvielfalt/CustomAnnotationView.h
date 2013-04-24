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

@interface CustomAnnotationView : MKAnnotationView
{
    UIImageView *imageView;
}

@property (nonatomic) UIImageView *imageView;

@end
