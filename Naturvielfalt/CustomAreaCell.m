//
//  CustomAreaCell.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 16.04.13.
//
//

#import "CustomAreaCell.h"

@implementation CustomAreaCell
@synthesize key, value, image;

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
}

@end
