//
//  NaturvielfaltAppDelegate.m
//  Naturvielfalt
//
//  Created by Robin Oster on 22.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NaturvielfaltAppDelegate.h"  

@implementation UINavigationBar (CustomImage)
- (void)drawRect:(CGRect)rect {
    UIImage *image = [UIImage imageNamed: @"navigationbar.png"];
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
@end

@implementation NaturvielfaltAppDelegate


@synthesize window=_window;

@synthesize tabBarController=_tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    self.observationTabItem.title = NSLocalizedString(@"observationTabLabel", nil);
    self.collectionTabItem.title = NSLocalizedString(@"collectionTabLabel", nil);
    self.settingsTabItem.title = NSLocalizedString(@"settingsTabLabel", nil);
    [self.window makeKeyAndVisible];
    
    UIColor *myBarButtonColor = [UIColor colorWithRed:60/255.0 green:120/255.0 blue:100/255.0 alpha:1];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:myBarButtonColor];
    
    // Store default settings in the appSettings
    NSUserDefaults* appSettings = [NSUserDefaults standardUserDefaults];
    //[appSettings setObject:@"waebi07" forKey:@"username"];
    //[appSettings setObject:@"natur498" forKey:@"password"];
    [appSettings setObject:@"2" forKey:@"mapType"];
    [appSettings synchronize];
    
    NSLog(@"language is: %@", [[NSLocale preferredLanguages] objectAtIndex:0]);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end
