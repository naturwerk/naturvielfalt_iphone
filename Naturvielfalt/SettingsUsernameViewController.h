//
//  SettingsUsernameViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 25.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsUsernameViewController : UIViewController {
    IBOutlet UITextField *textView;
    NSString *username;
}

@property (nonatomic, retain) UITextField *textView;
@property (nonatomic, retain) NSString *username;

- (void) saveUsername;

@end
