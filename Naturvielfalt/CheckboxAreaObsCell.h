//
//  CheckboxAreaObsCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 26.06.13.
//
//

#import <UIKit/UIKit.h>

@interface CheckboxAreaObsCell : UITableViewCell {
    
    IBOutlet UILabel *name;
    IBOutlet UILabel *date;
    IBOutlet UIButton *remove;
    IBOutlet UILabel *amount;
    IBOutlet UILabel *latName;
    IBOutlet UIImageView *image;
    IBOutlet UIImageView *areaImage;
    IBOutlet UIButton *checkbox;
    IBOutlet UILabel *submitted;
}

@property (nonatomic) IBOutlet UILabel *name;
@property (nonatomic) IBOutlet UILabel *date;
@property (nonatomic) UIButton *remove;
@property (nonatomic) IBOutlet UILabel *amount;
@property (nonatomic) IBOutlet UILabel *latName;
@property (nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) IBOutlet UIImageView *areaImage;
@property (nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic) IBOutlet UILabel *submitted;

@end
