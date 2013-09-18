//
//  ACollection.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 17.09.13.
//
//

#import <UIKit/UIKit.h>
#import "NMPaginator.h"
#import "MBProgressHUD.h"
#import "PersistenceManager.h"
#import "NaturvielfaltAppDelegate.h"
#import "AlertUploadView.h"

@interface ACollectionController : UIViewController <NMPaginatorDelegate, MBProgressHUDDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) BOOL doSubmit;
@property (nonatomic) PersistenceManager *persistenceManager;
@property (nonatomic) NaturvielfaltAppDelegate *app;

//table
@property (nonatomic) IBOutlet UITableView *table;
@property (nonatomic) IBOutlet UILabel *noEntryFoundLabel;
@property (nonatomic) MBProgressHUD *loadingHUD;
@property (nonatomic) AlertUploadView *uploadView;

//paging
@property (nonatomic) NMPaginator *pager;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

- (void)setupTableViewFooter;
- (void)updateTableViewFooter;
- (void)fetchNextPage;
- (BOOL) connectedToWiFi;
- (BOOL) connectedToInternet;

@end
