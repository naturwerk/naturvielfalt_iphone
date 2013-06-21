//
//  CollectionAreaObservationsController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 20.06.13.
//
//

#import "CollectionAreaObservationsController.h"
#import "CheckboxCell.h"
#import "AreasSubmitController.h"
#import "ObservationsOrganismSubmitController.h"
@interface CollectionAreaObservationsController ()

@end

@implementation CollectionAreaObservationsController
@synthesize table, persistenceManager, observations, operationQueue, countObservations, curIndex;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTable:nil];
    [super viewDidUnload];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        persistenceManager = [[PersistenceManager alloc] init];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"collectionAreaObsTitle", nil);
    self.navigationItem.title = title;
    
    table.delegate = self;
    
    // Reload the observations
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    loadingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:loadingHUD];
    
    loadingHUD.delegate = self;
    loadingHUD.mode = MBProgressHUDModeCustomView;
    loadingHUD.labelText = NSLocalizedString(@"collectionHudLoadMessage", nil);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [loadingHUD showWhileExecuting:@selector(reloadObservations) onTarget:self withObject:nil animated:YES];
    
    // Reload table
    [table reloadData];
}

- (void) removeObservations
{
    [self.table setEditing:!self.table.editing animated:YES];
}

- (void)beginLoadingObservations
{
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousLoadAreaObservations) object:nil];
    [operationQueue addOperation:operation];
}

- (void)synchronousLoadAreaObservations
{
    NSMutableArray *arrNewObservations;
    @synchronized (self) {
        // Establish a connection
        [persistenceManager establishConnection];
        
        // Get all observations
        arrNewObservations = [persistenceManager getAllAreaObservations];
        
        [persistenceManager closeConnection];
    }
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingAreaObservations:) withObject:arrNewObservations waitUntilDone:YES];
}

- (void)didFinishLoadingAreaObservations:(NSMutableArray *)arrNewObservations
{
    if(observations != nil) {
        if([observations count] != [arrNewObservations count]){
            observations = arrNewObservations;
        }
    }
    else {
        observations = arrNewObservations;
    }
    
    countObservations = (int *)self.observations.count;
    
    if(table.editing)
        [table deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.curIndex] withRowAnimation:YES];
    
    [table reloadData];
    
    // If there aren't any observations in the list. Stop the editing mode.
    if([observations count] < 1) {
        table.editing = FALSE;
    }
}

- (void) reloadObservations
{
    // Reset observations
    observations = nil;
    [self beginLoadingObservations];
}

- (void) viewWillAppear:(BOOL)animated
{
    table.editing = FALSE;
    [self reloadObservations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CheckboxCell *cell = (CheckboxCell *)[tableView cellForRowAtIndexPath:indexPath];
        UIButton *button = cell.checkbox;
        self.curIndex = indexPath;
        
        // Also delete it from the Database
        // Establish a connection
        [persistenceManager establishConnection];
        
        // If Yes, delete the observation with the persistence manager
        [persistenceManager deleteObservation:button.tag];
        
        // Close connection to the database
        [persistenceManager closeConnection];
        
        // Reload the observations from the database and refresh the TableView
        [self reloadObservations];
    }
}


// MARK: -
// MARK: TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.observations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CheckboxCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // use CustomCell layout
    CheckboxCell *checkboxCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                checkboxCell =  (CheckboxCell *)currentObject;
                break;
            }
        }
    } else {
        checkboxCell = (CheckboxCell *)cell;
    }
    
    Observation *observation = [observations objectAtIndex:indexPath.row];
    
    if(observation != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:observation.date];
        
        if(observation.pictures.count > 0){
            UIImage *original = ((ObservationImage *)[observation.pictures objectAtIndex:0]).image;
            CGFloat scale = [UIScreen mainScreen].scale;
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            
            CGContextRef context = CGBitmapContextCreate(NULL, 26, 26, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
            CGContextDrawImage(context,
                               CGRectMake(0, 0, 26, 26 * scale),
                               original.CGImage);
            CGImageRef shrunken = CGBitmapContextCreateImage(context);
            UIImage *final = [UIImage imageWithCGImage:shrunken];
            
            CGContextRelease(context);
            CGImageRelease(shrunken);
            checkboxCell.image.image = final;
        }
        else {
            checkboxCell.image.image = [UIImage imageNamed:@"blank.png"];
        }
        
        checkboxCell.name.text = [observation.organism getNameDe];
        checkboxCell.date.text = nowString;
        checkboxCell.amount.text = observation.amount;
        checkboxCell.latName.text = [observation.organism getLatName];
        checkboxCell.areaImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"symbol-%@.png", [AreasSubmitController getStringOfDrawMode:observation.inventory.area]]];
        
        // Define the action on the button and the current row index as tag
        [checkboxCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.checkbox setTag:observation.observationId];
        
        // Define the action on the button and the current row index as tag
        [checkboxCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxCell.remove setTag:observation.observationId];
        
        // Set checkbox icon
        if(observation.submitToServer) {
            checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }
    }
    
    return checkboxCell;
}

- (void) checkboxEvent:(UIButton *)sender
{
    UIButton *button = (UIButton *)sender;
    NSNumber *number = [NSNumber numberWithInt:button.tag];
    
    for(Observation *ob in observations) {
        if(ob.observationId == [number longLongValue]) {
            ob.submitToServer = !ob.submitToServer;
        }
    }
    
    [table reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Create the ObservationsOrganismViewController
    ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc]
                                                                      initWithNibName:@"ObservationsOrganismSubmitController"
                                                                      bundle:[NSBundle mainBundle]];
    
    Observation *observation = [observations objectAtIndex:indexPath.row];
    
    // Store the current observation object
    /*Observation *observationShared = [[Observation alloc] getObservation];
     [observationShared setObservation:observation];
     
     NSLog(@"Observation in CollectionOverView: %@", [observationShared getObservation]);*/
    
    // Set the current displayed organism
    organismSubmitController.observation = observation;
    organismSubmitController.organism = observation.organism;
    organismSubmitController.review = YES;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismSubmitController animated:TRUE];
    organismSubmitController = nil;
}



@end
