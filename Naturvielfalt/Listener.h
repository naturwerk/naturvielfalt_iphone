//
//  Listener.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 13.06.13.
//
//
#import <Foundation/Foundation.h>

@protocol Observer;
@protocol Listener <NSObject>

- (void) notifyListener:(NSObject *)object response:(NSString *)response observer:(id<Observer> )observer;

@end
