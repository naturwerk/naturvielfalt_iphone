//
//  ObservationUploadHelper.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import <UIKit/UIKit.h>
#import "AUploadHelper.h"
#import "Observer.h"
#import "Observation.h"

@interface ObservationUploadHelper : NSObject <AUploadHelper, Observer> {
    
    Observation *observation;
    id<Listener> listener;
}

@end
