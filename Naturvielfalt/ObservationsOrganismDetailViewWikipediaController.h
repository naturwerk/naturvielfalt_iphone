//
//  ObservationsOrganismDetailViewWikipediaController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 22.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObservationsOrganismDetailViewWikipediaController : UIViewController {

    IBOutlet UIWebView *webView;
    NSString *latName;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) NSString *latName;

@end
