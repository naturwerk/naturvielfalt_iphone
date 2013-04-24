//
//  CustomLineView.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 22.04.13.
//
//

#import "CustomLineView.h"
#import "MKPolyline+MKPolylineCategory.h"

#define lWidth 5
#define lAlpha 0.3

@implementation CustomLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithPolyline:(MKPolyline *)cp {
    
    if (self = [super initWithPolyline:cp]) {
        //customLine = polyline;
        if (!cp.persisted) {
            self.strokeColor = [UIColor blueColor];
            self.lineWidth = lWidth;
            self.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:12], [NSNumber numberWithFloat:8], nil];
        } else {
            self.strokeColor = [UIColor greenColor];
            self.lineWidth = lWidth;
        }
    }
    return self;
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
