//
//  AsyncRequestDelegate.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//

#import "AsyncRequestDelegate.h"

@implementation AsyncRequestDelegate
@synthesize observation;

- (id)initWithObservation:(Observation *)obs {
    
    if (self = [super init]) {
        observation = obs;
    }
    return  self;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    NSLog(@"request finished with Response: %@", response);
    [listener notifyListener:observation response:response];
}

- (void)registerListener:(id)l {
    listener = l;
}

- (void)unregisterListener {
    listener = nil;
}
    
@end
