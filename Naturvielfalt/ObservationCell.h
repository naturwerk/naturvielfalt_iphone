//
//  ObservationCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import <UIKit/UIKit.h>

@interface ObservationCell : UITableViewCell {
    IBOutlet UILabel *name;
    IBOutlet UILabel *latName;
    IBOutlet UIImageView *photo;
    IBOutlet UILabel *date;
    IBOutlet UILabel *count;
    IBOutlet UIButton *remove;
}
@property (nonatomic) IBOutlet UILabel *name;
@property (nonatomic) IBOutlet UILabel *latName;
@property (nonatomic) IBOutlet UIImageView *photo;
@property (nonatomic) IBOutlet UILabel *date;
@property (nonatomic) IBOutlet UILabel *count;
@property (nonatomic) IBOutlet UIButton *remove;

@end
