//
//  CheckboxAreaObsCell.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 26.06.13.
//
//

#import "CheckboxAreaObsCell.h"

@implementation CheckboxAreaObsCell
@synthesize name, date, amount, latName, image, areaImage, submitted, checkbox, remove;

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
