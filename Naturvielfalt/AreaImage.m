//
//  AreaImage.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 16.05.13.
//
//

#import "AreaImage.h"

@implementation AreaImage
@synthesize areaId, areaImageId, image, submitted;

static AreaImage *areaImage;

- (AreaImage *) getAreaImage {
    
    @synchronized(self)
    {
        if (!areaImage) {
            areaImage = [[AreaImage alloc] init];
        }
        return areaImage;
    }
}

- (void) setAreaImage:(AreaImage *) areaImg {
    areaImage = areaImg;
}
@end
