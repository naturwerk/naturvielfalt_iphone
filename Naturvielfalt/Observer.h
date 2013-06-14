//
//  Observer.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//

#import <Foundation/Foundation.h>
#import "Listener.h"

@protocol Observer <NSObject>

- (void) registerListener:(id<Listener>) l;
- (void) unregisterListener;

@end
