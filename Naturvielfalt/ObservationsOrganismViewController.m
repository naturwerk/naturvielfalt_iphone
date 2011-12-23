//
//  ObservationsOrganismViewController.m
//  Naturvielfalt
//
//  Created by Robin Oster on 28.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ObservationsOrganismViewController.h"
#import "ObservationsOrganismDetailViewController.h"
#import "ObservationsOrganismSubmitController.h"
#import "SBJson.h"
#import "Organism.h"
#import "OrganismFlora.h"
#import "OrganismFauna.h"
#import "OrganismGroup.h"

@implementation ObservationsOrganismViewController
@synthesize organismGroupId, listData, organismGroupName, dictOrganismsDE, dictOrganismsLAT, keysDE, keysLAT, isSearching, displayGermanNames, search, dictAllOrganismsDE, dictAllOrganismsLAT, keysAllDE, keysAllLAT, currKeys, currDict, spinner;


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
    [self loadFromWebsite];
    
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
    
    [title release];
    [submitButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) viewDidAppear:(BOOL)animated {
    // Reset search
    [self resetSearch]; 
    
    // Table reload data
    [table reloadData];
}

- (NSMutableDictionary *) getCurrentDict 
{
    return (displayGermanNames) ? dictOrganismsDE : dictOrganismsLAT;
}

- (NSMutableArray *) getCurrentKey
{
    return (displayGermanNames) ? keysDE : keysLAT;
}

- (void) changeNameLanguage 
{
    // Change button label
    self.navigationItem.rightBarButtonItem.title = (displayGermanNames) ? @"DE" : @"LAT";
    displayGermanNames = !displayGermanNames;
    
    [table reloadData];
}


- (void) loadFromWebsite 
{
    
    // Init all needed dictionaries
    dictOrganismsDE = [[NSMutableDictionary alloc] init];
    dictOrganismsLAT = [[NSMutableDictionary alloc] init];
    keysDE = [[NSMutableArray alloc] init];
    keysLAT = [[NSMutableArray alloc] init];
    
    
    // Get all oranismGroups
    PersistenceManager *persistenceManager = [[PersistenceManager alloc] init];
    [persistenceManager establishConnection];

    NSMutableArray *organisms = [persistenceManager getAllOrganisms:organismGroupId];
    
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
    NSMutableArray *sortedKeysDE = [tempDE sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    keysDE = [[NSMutableArray alloc] initWithArray:sortedKeysDE];;
    
    
    // SORT KEYS LATIN
    NSMutableArray *tempLat = [[NSMutableArray alloc] init];
    
    // Add all keys to the array
    for(NSString *key in keysLAT) {
        [tempLat addObject:key];
    }
    
    // Sort array
    NSMutableArray *sortedKeysLAT = [tempLat sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
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
        if(! [keysDE containsObject:firstLetterDE]) {
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
    
    [organism release];
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
    if ([[self getCurrentKey] count] == 0)
        return 0;
    
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
    search.text = @"";
    
    [tableView reloadData];
    
    return indexPath;	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
	
    NSString *key = [[self getCurrentKey] objectAtIndex:section];
    NSArray *nameSection = [[self getCurrentDict] objectForKey:key];
	
    static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
							 SectionsTableIdentifier];
    
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SectionsTableIdentifier] autorelease];
    }
	
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
        
        if(![[organism getNameDe] isEqualToString:organism.nameLat]) {
            cell.detailTextLabel.text = organism.nameLat;            
        }
    } else {
        cell.textLabel.text = organism.nameLat;

        if(![[organism getNameDe] isEqualToString:organism.nameLat]) {
            cell.detailTextLabel.text = [organism getNameDe];            
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    NSString *key = [keysDE objectAtIndex:index];
    
    if (key == UITableViewIndexSearch) {
        [tableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    } else {
        return index;   
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [[self getCurrentKey] objectAtIndex:section];
    NSArray *nameSection = [[self getCurrentDict] objectForKey:key];
    
    // Get the selected row
    Organism *currentSelectedOrganism = [nameSection objectAtIndex:row];
    
    // Create the ObservationsOrganismViewController
    ObservationsOrganismDetailViewController *organismDetailViewController = [[ObservationsOrganismDetailViewController alloc] 
                                                                              initWithNibName:@"ObservationsOrganismDetailViewController" 
                                                                              bundle:[NSBundle mainBundle]];
    
    // set the organismGroupId so it know which inventory is selected
    organismDetailViewController.organism = currentSelectedOrganism;
    
    // Start the spinner
    [NSThread detachNewThreadSelector:@selector(threadStartAnimating:) toTarget:self withObject:nil];
    
    // Switch the View & Controller
    [self.navigationController pushViewController:organismDetailViewController animated:TRUE];
    
    [spinner stopAnimating];
    
    [organismDetailViewController release];
    organismDetailViewController = nil;
}



////////////////////////////////////////////////////////////////////////////////////////////////
// UISEARCHBAR DELEGATE
//
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchTerm {
    if ([searchTerm length] == 0) {
        [self resetSearch];
        [table reloadData];
        return;
    }
    [self handleSearchForTerm:searchTerm];
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
    
    [alldictCopy release];
    
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    [keyArray addObjectsFromArray:[[(displayGermanNames) ? self.dictAllOrganismsDE : self.dictAllOrganismsLAT allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    
    if(displayGermanNames) {
        self.keysDE = keyArray;
    } else {
        self.keysLAT = keyArray;
    }
    
    [keyArray release];
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
            if(organism.genus != [NSNull null] && organism.species != [NSNull null]) {
                            
                if([organism.genus length] == 0 || [organism.species length] == 0) {
                    if([[organism getNameDe] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
                        [toRemove addObject:organism]; 
                        continue;
                    }
                }
                
                if ([[organism getNameDe] rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound &&
                    [organism.genus rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound &&
                    [organism.species rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
                    
                    // Also check for the chunks
                    if([chunks count] == 2 && ![self isEmptyString:[chunks objectAtIndex:0]] && 
                                              ![self isEmptyString:[chunks objectAtIndex:1]] &&
                                              [[chunks objectAtIndex:0] length] == 2 && 
                                              [[chunks objectAtIndex:1] length] == 2) {
     
                        
                        if([[organism.genus lowercaseString] characterAtIndex:0] != [[[chunks objectAtIndex:0] lowercaseString] characterAtIndex:0] || 
                           [[organism.genus lowercaseString] characterAtIndex:1] != [[[chunks objectAtIndex:0] lowercaseString] characterAtIndex:1] ||
                           [[organism.species lowercaseString] characterAtIndex:0] != [[[chunks objectAtIndex:1] lowercaseString] characterAtIndex:0] || 
                           [[organism.species lowercaseString] characterAtIndex:1] != [[[chunks objectAtIndex:1] lowercaseString] characterAtIndex:1]) {
                            
                            // Remove organism
                            [toRemove addObject:organism];
                        }
                    } else {
                        [toRemove addObject:organism];    
                    }
                }
            } else {
                [toRemove addObject:organism];
            }
        }
        
        if ([array count] <= [toRemove count])
            [sectionsToRemove addObject:key];
		
        [array removeObjectsInArray:toRemove];
        [toRemove release];
    }
    [[self getCurrentKey] removeObjectsInArray:sectionsToRemove];
    [sectionsToRemove release];
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




////////////////////////////////////////////////////////////////////////////////////////////////
// SCROLLVIEW DELEGATE
//
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [search resignFirstResponder];
}

- (void) threadStartAnimating:(id)data {
    [spinner startAnimating];
}

@end
