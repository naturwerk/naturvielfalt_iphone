//
//  WikipediaHelper.m
//  Naturvielfalt
//
//  Created by Robin Oster on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WikipediaHelper.h"
#import "SBJsonParser.h"

@implementation WikipediaHelper

- (NSString *) fetchWikipediaArticle:(NSString *)latName {
    // Create new SBJSON parser object
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    // JSON Request url
    NSURLRequest *request;
    
    NSString *url = [[NSString alloc] initWithFormat:@"http://de.wikipedia.org/w/api.php?action=query&prop=revisions&titles=%@&rvprop=content&rvparse&format=json&redirects", latName];
    
    request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Perform request and get JSON back as a NSData object
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    // Get JSON as a NSString from NSData response
    NSString *json_string = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    // parse the JSON response into an object
    // Here we're using NSArray since we're parsing an array of JSON status objects
    NSDictionary *wikipediaResponseObject = [parser objectWithString:json_string error:nil];
    
    NSArray *htmlTemp = [[[wikipediaResponseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
    
    if(![[htmlTemp objectAtIndex:0] objectForKey:@"revisions"]) {
        return @"";
    }
    
    NSString *htmlSrc = [[[[htmlTemp objectAtIndex:0] objectForKey:@"revisions"] objectAtIndex:0] objectForKey:@"*"];
    
    return htmlSrc;
}

- (NSString *) getWikipediaHTMLPage:(NSString *)latName {
    // Fetch wikipedia article
    NSString *htmlSrc = [self fetchWikipediaArticle:latName];
    
    if([htmlSrc isEqualToString:@""])
        return NSLocalizedString(@"organismWikiNotFound", nil);
        
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"/wiki/" withString:@"http://de.wikipedia.org/wiki/"];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"<a href=\"http://de.wikipedia.org/wiki\"" withString:@"<a target=\"blank\" href=\"http://de.wikipedia.org/wiki\""];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"class=\"editsection\"" withString:@"style=\"visibility: hidden\""];
    
    
    // Append html and body tags, Add some style
    formatedHtmlSrc = [NSString stringWithFormat:@"<body style=\"font-size: 13px; font-family: Helvetica, Verdana\">%@<br/><br/><br/>The article above is based on this article of the free encyclopedia Wikipedia and it is licensed under „Creative Commons Attribution/Share Alike“. Here you find versions/authors.</body>", formatedHtmlSrc];
    
    return formatedHtmlSrc;
}

- (NSString *) getUrlOfMainImage:(NSString *)latName {
    
    // Fetch wikipedia article
    NSString *htmlSrc = [self fetchWikipediaArticle:latName];
    
    if([htmlSrc isEqualToString:@""])
        return htmlSrc;
    
    // Otherwise images have an incorrect url
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];

    
    NSArray *splitonce = [formatedHtmlSrc componentsSeparatedByString:@"src=\""];
    
    // prevent out of bound exception
    if([splitonce count] < 2) return @"";

    NSString *finalSplitString = [[NSString alloc]  initWithString:[splitonce objectAtIndex:1]];
    NSArray *finalSplit = [finalSplitString  componentsSeparatedByString:@"\""];

    // prevent out of bound exception
    if([finalSplit count] < 1) return @"";
    
    NSString *imageURL = [[NSString alloc]  initWithString:[finalSplit objectAtIndex:0]];
    imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]];
    
    
    // Check if its not the correct image (Sometimes there are articles where the first image is an icon..)
    if([imageURL isEqualToString:@"http://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Disambig-dark.svg/25px-Disambig-dark.svg.png"] || [imageURL isEqualToString:@"http://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Qsicon_L%C3%BCcke.svg/24px-Qsicon_L%C3%BCcke.svg.png"]) {
        
        // prevent out of bound exception
        if([splitonce count] < 3) return @"";
        
        // Get the next image tag
        finalSplitString = [[NSString alloc]  initWithString:[splitonce objectAtIndex:2]];
        finalSplit = [finalSplitString  componentsSeparatedByString:@"\""];
        
        // prevent out of bound exception
        if([finalSplit count] < 1) return @"";
        
        imageURL = [[NSString alloc]  initWithString:[finalSplit objectAtIndex:0]];
        imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceCharacterSet]];
    }
    
    return imageURL;
}

@end
