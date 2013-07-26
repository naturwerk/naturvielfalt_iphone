//
//  ObservationUploadHelper.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.06.13.
//
//

#import <UIKit/UIKit.h>
#import "AUploadHelper.h"
#import "AsyncRequestDelegate.h"
#import "Observation.h"
#import "ASIFormDataRequest.h"
#import "PersistenceManager.h"

@interface ObservationUploadHelper : NSObject <AUploadHelper, Observer, Listener> {
    
    Observation *observation;
    id<Listener> listener;
    AsyncRequestDelegate *asyncRequestDelegate;
    ASIFormDataRequest *request;
    PersistenceManager *persistenceManager;
}

@end
