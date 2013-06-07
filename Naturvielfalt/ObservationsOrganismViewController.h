//
//  ObservationsOrganismViewController.h
//  Naturvielfalt
//
//  Created by Robin Oster on 28.09.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Organism.h"
#import "PersistenceManager.h"

@interface ObservationsOrganismViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate> {
    
    NSMutableArray *listData;
    NSInteger organismGroupId;
    NSString *organismGroupName;
    BOOL displayGermanNames;
    IBOutlet UITableView  *table;
    IBOutlet UISearchBar *search;
    PersistenceManager *persistenceManager;
    
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
@property (nonatomic) NSMutableArray *listData;
@property (nonatomic) NSString *organismGroupName;
@property (nonatomic) UISearchBar *search;
@property (nonatomic) NSMutableDictionary *dictAllOrganismsDE;
@property (nonatomic) NSMutableDictionary *dictAllOrganismsLAT;
@property (nonatomic) NSMutableDictionary *dictOrganismsDE;
@property (nonatomic) NSMutableDictionary *dictOrganismsLAT;
@property (nonatomic) NSMutableDictionary *currDict;
@property (nonatomic) NSMutableArray *keysAllDE;
@property (nonatomic) NSMutableArray *keysAllLAT;
@property (nonatomic) NSMutableArray *keysDE;
@property (nonatomic) NSMutableArray *keysLAT;
@property (nonatomic) NSMutableArray *currKeys;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic) IBOutlet UIActivityIndicatorView *spinner;


- (void) appendToDictionary:(Organism *)organism;
- (void) resetSearch;
- (void) handleSearchForTerm:(NSString *)searchTerm;
- (NSMutableDictionary *) getCurrentDict;
- (NSMutableArray *) getCurrentKey;
- (BOOL) isEmptyString:(NSString *) string;
- (void) threadStartAnimating:(id)data;

@end