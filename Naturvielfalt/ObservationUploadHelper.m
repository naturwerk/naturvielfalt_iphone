//
//  ObservationUploadHelper.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import "ObservationUploadHelper.h"

@implementation ObservationUploadHelper

- (void)submit:(NSObject *)object withRecursion:(BOOL)recursion {
    
}

- (void)update:(NSObject *)object {
    observation = (Observation *)object;
    
    //start async request
    
    
}

- (void) registerListener:(id<Listener>)l {
    listener = l;
}

- (void) unregisterListener {
    listener = nil;
}

@end
