//
//  ObservationsOrganismSubmitCommentController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Observation.h"
#import "PersistenceManager.h"

#define kOFFSET_FOR_KEYBOARD 20.0

@interface ObservationsOrganismSubmitCommentController : UIViewController {
    IBOutlet UITextView *textView;
    Observation *observation;
    PersistenceManager *persistenceManager;
}

@property (nonatomic) UITextView *textView;
@property (nonatomic) Observation *observation;
@property (nonatomic) PersistenceManager *persistenceManager;

- (void) saveComment;

@end
