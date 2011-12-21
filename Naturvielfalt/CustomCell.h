//
//  StateTableCellView.h
//  States
//
//  Created by Julio Barros on 1/26/09.
//  Copyright 2009 E-String Technologies, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell {
	IBOutlet UILabel *key;
	IBOutlet UILabel *value;
    IBOutlet UIImageView *image;
}

@property (nonatomic,retain) IBOutlet UILabel *key;
@property (nonatomic,retain) IBOutlet UILabel *value;
@property (nonatomic,retain) IBOutlet UIImageView *image;

@end
