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
    Observation *observation;
    id<Listener> listener;
}

@property (nonatomic) Observation *observation;

- initWithObservation:(Observation *) obs;

@end
