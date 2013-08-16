//
//  Observer.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//
#import "Listener.h"

@protocol Observer <NSObject>

@required
- (void) registerListener:(id<Listener>) l;
- (void) unregisterListener;

@optional
- (void) registerCollectionListener: (id<Listener>) l;
- (void) unregisterCollectionListener;

@end
