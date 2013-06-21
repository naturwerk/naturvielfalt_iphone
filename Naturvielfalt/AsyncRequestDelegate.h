//
//  AsyncRequestDelegate.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"
#import "Observer.h"

@interface AsyncRequestDelegate : NSObject <ASIHTTPRequestDelegate, Observer> {
    NSObject *object;
    id<Listener> listener;
    
}

- initWithObject:(NSObject *) obj;

@end
