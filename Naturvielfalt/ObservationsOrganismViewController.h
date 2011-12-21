//
//  ObservationsOrganismViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 28.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organism.h"

@interface ObservationsOrganismViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate> {
    
    NSMutableArray *listData;
    NSInteger organismGroupId;
    NSString *organismGroupName;
    BOOL displayGermanNames;
    IBOutlet UITableView  *table;
    IBOutlet UISearchBar *search;
    
    // FOR SEARCH and INDEXED TABLE
    // Dictionaries
    NSMutableDictionary *dictAllOrganismsDE;
    NSMutableDictionary *dictAllOrganismsLAT;
    NSMutableDictionary *dictOrganismsDE;
    NSMutableDictionary *dictOrganismsLAT;
    NSMutableDictionary *currDict;
    
    // Keys
    NSMutableArray *keysAllDE;
    NSMutableArray *keysAllLAT;
    NSMutableArray *keysDE;
    NSMutableArray *keysLAT;
    NSMutableArray *currKeys;
	BOOL isSearching;
    
    IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, assign) NSInteger organismGroupId;
@property (nonatomic, assign) BOOL displayGermanNames;
@property (nonatomic, retain) NSMutableArray *listData;
@property (nonatomic, retain) NSString *organismGroupName;
@property (nonatomic, retain) UISearchBar *search;
@property (nonatomic, retain) NSMutableDictionary *dictAllOrganismsDE;
@property (nonatomic, retain) NSMutableDictionary *dictAllOrganismsLAT;
@property (nonatomic, retain) NSMutableDictionary *dictOrganismsDE;
@property (nonatomic, retain) NSMutableDictionary *dictOrganismsLAT;
@property (nonatomic, retain) NSMutableDictionary *currDict;
@property (nonatomic, retain) NSMutableArray *keysAllDE;
@property (nonatomic, retain) NSMutableArray *keysAllLAT;
@property (nonatomic, retain) NSMutableArray *keysDE;
@property (nonatomic, retain) NSMutableArray *keysLAT;
@property (nonatomic, retain) NSMutableArray *currKeys;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (void) loadFromWebsite;
- (void) appendToDictionary:(Organism *)organism;
- (void) resetSearch;
- (void) handleSearchForTerm:(NSString *)searchTerm;
- (NSMutableDictionary *) getCurrentDict;
- (NSMutableArray *) getCurrentKey;
- (BOOL) isEmptyString:(NSString *) string;
- (void) threadStartAnimating:(id)data;

@end