//
//  CollectionViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionOverviewController.h"

@interface CollectionRootController : UINavigationController {
    UIViewController *collectionOverview;
}

@property (nonatomic, retain) UIViewController *collectionOverview;

@end
