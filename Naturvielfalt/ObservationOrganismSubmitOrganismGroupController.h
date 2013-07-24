//
//  ObservationOrganismSubmitOrganismGroupController.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.07.13.
//
//

#import <UIKit/UIKit.h>
#import "Observation.h"
#import "PersistenceManager.h"
#import "OrganismGroup.h"

@interface ObservationOrganismSubmitOrganismGroupController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>{
    IBOutlet UIPickerView *pickerView;
    IBOutlet UILabel *organismGroupTitle;
    IBOutlet UILabel *organismGroupName;
    Observation *observation;
    NSMutableArray *organismGroups;
    PersistenceManager *persistenceManager;
    int groupId;
    int classlevel;
    OrganismGroup *selectedOrganismGroup;
    OrganismGroup *oldOrganismGroup;
}

@property (nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic) IBOutlet UILabel *organismGroupTitle;
@property (nonatomic) IBOutlet UILabel *organismGroupName;
@property (nonatomic) Observation *observation;
@property (nonatomic) int groupId;
@property (nonatomic) int classlevel;
@property (nonatomic) OrganismGroup *selectedOrganismGroup;


@end
