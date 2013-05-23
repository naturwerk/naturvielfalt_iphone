//
//  CustomPolygonView.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 22.04.13.
//
//

#import "CustomPolygonView.h"
#import "MKPolygon+MKPolygonCategory.h"

#define pWidth 5
#define pAlpha 0.3

@implementation CustomPolygonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithPolygon:(MKPolygon *)polygon {
    
    if (self = [super initWithPolygon:polygon]) {
        if (!polygon.persisted) {
            self.fillColor = [[UIColor blueColor] colorWithAlphaComponent:pAlpha];
            self.strokeColor = [UIColor blueColor];
            self.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:12], [NSNumber numberWithFloat:8], nil];
            self.lineWidth = pWidth;
        } else {
            self.fillColor = [[UIColor greenColor] colorWithAlphaComponent:pAlpha];
            self.strokeColor = [UIColor greenColor];
            self.lineWidth = pWidth;
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
