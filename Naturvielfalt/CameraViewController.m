//
//  CameraViewController.m
//  Camera
//
//  Created by Dave Mark on 12/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Observation.h"
#import "ObservationImage.h"

@interface CameraViewController ()
static UIImage *shrinkImage(UIImage *original, CGSize size);
- (void)updateDisplay;
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;
@end

@implementation CameraViewController
@synthesize deletePhotoButton, moviePlayerController, image, movieURL, lastChosenMediaType, observation, takePhotoButton, chooseExistingButton;

- (void)viewDidLoad {
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        takePhotoButton.hidden = YES;
    }
    imageFrame = CGRectMake(0, 0, 320, 270);
    
    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"photoNavTitle", nil);
    self.navigationItem.title = title;
    
    [takePhotoButton setTitle:NSLocalizedString(@"photoNew", nil) forState:UIControlStateNormal];
    [chooseExistingButton setTitle:NSLocalizedString(@"photoExisting", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Get current observation
    observation = [[Observation alloc] getObservation];
      
    if(observation.pictures.count > 0) {
        //self.image = (UIImage *)[observation.pictures objectAtIndex:0];
        
        // Set the media type
        lastChosenMediaType = (NSString *)kUTTypeImage;
    } 
    
    [self updateDisplay];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.takePhotoButton = nil;
    self.moviePlayerController = nil;
    
    [self setDeletePhotoButton:nil];
    [super viewDidUnload];
}

-(NSArray *) images
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    if (observation) {
        for (ObservationImage *obsImg in observation.pictures) {
            [images addObject:obsImg.image];
        }
    }
    
    //Sample data
    /*NSArray *imageNames = [NSArray arrayWithObjects:@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", nil];
     NSMutableArray *images = [NSMutableArray array];
     for (NSString *imageName in imageNames) [images addObject:[UIImage imageNamed:imageName]];*/
    
    return images;
}


- (IBAction)shootPictureOrVideo:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)selectExistingPictureOrVideo:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)deleteCurrentPhoto:(id)sender {
    UIAlertView *areaAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"areaDeletePhoto", nil)
                                                        message:NSLocalizedString(@"areaDeletePhotoMessage", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"areaCancelMod", nil)
                                              otherButtonTitles:NSLocalizedString(@"navOk", nil) , nil];
    [areaAlert show];
}

#pragma mark
#pragma UIAlertViewDelegate Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        //ok pressed
        if (observation) {
            [observation.pictures removeObjectAtIndex:[imageViewer currentPage]];
        }
        [self updateDisplay];
    }
}

#pragma mark UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.lastChosenMediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *shrunkenImage = shrinkImage(chosenImage, imageFrame.size);
        self.image = shrunkenImage;
        
        if (observation) {
            ObservationImage *oImg = [[ObservationImage alloc] getObservationImage];
            oImg.image = shrunkenImage;
            [observation.pictures addObject:oImg];
            [oImg setObservationImage:nil];
        }
        
        /*NSMutableArray *arrPictures = [[NSMutableArray alloc] init];
        [arrPictures addObject:shrunkenImage];
        
        observation.pictures = arrPictures;*/
        
    } else if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        self.movieURL = [info objectForKey:UIImagePickerControllerMediaURL];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {    
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark  -
static UIImage *shrinkImage(UIImage *original, CGSize size) {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, size.width * scale,
												 size.height * scale, 8, 0, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context,
					   CGRectMake(0, 0, size.width * scale, size.height * scale),
					   original.CGImage);
    CGImageRef shrunken = CGBitmapContextCreateImage(context);
    UIImage *final = [UIImage imageWithCGImage:shrunken];
    
    CGContextRelease(context);
    CGImageRelease(shrunken);	
	
    return final;
}

- (void)updateDisplay {
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        if (imageViewer) {
            [imageViewer removeFromSuperview];
        }
        
        imageViewer = [[AFImageViewer alloc] initWithFrame:CGRectMake(0, 0, 320, 270)];
        
        imageViewer.images = [[NSMutableArray alloc] initWithArray:[self images]];
        imageViewer.contentMode = UIViewContentModeScaleAspectFit;
        imageViewer.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        [self.view addSubview:imageViewer];
    } else if ([lastChosenMediaType isEqual:(NSString *)kUTTypeMovie]) {
        [self.moviePlayerController.view removeFromSuperview];
        MPMoviePlayerController *mpController = [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
        self.moviePlayerController = mpController;
        moviePlayerController.view.frame = imageFrame;
        moviePlayerController.view.clipsToBounds = YES;
        [self.view addSubview:moviePlayerController.view];
    }
    [self checkPhotoDeleteButton];
    [self.view bringSubviewToFront:deletePhotoButton];
}

- (void) checkPhotoDeleteButton {
    if (observation) {
        if (observation.pictures.count > 0) {
            deletePhotoButton.hidden = NO;
        } else {
            deletePhotoButton.hidden = YES;
        }
    }
}

- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediaTypes = [UIImagePickerController
						   availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:
         sourceType] && [mediaTypes count] > 0) {
        NSArray *mediaTypes = [UIImagePickerController
							   availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker =
        [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediaTypes;
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentModalViewController:picker animated:YES];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:NSLocalizedString(@"alertMessageMediaTitle", nil)
                              message:NSLocalizedString(@"alertMessageMedia", nil)
                              delegate:nil 
                              cancelButtonTitle:NSLocalizedString(@"navCancel", nil)
                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
