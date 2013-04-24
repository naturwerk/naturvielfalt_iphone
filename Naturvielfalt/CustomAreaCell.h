//
//  CustomAreaCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 16.04.13.
//
//

#import <UIKit/UIKit.h>

@interface CustomAreaCell : UITableViewCell {
    
    IBOutlet UILabel *key;
    IBOutlet UILabel *value;
    IBOutlet UIImageView *image;

}

@property (nonatomic) IBOutlet UILabel *key;
@property (nonatomic) IBOutlet UILabel *value;
@property (nonatomic) IBOutlet UIImageView *image;

@end
