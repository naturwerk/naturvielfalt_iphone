//
//  NaturvielfaltAppDelegate.h
//  Naturvielfalt
//
//  Created by Robin Oster on 22.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NaturvielfaltAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet UITabBarController *tabBarController;
@property (nonatomic) IBOutlet UITabBarItem *observationTabItem;
@property (nonatomic) IBOutlet UITabBarItem *collectionTabItem;
@property (nonatomic) IBOutlet UITabBarItem *settingsTabItem;
@property (nonatomic) BOOL observationsChanged;

@end
