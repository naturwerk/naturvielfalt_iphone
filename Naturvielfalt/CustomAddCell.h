//
//  CustomInventoryAddCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import <UIKit/UIKit.h>

@interface CustomAddCell : UITableViewCell {
    IBOutlet UIButton *addButton;
    IBOutlet UILabel *key;
    IBOutlet UILabel *value;
    
}

@property (nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic) IBOutlet UILabel *key;
@property (nonatomic) IBOutlet UILabel *value;

@end
