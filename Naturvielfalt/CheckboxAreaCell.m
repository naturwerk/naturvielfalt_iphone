//
//  CheckboxAreaCell.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 01.05.13.
//
//

#import "CheckboxAreaCell.h"

@implementation CheckboxAreaCell
@synthesize checkbox, areaMode, title, subtitle, date, count, image, remove, submitted, checkboxView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
