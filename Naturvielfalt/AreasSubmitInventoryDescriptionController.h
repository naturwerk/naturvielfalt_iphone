//
//  AreasSubmitInventoryDescriptionController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Inventory.h"

@interface AreasSubmitInventoryDescriptionController : UIViewController {
    
    IBOutlet UITextView *textView;
    
    Inventory *inventory;
}
@property (nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) Inventory *inventory;

@end
