//
//  AreasSubmitNameController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 09.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"

@interface AreasSubmitNameController : UIViewController {
    
    Area *area;
    IBOutlet UITextView *textView;
}

@property (nonatomic) Area *area;

@end
