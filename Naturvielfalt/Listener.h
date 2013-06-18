//
//  Listener.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//

#import <Foundation/Foundation.h>

@protocol Listener <NSObject>

- (void) notifyListener:(NSObject *)object response:(NSString *)response;

@end
