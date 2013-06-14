//
//  Listener.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//

#import <Foundation/Foundation.h>
#import "Observation.h"

@protocol Listener <NSObject>

- (void) notifyListener:(Observation *)observation response:(NSString *)response;

@end
