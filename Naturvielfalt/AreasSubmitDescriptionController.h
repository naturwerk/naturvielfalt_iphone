//
//  AreasSubmitDescriptionController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"
#import "PersistenceManager.h"

@interface AreasSubmitDescriptionController : UIViewController {
    
    Area *area;
    PersistenceManager *persistenceManager;
    IBOutlet UITextView *textView;
}

@property (nonatomic) Area *area;

@end
