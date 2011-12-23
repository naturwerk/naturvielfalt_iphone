//
//  WikipediaHelper.h
//  Naturvielfalt
//
//  Created by Robin Oster on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikipediaHelper : NSObject {
    
}

// Fetches an wikipedia article from the wikipedia api
- (NSString *) fetchWikipediaArticle:(NSString *)latName;

// Returns the HTML page from an wikipedia article search by the latin name of the organism
- (NSString *) getWikipediaHTMLPage:(NSString *)latName;

// Return the Main image of an wikipedia article search by the latin name of the organism
- (NSString *) getUrlOfMainImage:(NSString *)latName;

@end
