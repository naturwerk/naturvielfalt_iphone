//
//  ACollection.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.09.13.
//
//

#import "ACollectionController.h"
#import "Reachability.h"

@interface ACollectionController () {
    
}

@end

@implementation ACollectionController
@synthesize doSubmit, persistenceManager, app, pager, table, noEntryFoundLabel, loadingHUD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.doSubmit = NO;
        self.persistenceManager = [[PersistenceManager alloc] init];
        self.app = (NaturvielfaltAppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setPager:(NMPaginator *)paginator
{
    self.pager = paginator;
}

- (void)setupTableViewFooter
{
    // set up label
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footerView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    label.font = [UIFont boldSystemFontOfSize:16];
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    self.footerLabel = label;
    [footerView addSubview:label];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(40, 22);
    activityIndicatorView.hidesWhenStopped = YES;
    
    self.activityIndicator = activityIndicatorView;
    [footerView addSubview:activityIndicatorView];
    
    self.table.tableFooterView = footerView;
}

- (void)updateTableViewFooter
{
    if ([self.pager.results count] != 0)
    {
        self.footerLabel.text = [NSString stringWithFormat:@"%d results out of %d", [self.pager.results count], self.pager.total];
    } else
    {
        self.footerLabel.text = @"";
    }
    
    [self.footerLabel setNeedsDisplay];
}


- (void)fetchNextPage
{
    [self.pager fetchNextPage];
    [self.activityIndicator startAnimating];
}


- (void)paginatorDidReset:(id)paginator
{
    [self.table reloadData];
    [self updateTableViewFooter];
}


- (void)paginator:(id)paginator didReceiveResults:(NSArray *)results
{
    
    // update tableview footer
    [self updateTableViewFooter];
    [self.activityIndicator stopAnimating];
    
    // update tableview content
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSInteger i = [self.pager.results count] - [results count];
    
    for(NSDictionary *result in results)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        i++;
    }
    
    [self.table beginUpdates];
    [self.table insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [self.table endUpdates];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // when reaching bottom, load a new page
    if (table.contentOffset.y == table.contentSize.height - table.bounds.size.height)
    {
        // ask next page only if we haven't reached last page
        if(![self.pager reachedLastPage])
        {
            // fetch next page of results
            [self fetchNextPage];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pager.results count];
}

//Check if there is an active WiFi connection
- (BOOL) connectedToWiFi {
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = NO;
	
	if (internetStatus == ReachableViaWiFi)
	{
	    result = YES;
	}
	
	return result;
}

//Check if there is an active internet connection (3G OR WIFI)
- (BOOL) connectedToInternet {
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = false;
	
	if (internetStatus != NotReachable)
	{
	    result = true;
	}
	
	return result;
}


@end
