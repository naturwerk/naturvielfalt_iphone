//
//  AlertUploadView.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 14.06.13.
//
//

#import <UIKit/UIKit.h>

@interface AlertUploadView : UIAlertView {
    
    UIProgressView *progressView;
}

@property (nonatomic) UIProgressView *progressView;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;

@end
