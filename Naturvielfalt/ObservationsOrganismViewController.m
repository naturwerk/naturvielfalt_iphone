//
//  ObservationsOrganismViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 28.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismViewController.h"
#import "ObservationsOrganismSubmitController.h"
#import "ObservationsOrganismDetailViewWikipediaController.h"
#import "Organism.h"
#import "OrganismGroup.h"
#import "NSDictionary-MutableDeepCopy.h"
#import "CustomOrganismCell.h"

@implementation ObservationsOrganismViewController
@synthesize organismGroupId, listData, organismGroupName, dictOrganismsDE, dictOrganismsLAT, keysDE, keysLAT, isSearching, displayGermanNames, search, dictAllOrganismsDE, dictAllOrganismsLAT, keysAllDE, keysAllLAT, currKeys, currDict, spinner, inventory;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self loadData];
    
    [super viewDidLoad];
    
    // Display names in german
    displayGermanNames = true;
    
    // Set top navigation bar button  
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] 
                                     initWithTitle:@"LAT"
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(changeNameLanguage)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
    
    // Set navigation bar title    
    NSString *title = [[NSString alloc] initWithFormat:@"%@", organismGroupName];
    self.navigationItem.title = title;
    
    // reload data again
    [table reloadData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) viewDidAppear:(BOOL)animated {
}

- (NSMutableDictionary *) getCurrentDict 
{
    return (displayGermanNames) ? dictOrganismsDE : dictOrganismsLAT;
}

- (NSMutableArray *) getCurrentKey
{
    //if([keysDE count] == 0) return keysLAT;
    return (displayGermanNames) ? keysDE : keysLAT;
}

- (void) changeNameLanguage 
{
    // Change button label
    self.navigationItem.rightBarButtonItem.title = (displayGermanNames) ? @"DE" : @"LAT";
    displayGermanNames = !displayGermanNames;
    
    // take the search if is active
    if(isSearching){
        [self handleSearchForTerm:search.text];
    }
    [table reloadSectionIndexTitles];
    [table reloadData];
}


- (void) loadData 
{
    
    // Init all needed dictionaries
    dictOrganismsDE = [[NSMutableDictionary alloc] init];
    dictOrganismsLAT = [[NSMutableDictionary alloc] init];
    keysDE = [[NSMutableArray alloc] init];
    keysLAT = [[NSMutableArray alloc] init];
    
    
    // Get all oranismGroups
    PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
    [persistenceManager establishConnection];
    
    NSMutableArray *organisms;
    
    organisms = [persistenceManager getAllOrganisms:organismGroupId];
    [persistenceManager closeConnection];
    
    for(Organism *organism in organisms) {
        [self appendToDictionary:organism];
    }
    
    // copy all values in other dictionary
    dictAllOrganismsDE = [[NSMutableDictionary alloc] initWithDictionary:dictOrganismsDE];
    dictAllOrganismsLAT = [[NSMutableDictionary alloc] initWithDictionary:dictOrganismsLAT];
    
    // SORT KEYS GERMAN
    NSMutableArray *tempDE = [[NSMutableArray alloc] init];
    
    // Add all keys to the array
    for(NSString *key in keysDE) {
        [tempDE addObject:key];
    }
    
    // Sort array
    NSArray *sortedKeysDE = [tempDE sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    keysDE = [[NSMutableArray alloc] initWithArray:sortedKeysDE];;
    
    
    // SORT KEYS LATIN
    NSMutableArray *tempLat = [[NSMutableArray alloc] init];
    
    // Add all keys to the array
    for(NSString *key in keysLAT) {
        [tempLat addObject:key];
    }
    
    // Sort array
    NSArray *sortedKeysLAT = [tempLat sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    keysLAT = [[NSMutableArray alloc] initWithArray:sortedKeysLAT];
    
    // copy all keys into other array
    keysAllDE = [[NSMutableArray alloc] initWithArray:keysDE];
    keysAllLAT = [[NSMutableArray alloc] initWithArray:keysLAT];
}

- (void) appendToDictionary:(Organism *)organism
{
    // GERMAN NAME
    if([organism getNameDe].length > 0) {
        NSString *firstLetterDE = [[organism getNameDe] substringToIndex:1];
        
        // Put all "umlaute" under there belonging character
        // ä => a, ö => o, ü => u
        if([firstLetterDE isEqual:@"Ü"]) {
            firstLetterDE = @"U";
        } else if([firstLetterDE isEqual:@"Ö"]) {
            firstLetterDE = @"O";            
        } else if([firstLetterDE isEqual:@"Ä"]) {
            firstLetterDE = @"A";
        }
        
        // Create Letter index if it doesn't already exist
        if(![keysDE containsObject:firstLetterDE]) {
            
            // Does not contain the key letter
            [keysDE addObject:[firstLetterDE uppercaseString]];
            NSMutableArray *newArray = [[NSMutableArray alloc] init];
            [newArray addObject:organism];
            [dictOrganismsDE setObject:newArray forKey:firstLetterDE];
            
        } else {
            
            // Add the organism to the corresponding letter
            NSMutableArray *arrayOrganisms = [dictOrganismsDE objectForKey:firstLetterDE];
            [arrayOrganisms addObject:organism];
            [dictOrganismsDE setObject:arrayOrganisms forKey:firstLetterDE];
            
        }
    }
    
    // LAT NAME
    if([organism.genus isKindOfClass:[NSString class]] && organism.genus.length > 0) {
        NSString *firstLetterLAT = [organism.genus substringToIndex:1];  
        
        if([firstLetterLAT isEqual:@"Ü"]) {
            firstLetterLAT = @"U";
        } else if([firstLetterLAT isEqual:@"Ö"]) {
            firstLetterLAT = @"O";            
        } else if([firstLetterLAT isEqual:@"Ä"]) {
            firstLetterLAT = @"A";
        }
        
        // Create Letter index if it doesn't already exist
        if(! [keysLAT containsObject:firstLetterLAT]) {
            
            // Does not contain the key letter
            [keysLAT addObject:[firstLetterLAT uppercaseString]];
            NSMutableArray *newArray = [[NSMutableArray alloc] init];
            [newArray addObject:organism];
            [dictOrganismsLAT setObject:newArray forKey:firstLetterLAT];
            
        } else {
            
            // Add the organism to the corresponding letter
            NSMutableArray *arrayOrganisms = [dictOrganismsLAT objectForKey:firstLetterLAT];
            [arrayOrganisms addObject:organism];
            [dictOrganismsLAT setObject:arrayOrganisms forKey:firstLetterLAT];
            
        }
    }
}

- (IBAction) wikipediaLinkClicked:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    UIButton *button = (UIButton *)sender;
    UIView *accessoryView = (UIView *) button.superview;
    UITableViewCell *cell = (UITableViewCell *)accessoryView.superview;
    UITableView *tableView = (UITableView *)cell.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:cell];
    NSLog(@"wikibutton in row :%d", indexPath.row);
    

    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [[self getCurrentKey] objectAtIndex:section];
    NSArray *nameSection = [[self getCurrentDict] objectForKey:key];
    
    // Get the selected row
    Organism *organism = [nameSection objectAtIndex:row];

    NSLog(@"organism: %@", organism.nameDe);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    // Create the ObservationsOrganismViewController
    ObservationsOrganismDetailViewWikipediaController *organismWikipediaController 
                = [[ObservationsOrganismDetailViewWikipediaController alloc] initWithNibName:@"ObservationsOrganismDetailViewWikipediaController" bundle:[NSBundle mainBundle]];
    
    // Build the lat search name for the wikipedia search
    NSString *latName = [[NSString alloc] initWithFormat:@"%@_%@", organism.genus, organism.species];
    
    // Set the latname on the controller
    organismWikipediaController.latName = latName;
    organismWikipediaController.organism = organism;
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismWikipediaController animated:TRUE];
    [spinner stopAnimating];
    organismWikipediaController = nil;
}




////////////////////////////////////////////////////////////////////////////////////////////////
// TABLE DELEGATE
//
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    if(!isSearching) {
        NSMutableArray *arrKeys = [[NSMutableArray alloc] init];
        
        // Add all keys to the array
        for(NSString *key in [self getCurrentKey]) {
            [arrKeys addObject:key];
        }
        
        // Sort array
        NSArray *sortedArray = [arrKeys sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
        
        return sortedArray;
    } else {
        return nil;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ([[self getCurrentKey] count] > 0) ? [[self getCurrentKey] count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // show emtpy message
    if ([[self getCurrentKey] count] == 0) return 1;
    
    NSString *key = [[self getCurrentKey] objectAtIndex:section];
    NSArray *nameSection = [[self getCurrentDict] objectForKey:key];
    
    return [nameSection count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([[self getCurrentKey] count] == 0)
        return nil;
    
    NSString *key = [[self getCurrentKey] objectAtIndex:section];
    
	if (key == UITableViewIndexSearch)
        return nil;
    
    return key;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [search resignFirstResponder];
    isSearching = NO;
    
    [tableView reloadData];
    
    return indexPath;	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //static NSString *cellIdentifier = @"CustomOrganismCell";
    //UITableViewCell *oCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    CustomOrganismCell *cell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomOrganismCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                cell =  (CustomOrganismCell *)currentObject;
                break;
            }
        }
    } else {
        cell = (CustomOrganismCell *)cell;
    }
    
    //show empty message
    if ([[self getCurrentKey] count] == 0){
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = NSLocalizedString(@"organismNotFound", nil);
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:16];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.wikiButton.hidden = true;
        return cell;
    }
    
    NSString *key = [[self getCurrentKey] objectAtIndex:section];
    NSArray *nameSection = [[self getCurrentDict] objectForKey:key];
	
    Organism *organism = [nameSection objectAtIndex:row];
    
    if(displayGermanNames) {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:12];    
    } else {
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:13];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    }
    
    // German/Lat names
    if (displayGermanNames) {
        cell.textLabel.text = [organism getNameDe];
        
        //if(![[organism getNameDe] isEqualToString:organism.nameLat]) {
            cell.detailTextLabel.text = organism.nameLat;            
        //}
    } else {
        cell.textLabel.text = organism.nameLat;
        
        //if(![[organism getNameDe] isEqualToString:organism.nameLat]) {
            cell.detailTextLabel.text = [organism getNameDe];            
        //}
    }
    
//    cell.wikiButton.action = @selector(viewArticle:indexPath);
//    cell.wikiButton.tag = indexPath.row;
    [cell.wikiButton addTarget:self action:@selector(wikipediaLinkClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSString *key = [[self getCurrentKey] objectAtIndex:index];
    
    if (key == UITableViewIndexSearch) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    } else {
        return index;   
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        
    // if no data message ist displayed do nothing
    if ([[self getCurrentKey] count] == 0){
        NSLog(@"click on no data");
    }else {        
        NSLog(@"click on a organism");
        NSUInteger section = [indexPath section];
        NSUInteger row = [indexPath row];
        
        NSString *key = [[self getCurrentKey] objectAtIndex:section];
        NSArray *nameSection = [[self getCurrentDict] objectForKey:key];
        
        // Get the selected row
        Organism *currentSelectedOrganism = [nameSection objectAtIndex:row];
        
        // Create the ObservationsOrganismViewController
        ObservationsOrganismSubmitController *organismSubmitController = [[ObservationsOrganismSubmitController alloc] 
                                                                          initWithNibName:@"ObservationsOrganismSubmitController" 
                                                                          bundle:[NSBundle mainBundle]];
        
        // Set the current displayed organism
        organismSubmitController.organism = currentSelectedOrganism;
        organismSubmitController.review = false;
        organismSubmitController.comeFromOrganism = true;
        organismSubmitController.inventory = inventory;
        
        // Switch the View & Controller
        [self.navigationController pushViewController:organismSubmitController animated:TRUE];
        organismSubmitController = nil;
        
    }
}

// UISEARCHBAR DELEGATE
//
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
    if ([searchTerm length] == 0) {
        [self resetSearch];
        [table reloadData];
        return;
    }
    else if ([searchTerm length] < 3) {
        return;
    }
    [[self getCurrentKey] removeAllObjects];
    [self handleSearchForTerm:searchTerm];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self handleSearchForTerm:searchBar.text];
    [searchBar resignFirstResponder];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    isSearching = NO;
    search.text = @"";
    [self resetSearch];
    [table reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    isSearching = YES;
    [table reloadData];
}

- (void)resetSearch {
    NSMutableDictionary *alldictCopy = [(displayGermanNames) ? self.dictAllOrganismsDE : self.dictAllOrganismsLAT mutableDeepCopy];
    
    if(displayGermanNames) {
        self.dictOrganismsDE = alldictCopy;
    } else {
        self.dictOrganismsLAT = alldictCopy;
    }
    
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    [keyArray addObjectsFromArray:[[(displayGermanNames) ? self.dictAllOrganismsDE : self.dictAllOrganismsLAT allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    
    if(displayGermanNames) {
        self.keysDE = keyArray;
    } else {
        self.keysLAT = keyArray;
    }
    
}

- (void)handleSearchForTerm:(NSString *)searchTerm {    
    NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
    [self resetSearch];
    
    NSArray *chunks = [searchTerm componentsSeparatedByString: @" "];
    
    for (NSString *key in [self getCurrentKey]) {
        NSMutableArray *array = [[self getCurrentDict] valueForKey:key];
        NSMutableArray *toRemove = [[NSMutableArray alloc] init];
        
        for (Organism *organism in array) {
            
            // IF the genus or the species is null jump to next organism
            if(organism.genus != nil && organism.species != nil) {
                
                // if only the german name is available
                if([organism.genus length] == 0 && [organism.species length] == 0) {
                    if([[organism getNameDe] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        [toRemove addObject:organism];
                        continue;
                    }
                }
                
                // Check if found in DE
                if ([[organism getNameDe] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    // if in searchterm is more than 1 term check genus&species
                    if([chunks count] > 1 && [[chunks objectAtIndex:0] length] > 1 && [[chunks objectAtIndex:1] length] > 1) {
                        if([organism.genus rangeOfString:[chunks objectAtIndex:0] options:NSCaseInsensitiveSearch].location == NSNotFound ||
                           [organism.species rangeOfString:[chunks objectAtIndex:1] options:NSCaseInsensitiveSearch].location == NSNotFound) {
                            [toRemove addObject:organism];
                        }
                        // else search just in the genus
                    }else if([[chunks objectAtIndex:0] length] > 1 && 
                             [organism.genus rangeOfString:[chunks objectAtIndex:0] options:NSCaseInsensitiveSearch].location == NSNotFound){
                        [toRemove addObject:organism];
                    }
                }
            }else{
                [toRemove addObject:organism];    
            }
        }
        
        if ([array count] <= [toRemove count])
            [sectionsToRemove addObject:key];
        
        [array removeObjectsInArray:toRemove];
    }
    [[self getCurrentKey] removeObjectsInArray:sectionsToRemove];
    [table reloadSectionIndexTitles];
    [table reloadData];
}

- (BOOL) isEmptyString:(NSString *) string {
    if([string length] == 0) { //string is empty or nil
        return YES;
    } else if([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        //string is all whitespace
        return YES;
    }
    return NO;
}


// SCROLLVIEW DELEGATE
//
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [search resignFirstResponder];
}

- (void) threadStartAnimating:(id)data {
    [spinner startAnimating ];
}

@end
