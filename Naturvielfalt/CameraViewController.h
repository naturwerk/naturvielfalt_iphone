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

@interface CameraViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    PersistenceManager *persistenceManager;
    UIImageView *imageView;
    UIButton *takePictureButton;
    MPMoviePlayerController *moviePlayerController;
    UIImage *image;
    NSURL *movieURL;
    NSString *lastChosenMediaType;
    CGRect imageFrame;
    Observation *observation;
    Area *area;
    
    IBOutlet UIButton *takePhotoButton;
    IBOutlet UIButton *chooseExistingButton;
}
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIButton *takePictureButton;
@property (nonatomic) MPMoviePlayerController *moviePlayerController;
@property (nonatomic) UIImage *image;
@property (nonatomic) NSURL *movieURL;
@property (nonatomic, copy) NSString *lastChosenMediaType;
@property (nonatomic) Observation *observation;
@property (nonatomic) Area *area;
@property (nonatomic) IBOutlet UIButton *chooseExistingButton;
@property (nonatomic) IBOutlet UIButton *takePhotoButton;

- (IBAction)shootPictureOrVideo:(id)sender;
- (IBAction)selectExistingPictureOrVideo:(id)sender;
@end
