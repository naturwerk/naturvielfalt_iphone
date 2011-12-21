//
//  SettingsPasswordViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsPasswordViewController : UIViewController {
    IBOutlet UITextField *textView;
    NSString *password;
}

@property (nonatomic, retain) UITextField *textView;
@property (nonatomic, retain) NSString *password;

- (void) savePassword;

@end
