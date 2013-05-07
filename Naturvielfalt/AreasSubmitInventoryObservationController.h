//
//  AreasSubmitInvetoryObservationController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import <UIKit/UIKit.h>
#import "Area.h"
#import "Inventory.h"
#import "PersistenceManager.h"

@interface AreasSubmitInventoryObservationController : UIViewController <UITableViewDelegate> {
    
    PersistenceManager *persistenceManager;
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *inventoryLabel;
    IBOutlet UILabel *areaLabel;
    IBOutlet UILabel *observationLabel;
    IBOutlet UITableView *observationsTableView;
    
    Area *area;
    Inventory *inventory;
    BOOL review;
}
@property (nonatomic) Area *area;
@property (nonatomic) Inventory *inventory;

@property (nonatomic) IBOutlet UILabel *dateLabel;
@property (nonatomic) IBOutlet UILabel *inventoryLabel;
@property (nonatomic) IBOutlet UILabel *areaLabel;
@property (nonatomic) IBOutlet UILabel *observationLabel;
@property (nonatomic) IBOutlet UITableView *observationsTableView;


- (IBAction)newObservation:(id)sender;
@end
