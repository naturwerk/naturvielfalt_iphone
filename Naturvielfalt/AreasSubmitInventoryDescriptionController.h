//
//  AreasSubmitInventoryDescriptionController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Inventory.h"
#import "PersistenceManager.h"

@interface AreasSubmitInventoryDescriptionController : UIViewController {
    
    IBOutlet UITextView *textView;
    PersistenceManager *persistenceManager;
    Inventory *inventory;
}
@property (nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) Inventory *inventory;

@end
