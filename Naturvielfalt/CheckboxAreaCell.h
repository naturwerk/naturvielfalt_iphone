//
//  CheckboxAreaCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 01.05.13.
//
//

#import <UIKit/UIKit.h>

@interface CheckboxAreaCell : UITableViewCell {
    
    IBOutlet UIButton *checkbox;
    IBOutlet UIImageView *areaMode;
    IBOutlet UILabel *title;
    IBOutlet UILabel *subtitle;
    IBOutlet UILabel *date;
    IBOutlet UILabel *count;
    IBOutlet UIImageView *image;
    IBOutlet UIButton *remove;
    IBOutlet UILabel *submitted;
    IBOutlet UIImageView *checkboxView;
}

@property (nonatomic) IBOutlet UIButton *checkbox;
@property (nonatomic) IBOutlet UIImageView *areaMode;
@property (nonatomic) IBOutlet UILabel *title;
@property (nonatomic) IBOutlet UILabel *subtitle;
@property (nonatomic) IBOutlet UILabel *date;
@property (nonatomic) IBOutlet UILabel *count;
@property (nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) IBOutlet UIButton *remove;
@property (nonatomic) IBOutlet UILabel *submitted;
@property (nonatomic) IBOutlet UIImageView *checkboxView;

@end
