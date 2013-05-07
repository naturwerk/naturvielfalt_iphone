//
//  DeleteCell.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 07.05.13.
//
//

#import "DeleteCell.h"

@implementation DeleteCell
@synthesize deleteLabel;

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
