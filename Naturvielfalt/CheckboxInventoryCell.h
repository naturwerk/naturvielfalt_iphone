//
//  CheckboxInventoryCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 01.05.13.
//
//

#import <UIKit/UIKit.h>

@interface CheckboxInventoryCell : UITableViewCell {
    IBOutlet UIButton *checkbox;
    IBOutlet UIImageView *areaMode;
    IBOutlet UILabel *title;
    IBOutlet UILabel *subtitle;
    IBOutlet UILabel *date;
    IBOutlet UILabel *count;
    IBOutlet UIButton *remove;
}

@property (nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic) IBOutlet UIImageView *areaMode;
@property (nonatomic) IBOutlet UILabel *title;
@property (nonatomic) IBOutlet UILabel *subtitle;
@property (nonatomic) IBOutlet UILabel *date;
@property (nonatomic) IBOutlet UILabel *count;
@property (nonatomic) IBOutlet UIButton *remove;



@end
