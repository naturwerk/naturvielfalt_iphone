//
//  Settings.h
//  Naturvielfalt
//
//  Created by Robin Oster on 02.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject {
    NSString *urlWebservice;
    NSString *urlSubmitScript;
}

@property (nonatomic, retain) NSString *urlWebservice;
@property (nonatomic, retain) NSString *urlSubmitScript;

- (Settings *) getSettings;
- (id)init;
- (id)initWithLocalhost;
- (id)initWithServer;
@end
