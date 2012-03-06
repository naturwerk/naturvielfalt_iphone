//
//  ObservationsOrganismSubmitCommentController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 18.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Observation.h"

#define kOFFSET_FOR_KEYBOARD 20.0

@interface ObservationsOrganismSubmitCommentController : UIViewController {
    IBOutlet UITextView *textView;
    Observation *observation;
}

@property (nonatomic) UITextView *textView;
@property (nonatomic) Observation *observation; 

- (void) saveComment;

@end
