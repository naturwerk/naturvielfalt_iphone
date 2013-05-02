//
//  CollectionAreasController.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 30.04.13.
//
//

#import "CollectionAreasController.h"
#import "CheckboxAreaCell.h"
#import "Area.h"
#import "Reachability.h"

@interface CollectionAreasController ()

@end

@implementation CollectionAreasController
@synthesize tableView, areas;

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
    
    // Set the title of the Navigationbar
    NSString *title = NSLocalizedString(@"areaTabLabel", nil);
    self.navigationItem.title = title;
    
    // Create filter button and add it to the NavigationBar
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"navSubmit", nil)
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action: @selector(alertOnSendAreasDialog)];
    
    self.navigationItem.rightBarButtonItem = filterButton;
    
    tableView.delegate = self;
    
    [self prepareData];
}

- (void) prepareData {
    
    if (!areas) {
        areas = [[NSMutableArray alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

//Check if there is an active WiFi connection
- (BOOL) connectedToWiFi{
    Reachability *r = [Reachability reachabilityWithHostName:@"www.google.com"];
	
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	
	bool result = false;
	
	if (internetStatus == ReachableViaWiFi)
	{
	    result = true;
	}
	
	return result;
}

//fires an alert if not connected to WiFi
- (void) alertOnSendAreasDialog{
    doSubmit = TRUE;
    if([self connectedToWiFi]){
        [self sendAreas];
    }
    else {
        UIAlertView *submitAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"collectionAlertAreaTitle", nil)
                                                              message:NSLocalizedString(@"collectionAlertAreaDetail", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"navCancel", nil)
                                                    otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
        [submitAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(doSubmit){
        if (buttonIndex == 1){
            [self sendAreas];
        }
        doSubmit = FALSE;
    }
}

- (void) sendAreas {
    NSLog(@"send Inventories");
}

#pragma UITableViewDelegates methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [areas count];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CheckboxAreaCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
    
    // use CustomCell layout
    CheckboxAreaCell *checkboxAreaCell;
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CheckboxAreaCell" owner:self options:nil];
        
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
                checkboxAreaCell =  (CheckboxAreaCell *)currentObject;
                break;
            }
        }
    } else {
        checkboxAreaCell = (CheckboxAreaCell *)cell;
    }
    
    Area *area = [areas objectAtIndex:indexPath.row];
    
    if(area != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd.MM.yyyy";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        NSString *nowString = [dateFormatter stringFromDate:area.date];
        
        if(area.pictures.count > 0){
            UIImage *original = (UIImage *)[area.pictures objectAtIndex:0];
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
            checkboxAreaCell.image.image = final;
        }
        else {
            checkboxAreaCell.image.image = [UIImage imageNamed:@"blank.png"];
        }

        checkboxAreaCell.title.text = area.name;
        checkboxAreaCell.date.text = nowString;
        checkboxAreaCell.count.text = [NSString stringWithFormat:@"%i", area.inventories.count];
        checkboxAreaCell.subtitle.text = area.author;
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaCell.checkbox addTarget:self action:@selector(checkboxEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaCell.checkbox setTag:area.areaId];
        
        // Define the action on the button and the current row index as tag
        [checkboxAreaCell.remove addTarget:self action:@selector(removeEvent:) forControlEvents:UIControlEventTouchUpInside];
        [checkboxAreaCell.remove setTag:area.areaId];
        
        // Set checkbox icon
        if(area.submitToServer) {
            checkboxAreaCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox_checked.png"];
        } else {
            checkboxAreaCell.checkbox.imageView.image = [UIImage imageNamed:@"checkbox.gif"];
        }
    }
    
    return checkboxAreaCell;
}

- (void) checkboxEvent {
    NSLog(@"checkboxEvent");
}

- (void) removeEvent {
    NSLog(@"removeEvent");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

@end
