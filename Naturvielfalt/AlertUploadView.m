//
//  AlertUploadView.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 14.06.13.
//
//

#import "AlertUploadView.h"

@implementation AlertUploadView
@synthesize progressView;

static const float kProgressHeight     = 15.0;
static const float kProgressWidth      = 200.0;

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGRect labelFrame;
    NSArray *views = [self subviews];
    for (UIView *view in views){
        if ([view isKindOfClass:[UILabel class]]) {
            labelFrame = view.frame;
        } else {
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y + kProgressHeight , view.frame.size.width, view.frame.size.height);
        }
    }
    
    CGRect myFrame = self.frame;
    progressView = [[UIProgressView alloc] init];
    progressView.frame = CGRectMake(40, labelFrame.origin.y+labelFrame.size.height + 10.0, kProgressWidth, kProgressHeight);
    [self addSubview:progressView];
    self.frame = CGRectMake(myFrame.origin.x, myFrame.origin.y, myFrame.size.width, myFrame.size.height);
    
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        
        // CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 20.0);
        //  [self setTransform:translate];
    }
    return self;
}

@end

