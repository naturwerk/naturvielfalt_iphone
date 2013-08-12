//
//  CameraViewController.h
//  Camera
//
//  Created by Dave Mark on 12/16/10. 
//  Adapted by Robin Oster.
//
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Observation.h"
#import "Area.h"
#import "PersistenceManager.h"
#import "AFImageViewer.h"

@interface CameraViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    PersistenceManager *persistenceManager;
    MPMoviePlayerController *moviePlayerController;
    NSURL *movieURL;
    NSString *lastChosenMediaType;
    CGRect imageFrame;
    Observation *observation;
    Area *area;
    AFImageViewer *imageViewer;
    int currentPage;
    
    IBOutlet UIButton *takePhotoButton;
    IBOutlet UIButton *chooseExistingButton;
    IBOutlet UIButton *deletePhotoButton;
}
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@property (nonatomic) NSURL *movieURL;
@property (nonatomic, copy) NSString *lastChosenMediaType;
@property (nonatomic) Observation *observation;
@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UIButton *chooseExistingButton;
@property (nonatomic) IBOutlet UIButton *takePhotoButton;
@property (nonatomic) IBOutlet UIButton *deletePhotoButton;

- (IBAction)shootPictureOrVideo:(id)sender;
- (IBAction)selectExistingPictureOrVideo:(id)sender;
- (IBAction)deleteCurrentPhoto:(id)sender;

@end
