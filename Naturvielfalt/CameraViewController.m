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
#import "ObservationsOrganismSubmitController.h"

@interface CameraViewController ()
static UIImage *shrinkImage(UIImage *original, CGSize size);
- (void)updateDisplay;
- (void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType;
@end

@implementation CameraViewController
@synthesize moviePlayerController,movieURL,lastChosenMediaType,observation, chooseExistingButton, takePhotoButton, area, deletePhotoButton;

- (void)viewDidLoad {
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        takePhotoButton.hidden = YES;
    }
    imageFrame = CGRectMake(0, 0, 320, 270);
    
    // Set navigation bar title    
    NSString *title = NSLocalizedString(@"photoNavTitle", nil);
    self.navigationItem.title = title;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"navSave", nil)
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(persistPhotos)];
    
    self.navigationItem.rightBarButtonItem = backButton;
    
    [takePhotoButton setTitle:NSLocalizedString(@"photoNew", nil) forState:UIControlStateNormal];
    [chooseExistingButton setTitle:NSLocalizedString(@"photoExisting", nil) forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Get current observation
    //observation = [[Observation alloc] getObservation];
    
    // Get current area;
    //area = [[Area alloc] getArea];
    
    if (observation) {
        if(observation.pictures.count > 0) {
            // Set the media type
            lastChosenMediaType = (NSString *)kUTTypeImage;
        } 
    } else if (area) {
        if(area.pictures.count > 0) {
            // Set the media type
            lastChosenMediaType = (NSString *)kUTTypeImage;
        }
    }
    [self updateDisplay];
}

-(NSArray *) images
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    if (observation) {
        for (ObservationImage *obsImg in observation.pictures) {
            [images addObject:obsImg.image];
        }
    } else if (area) {
        for (AreaImage *areaImg in area.pictures) {
            [images addObject:areaImg.image];
        }
    }
    
    //Sample data
    /*NSArray *imageNames = [NSArray arrayWithObjects:@"1.jpg", @"2.jpg", @"3.jpg", @"4.jpg", nil];
    NSMutableArray *images = [NSMutableArray array];
    for (NSString *imageName in imageNames) [images addObject:[UIImage imageNamed:imageName]];*/
    
    return images;
}

- (void) viewWillAppear:(BOOL)animated {
    if (area.areaId) {
        if(!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        [persistenceManager establishConnection];
        Area *tmpArea = [persistenceManager getArea:area.areaId];
        [persistenceManager closeConnection];
        
        if (!tmpArea) {
            [self.navigationController popViewControllerAnimated:TRUE];
        } else {
            for (AreaImage *aImg in area.pictures) {
                if (!aImg.areaImageId) {
                    [tmpArea.pictures addObject:aImg];
                }
            }
            area = tmpArea;
        }
        tmpArea = nil;
    } else if (observation.observationId) {
        if(!persistenceManager) {
            persistenceManager = [[PersistenceManager alloc] init];
        }
        [persistenceManager establishConnection];
        Observation *tmpObservation = [persistenceManager getObservation:observation.observationId];
        [persistenceManager closeConnection];
        
        if (!tmpObservation) {
            [self.navigationController popViewControllerAnimated:TRUE];
        } else {
            for (ObservationImage *oImg in observation.pictures) {
                if (!oImg.observationImageId) {
                    [tmpObservation.pictures addObject:oImg];
                }
            }
            observation = tmpObservation;
        }
        tmpObservation = nil;
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    
    [self persistPhotos];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.moviePlayerController = nil;
    
    [self setChooseExistingButton:nil];
    [self setTakePhotoButton:nil];
    [self setDeletePhotoButton:nil];
    [super viewDidUnload];
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
        if (area) {
            [area.pictures removeObjectAtIndex:[imageViewer currentPage]];
        } else if (observation) {
            [observation.pictures removeObjectAtIndex:[imageViewer currentPage]];
        }
        [self updateDisplay];
    }
}


- (void) persistPhotos {
    
    if (!persistenceManager) {
        persistenceManager = [[PersistenceManager alloc] init];
    }
    [persistenceManager establishConnection];
    
    if (area) {
        if (area.areaId) {
            //Delete all photos from area first, then save the new images
            [persistenceManager deleteAreaImagesFromArea:area.areaId];
            for (AreaImage *aImg in area.pictures) {
                aImg.areaId = area.areaId;
                aImg.areaImageId = [persistenceManager saveAreaImage:aImg];
            }
        } else {
            [area setArea:area];
            
        }
    } else if (observation) {
        /*if (observation.observationId) {
            //Delete all photos from observation first, then save the new images
            [persistenceManager deleteObservationImagesFromObservation:observation.observationId];
            for (ObservationImage *oImg in observation.pictures) {
                oImg.observationId = observation.observationId;
                oImg.observationImageId = [persistenceManager saveObservationImage:oImg];
            }
        } else {
            [observation setObservation:observation];
        }*/
        [ObservationsOrganismSubmitController persistObservation:observation inventory:observation.inventory];
    }
    [persistenceManager closeConnection];
    
    // Switch the View & Controller
    // POP
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.lastChosenMediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage]) {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage *shrunkenImage = shrinkImage(chosenImage, imageFrame.size);
        
        if (area) {
            AreaImage *aImg = [[AreaImage alloc] getAreaImage];
            aImg.image = shrunkenImage;
            [area.pictures addObject:aImg];
            [aImg setAreaImage:nil];
        } else if(observation) {
            ObservationImage *oImg = [[ObservationImage alloc] getObservationImage];
            oImg.image = shrunkenImage;
            [observation.pictures addObject:oImg];
            [oImg setObservationImage:nil];
        }
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
    if (area) {
        if (area.pictures.count > 0) {
            deletePhotoButton.hidden = NO;
        } else {
            deletePhotoButton.hidden = YES;
        }
    } else if (observation) {
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
