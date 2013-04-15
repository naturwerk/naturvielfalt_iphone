//
//  CustomObservationAddCell.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 11.04.13.
//
//

#import <UIKit/UIKit.h>

@interface CustomObservationAddCell : UITableViewCell {

    IBOutlet UILabel *key;
    IBOutlet UILabel *value;
}

- (IBAction)addObservation:(id)sender;

@property (nonatomic) IBOutlet UILabel *key;
@property (nonatomic) IBOutlet UILabel *value;


@end
