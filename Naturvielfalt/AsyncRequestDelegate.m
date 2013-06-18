//
//  AsyncRequestDelegate.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//

#import "AsyncRequestDelegate.h"

@implementation AsyncRequestDelegate

- (id)initWithObject:(NSObject *)obj {
    
    if (self = [super init]) {
        object = obj;
    }
    return  self;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"request finished");
    
    NSString *response = [request responseString];
    [listener notifyListener:object response:response];
}

- (void)registerListener:(id)l {
    listener = l;
}

- (void)unregisterListener {
    listener = nil;
}
    
@end
