//
//  SubmissionCancelView.m
//  Naturvielfalt
//
//  Created by Albert von Felten on 11.06.13.
//
//

#import "SubmissionCancelView.h"
#import <QuartzCore/QuartzCore.h>

@interface SubmissionCancelView ()

@end

@implementation SubmissionCancelView
@synthesize cancelButton, cancelView, progressBar, messageLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andCollectionOverviewController:(id)coc
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        collectionOverviewController = coc;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cancelView.layer.cornerRadius = 5;
    cancelView.frame = CGRectMake(85, 190, 150, 100);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    cancelView = nil;
    [self setProgressBar:nil];
    [self setCancelView:nil];
    [self setCancelButton:nil];
    [self setMessageLabel:nil];
    [super viewDidUnload];
}
- (IBAction)cancelPressed:(id)sender {
    NSLog(@"button pressed");
    cancelButton.enabled = NO;
    
    /*if (collectionOverviewController) {
        [collectionOverviewController setCancelSubmission:YES];
    }*/
}

- (void) updateProgress:(float)percent {
    [progressBar setProgress:percent];
}

@end
