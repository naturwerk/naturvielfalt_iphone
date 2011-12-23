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

@interface CameraViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIImageView *imageView;
    UIButton *takePictureButton;
    MPMoviePlayerController *moviePlayerController;
    UIImage *image;
    NSURL *movieURL;
    NSString *lastChosenMediaType;
    CGRect imageFrame;
    Observation *observation;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *takePictureButton;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSURL *movieURL;
@property (nonatomic, copy) NSString *lastChosenMediaType;
@property (nonatomic, retain) Observation *observation;

- (IBAction)shootPictureOrVideo:(id)sender;
- (IBAction)selectExistingPictureOrVideo:(id)sender;
@end
