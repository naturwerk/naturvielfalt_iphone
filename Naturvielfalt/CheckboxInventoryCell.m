//
//  CheckboxInventoryCell.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 01.05.13.
//
//

#import "CheckboxInventoryCell.h"

@implementation CheckboxInventoryCell
@synthesize checkbox, areaMode, title, subtitle, date, count, remove;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
