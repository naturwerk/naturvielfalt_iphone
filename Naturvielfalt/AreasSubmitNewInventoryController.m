//
//  AreasSubmitNewInventoryController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 15.04.13.
//
//

#import "AreasSubmitNewInventoryController.h"
#import "AreasSubmitInventoryNameController.h"
#import "AreasSubmitInventoryDescriptionController.h"
#import "AreasSubmitInventoryObservationController.h"
#import "CustomCell.h"
#import "CustomAddCell.h"

@interface AreasSubmitNewInventoryController ()

@end

@implementation AreasSubmitNewInventoryController
@synthesize area;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareData {
    
    // create new inventory if no inventory is choosen
    if (!inventory) {
        inventory = [[Inventory alloc] init];
        inventory.date = area.date;
    }
    
    if (!review) {
        // Set current time
        NSDate *now = [NSDate date];
        
        // Update date in observation data object
        inventory.date = now;
    }
    
    
    // Get formatted date string
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd.MM.yyyy, HH:mm:ss";
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *nowString = [dateFormatter stringFromDate:area.date];
    
    // Initialize keys/values
    arrayKeys = [[NSArray alloc] initWithObjects:@"Zeit", @"Erfasser", @"Gebietsname", @"Inventarname" @"Beschreibung", nil];
    arrayValues = [[NSArray alloc] initWithObjects:nowString, area.author, area.name, inventory.name, inventory.description, @">", nil];
}

- (void) newObservation {
    NSLog(@"new Observation pressed");
}

#pragma mark
#pragma UITableViewDelegate Methodes
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView");
    return 2;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    if (section == 0) {
        return [arrayKeys count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tw cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndexPath");
    static NSString *cellIdentifier = @"CustomCell";
    UITableViewCell *cell = [tw dequeueReusableCellWithIdentifier:cellIdentifier];
    CustomCell *customCell;
    CustomAddCell *customAddCell;
    
    if (indexPath.section == 0) {
        if(indexPath.row > 2) {
            // use CustomCell layout
            
            if(cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];
                
                for (id currentObject in topLevelObjects){
                    if ([currentObject isKindOfClass:[UITableViewCell class]]){
                        customCell =  (CustomCell *)currentObject;
                        break;
                    }
                }
                
                switch(indexPath.row) {
                    case 3:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = (inventory.name.length > 10) ? @"..." : inventory.name;
                        customCell.image.image = nil;
                    }
                        break;
                        
                    case 4:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = (inventory.description.length > 0) ? @"..." : @"";
                        customCell.image.image = nil;
                    }
                        break;
                        
                    default:
                    {
                        customCell.key.text = [arrayKeys objectAtIndex:indexPath.row];
                        customCell.value.text = @"";
                        customCell.image.image = nil;
                    }
                        break;
                }
                return customCell;
            }
        } else {
            // Use normal cell layout
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            }
            
            // Set up the cell...
            cell.textLabel.text = [arrayKeys objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [arrayValues objectAtIndex:indexPath.row];
            
            return cell;
        }
    } else {
        
        if(cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomAddCell" owner:self options:nil];
            
            for (id currentObject in topLevelObjects){
                if ([currentObject isKindOfClass:[UITableViewCell class]]){
                    customAddCell =  (CustomAddCell *)currentObject;
                    break;
                }
            }
            
            NSLog(@"section %i", indexPath.section);
            customAddCell.key.text = @"Beobachtungen";
            customAddCell.value.text = @"3";
            [customAddCell.addButton addTarget:self action:@selector(newObservation) forControlEvents:UIControlEventTouchUpInside];
            
            return customAddCell;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self rowClicked:indexPath];
}

- (void) rowClicked:(NSIndexPath *) indexPath {
    NSLog(@"index Path: %@", indexPath);
    AreasSubmitInventoryNameController *areasSubmitInventoryNameController;
    AreasSubmitInventoryDescriptionController *areasSubmitInventoryDescriptionController;
    AreasSubmitInventoryObservationController *areasSubmitInventoryObservationController;
    
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 2:
                // NAME
                // Create the ObservationsOrganismSubmitCameraController
                areasSubmitInventoryNameController = [[AreasSubmitInventoryNameController alloc]
                                             initWithNibName:@"AreasSubmitInventoryNameController"
                                             bundle:[NSBundle mainBundle]];
                
                
                areasSubmitInventoryNameController.inventory = inventory;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitInventoryNameController animated:TRUE];
                areasSubmitInventoryNameController = nil;
                
                break;
            case 3:
                // DESCRIPTION
                // Create the ObservationsOrganismSubmitCameraController
                areasSubmitInventoryDescriptionController = [[AreasSubmitInventoryDescriptionController alloc]
                                                    initWithNibName:@"AreasSubmitInventoryDescriptionController"
                                                    bundle:[NSBundle mainBundle]];
                
                areasSubmitInventoryDescriptionController.inventory = inventory;
                
                // Switch the View & Controller
                [self.navigationController pushViewController:areasSubmitInventoryDescriptionController animated:TRUE];
                areasSubmitInventoryDescriptionController = nil;
                
                break;
        }
    } else {
        
        // OBSERVATION
        // Create the ObservationsOrganismSubmitMapController
        areasSubmitInventoryObservationController = [[AreasSubmitInventoryObservationController alloc]
                                          initWithNibName:@"AreasSubmitInventoryObservationController"
                                          bundle:[NSBundle mainBundle]];
        
        areasSubmitInventoryObservationController.area = area;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:areasSubmitInventoryObservationController animated:TRUE];
        areasSubmitInventoryObservationController = nil;
    }
}

@end
