//
//  AUploadHelper.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import <Foundation/Foundation.h>

@protocol AUploadHelper <NSObject>

- (void) submit:(NSObject *) object withRecursion:(BOOL)recursion;
- (void) update:(NSObject *) object;
- (void) cancel;

@end
