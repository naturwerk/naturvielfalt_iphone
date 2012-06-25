//
//  InfoController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 15.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoController : UIViewController {
    IBOutlet UILabel *lblPartner;
    IBOutlet UIScrollView *scrollView;
}

@property (nonatomic) IBOutlet UILabel *lblPartner;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@end
