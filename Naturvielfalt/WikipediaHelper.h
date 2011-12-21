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

- (NSString *) fetchWikipediaArticle:(NSString *)latName;
- (NSString *) getWikipediaHTMLPage:(NSString *)latName;
- (NSString *) getUrlOfMainImage:(NSString *)latName;

@end
