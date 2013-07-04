//
//  CustomDateCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 03.07.13.
//
//

#import <UIKit/UIKit.h>

@interface CustomDateCell : UITableViewCell {
    IBOutlet UILabel *key;
    IBOutlet UILabel *value;
}
@property (nonatomic) IBOutlet UILabel *key;
@property (nonatomic) IBOutlet UILabel *value;

@end
