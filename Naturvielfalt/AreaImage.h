//
//  AreaImage.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 16.05.13.
//
//

#import <Foundation/Foundation.h>

@interface AreaImage : NSObject {
    
    long long int areaImageId;
    long long int areaId;
    UIImage *image;
    BOOL submitted;
}

@property (nonatomic) long long int areaImageId;
@property (nonatomic) long long int areaId;
@property (nonatomic) UIImage *image;
@property (nonatomic) BOOL submitted;

- (AreaImage *) getAreaImage;
- (void) setAreaImage:(AreaImage *) areaImg;
@end
