//
//  InventoryCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 29.04.13.
//
//

#import <UIKit/UIKit.h>

@interface InventoryCell : UITableViewCell {
    
    IBOutlet UILabel *date;
    IBOutlet UILabel *name;
    IBOutlet UILabel *observationsCount;
    IBOutlet UILabel *author;
}

@property (nonatomic) IBOutlet UILabel *date;
@property (nonatomic) IBOutlet UILabel *name;
@property (nonatomic) IBOutlet UILabel *observationsCount;
@property (nonatomic) IBOutlet UILabel *author;


@end
