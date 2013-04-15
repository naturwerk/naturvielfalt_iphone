//
//  CustomInventoryAddCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import <UIKit/UIKit.h>

@interface CustomInventoryAddCell : UITableViewCell {
    IBOutlet UIButton *addInventoryButton;
    IBOutlet UILabel *key;
    IBOutlet UILabel *value;
    
}

@property (nonatomic) IBOutlet UIButton *addInventoryButton;
@property (nonatomic) IBOutlet UILabel *key;
@property (nonatomic) IBOutlet UILabel *value;

@end
