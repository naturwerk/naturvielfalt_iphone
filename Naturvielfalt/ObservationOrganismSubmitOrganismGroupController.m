//
//  ObservationOrganismSubmitOrganismGroupController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.07.13.
//
//

#import "ObservationOrganismSubmitOrganismGroupController.h"
#import "ObservationsOrganismSubmitController.h"

extern int UNKNOWN_ORGANISMID;

@implementation ObservationOrganismSubmitOrganismGroupController
@synthesize pickerView, organismGroupName, organismGroupTitle, observation, groupId, classlevel, selectedOrganismGroup;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        persistenceManager = [[PersistenceManager alloc] init];
        
        // Root element has the id 1
        groupId = 1;
        classlevel = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pickerView.delegate = self;
    
    // Set navigation bar title
    NSString *title = NSLocalizedString(@"observationSpecies", nil);
    self.navigationItem.title = title;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(saveOrganismGroup)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [persistenceManager establishConnection];
    organismGroups = [persistenceManager getAllOrganismGroups:groupId withClasslevel:classlevel];
}

- (void)viewWillAppear:(BOOL)animated {
    organismGroupName.text = observation.organismGroup.name;
    int index;
    for (OrganismGroup *organismGroup in organismGroups) {
        if (organismGroup.organismGroupId  == observation.organism.organismGroupId) {
            selectedOrganismGroup = organismGroup;
            oldOrganismGroup = organismGroup;
            index = [organismGroups indexOfObject:selectedOrganismGroup];
            [pickerView selectRow:index inComponent:0 animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPickerView:nil];
    [self setOrganismGroupTitle:nil];
    [self setOrganismGroupName:nil];
    [super viewDidUnload];
}

- (void) saveOrganismGroup {
    if (selectedOrganismGroup.organismGroupId != oldOrganismGroup.organismGroupId) {
        
        //Unknown organism
        Organism *notYetDefined = [[Organism alloc] init];
        notYetDefined.organismGroupName = selectedOrganismGroup.name;
        notYetDefined.organismGroupId = selectedOrganismGroup.organismGroupId;
        notYetDefined.organismId = UNKNOWN_ORGANISMID;
        notYetDefined.nameDe = NSLocalizedString(@"unknownArt", nil);
        
        //observation.organismGroup.name = selectedOrganismGroup.name;
        //observation.organism.organismGroupName = selectedOrganismGroup.name;
        //observation.organism.organismGroupId = selectedOrganismGroup.organismGroupId;
        
        observation.organism = notYetDefined;
        observation.organismGroup = selectedOrganismGroup;
        
        if (observation.inventory) {
            observation.submitted = NO;
        }
        [persistenceManager establishConnection];
        [persistenceManager persistObservation:observation];
        [persistenceManager closeConnection];

    }
    // POP
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma UIPicker methods
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return organismGroups.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return ((OrganismGroup *)[organismGroups objectAtIndex:row]).name;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    selectedOrganismGroup = [organismGroups objectAtIndex:row];
    organismGroupName.text = selectedOrganismGroup.name;
}


@end
