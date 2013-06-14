//
//  SubmissionCancelView.h
//  Naturvielfalt
//
//  Created by Albert von Felten on 11.06.13.
//
//

#import <UIKit/UIKit.h>
#import "CollectionOverviewController.h"

@interface SubmissionCancelView : UIViewController {
    
    IBOutlet UIView *cancelView;
    IBOutlet UIProgressView *progressBar;
    IBOutlet UIButton *cancelButton;
    IBOutlet UILabel *messageLabel;
    
    CollectionOverviewController *collectionOverviewController;
	
	SEL methodForExecution;
	id targetForExecution;
	id objectForExecution;
	BOOL useAnimation;
	
	BOOL dimBackground;
	
	BOOL taskInProgress;
	float graceTime;
	float minShowTime;
	NSTimer *graceTimer;
	NSTimer *minShowTimer;
	NSDate *showStarted;

	float opacity;
	
    BOOL isFinished;
	BOOL removeFromSuperViewOnHide;

}
- (IBAction)cancelPressed:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andCollectionOverviewController:(CollectionOverviewController *) coc;
- (void) updateProgress: (float) percent;

@property (nonatomic) IBOutlet UIProgressView *progressBar;
@property (nonatomic) IBOutlet UIView *cancelView;
@property (nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic) IBOutlet UILabel *messageLabel;

@end
