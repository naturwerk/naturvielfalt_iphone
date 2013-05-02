//
//  CollectionAreasController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CollectionAreasController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
    
    IBOutlet UITableView *tableView;
    NSMutableArray *areas;
    BOOL doSubmit;
}

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *areas;

@end
