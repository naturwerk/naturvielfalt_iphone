//
//  ObservationsOrganismDetailViewWikipediaController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 22.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organism.h"

@interface ObservationsOrganismDetailViewWikipediaController : UIViewController <UIWebViewDelegate> {
    Organism *organism;
    UIWebView *webView;
    NSString *latName;
    IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic) Organism *organism;
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic) NSString *latName;
@property (nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
