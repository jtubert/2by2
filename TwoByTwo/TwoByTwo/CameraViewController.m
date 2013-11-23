//
//  CameraViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CameraViewController.h"
#import "GPUImage.h"
#import "ProgressButton.h"
#import "AppDelegate.h"
#import "UIImage+UIImageResizing.h"


typedef NS_ENUM(NSUInteger, CameraViewState) {
    CameraViewStateTakePhoto = 0,
    CameraViewStateReadyToUpload,
    CameraViewStateUploading,
    CameraViewStateDone,
};



@interface CameraViewController ()
@property (nonatomic, weak) IBOutlet GPUImageView *liveView;
@property (nonatomic, weak) IBOutlet UIImageView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *topButton;
@property (nonatomic, weak) IBOutlet ProgressButton *bottomButton;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@property (nonatomic) CameraViewState state;
@property (nonatomic) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@end


@implementation CameraViewController

+ (instancetype)controller
{
    CameraViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraViewController"];
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    self.state = CameraViewStateTakePhoto;
    
    self.liveView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    
    if (self.photo) {

        __weak typeof(self) weakSelf = self;
        
        //lets check again to make sure photo is not "in-use"
        PFQuery *query = [PFQuery queryWithClassName:PFPhotoKey];
        [query includeKey:PFUserInUseKey];
        [query getObjectInBackgroundWithId:weakSelf.photo.objectId block:^(PFObject *photo, NSError *error) {
            if(!error){
                if ([photo.state isEqualToString:@"half"]) {
                    
                    [weakSelf setPhotoState:@"in-use" completion:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            [photo.imageHalf getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                                if (!error) {
                                    weakSelf.filter = [[GPUImageLightenBlendFilter alloc] init];
                                    [weakSelf.filter addTarget:weakSelf.liveView];
                                    
                                    UIImage *image = [UIImage imageWithData:data];
                                    weakSelf.sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
                                    [weakSelf.sourcePicture processImage];
                                    [weakSelf.sourcePicture addTarget:weakSelf.filter];
                                    
                                    weakSelf.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
                                    weakSelf.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
                                    [weakSelf.stillCamera addTarget:weakSelf.filter];
                                    [weakSelf.stillCamera startCameraCapture];
                                }
                                else {
                                    NSLog(@"getDataInBackgroundWithBlock: %@", error);
                                }
                            }];
                        }
                        else {
                            NSLog(@"setPhotoState: %@", error);
                            [UIAlertView showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
                        }
                    }];
                }
                else {
                    NSString *message = [NSString stringWithFormat:@"Sorry but this photo is in use by %@", photo.userInUse.username];
                    [UIAlertView showAlertViewWithTitle:@"Sorry" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        
                        [weakSelf setPhotoState:@"half" completion:^(BOOL succeeded, NSError *error) {
                            
                            if (!succeeded) {
                                NSLog(@"setPhotoState: %@", error);
                                [UIAlertView showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
                            }
                            
                            [weakSelf cleanup];
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        }];
                    }];
                }
            }else{
                NSString *message = [NSString stringWithFormat:@"Sorry there was an error: %@", error];
                [UIAlertView showAlertViewWithTitle:@"Sorry" message:message cancelButtonTitle:@"OK" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    [weakSelf setPhotoState:@"half" completion:^(BOOL succeeded, NSError *error) {
                        if (!succeeded) {
                            NSLog(@"setPhotoState: %@", error);
                            [UIAlertView showAlertViewWithTitle:@"Error" message:error.localizedDescription cancelButtonTitle:@"OK" otherButtonTitles:nil handler:nil];
                        }
                        
                        [weakSelf cleanup];
                        [weakSelf dismissViewControllerAnimated:YES completion:nil];
                    }];
                }];
            }
        }];
    }
    else {
        self.filter = [[GPUImageGammaFilter alloc] init];
        [self.filter addTarget:self.liveView];
        
        self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        [self.stillCamera addTarget:self.filter];
        [self.stillCamera startCameraCapture];
    }
}


#pragma mark - Location

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"locationManager: %@", locations);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager: %@", error);
}


#pragma mark - State

- (void)setState:(CameraViewState)state
{
    _state = state;
    switch (state) {
        case CameraViewStateTakePhoto:
            self.liveView.hidden = NO;
            self.previewView.hidden = YES;
            [self.topButton setImage:[UIImage imageNamed:@"button-close"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-shutter-black"] forState:UIControlStateNormal];
            break;
            
        case CameraViewStateReadyToUpload:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            [self.topButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-upload"] forState:UIControlStateNormal];
            break;
            
        case CameraViewStateUploading:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            [self.topButton setImage:[UIImage imageNamed:@"button-back"] forState:UIControlStateNormal];
            [self.bottomButton setImage:nil forState:UIControlStateNormal];
            self.bottomButton.outerColor = [UIColor appBlackishColor];
            self.bottomButton.innerColor = [UIColor appBlackishColor];
            self.bottomButton.trackColor = [UIColor appDarkGrayColor];
            self.bottomButton.progressColor = [UIColor appRedColor];
            self.bottomButton.trackInset = 4.0;
            self.bottomButton.trackWidth = 2.0;
            self.bottomButton.progress = 0.0;
            break;
            
        case CameraViewStateDone:
            self.liveView.hidden = YES;
            self.previewView.hidden = NO;
            [self.topButton setImage:nil forState:UIControlStateNormal];
            [self.bottomButton setImage:[UIImage imageNamed:@"button-done"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark - Actions

- (IBAction)topButtonTapped:(id)sender
{
    switch (self.state) {
        case CameraViewStateTakePhoto:
        {
            __weak typeof(self) weakSelf = self;
            [self setPhotoState:@"half" completion:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    NSLog(@"CameraViewStateTakePhoto setPhotoState: %@", error);
                }
                [weakSelf cleanup];
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];
        }
            break;
            
        case CameraViewStateReadyToUpload:
            NSLog(@"CameraViewStateReadyToUpload");
            self.state = CameraViewStateTakePhoto;
            break;
            
        case CameraViewStateUploading:
            NSLog(@"CameraViewStateUploading");
            self.state = CameraViewStateReadyToUpload;
            break;
            
        case CameraViewStateDone:
            NSLog(@"CameraViewStateDone");
        default:
            break;
    }
}

- (IBAction)bottomButtonTapped:(id)sender
{
    __weak typeof(self) weakSelf = self;

    switch (self.state) {
        case CameraViewStateTakePhoto:
        {
            __weak typeof(self) weakSelf = self;
            [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
                UIImage* smallImage = [processedImage scaleToSize:CGSizeMake(300, 300) contentMode:UIViewContentModeScaleAspectFill interpolationQuality:kCGInterpolationHigh];
                weakSelf.previewView.image = smallImage;
                weakSelf.state = CameraViewStateReadyToUpload;
            }];
        }
            break;
            
        case CameraViewStateReadyToUpload:
        {
            self.state = CameraViewStateUploading;
            [self uploadImage:self.previewView.image progress:^(int percentDone) {
                weakSelf.bottomButton.progress = (float)percentDone / 100;
            } completion:^(BOOL succeeded, NSError *error) {
                weakSelf.state = CameraViewStateDone;
                
                NSString *location = [NSString stringWithFormat:@"%f,%f",weakSelf.photo.locationFull.latitude,weakSelf.photo.locationFull.longitude];
                
                if(weakSelf.photo){
                    [PFCloud callFunctionInBackground:@"notifyUser"
                                       withParameters:@{@"user_full_username":weakSelf.photo.userFull.username,@"user":weakSelf.photo.user,@"url":weakSelf.photo.imageFull.url,@"locationFull":location}
                                                block:^(NSNumber *result, NSError *error) {
                                                    if (!error) {
                                                        NSLog(@"The user was notified sucessfully: %@", result);
                                                        
                                                    }else{
                                                        NSLog(@"error: %@", error);
                                                    }
                                                }];
                }
             

                
            }];
        }
            break;
            
        case CameraViewStateUploading:
            break;
            
        case CameraViewStateDone:
            [self cleanup];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
            
        default:
            break;
    }
}


#pragma mark -

- (void)cleanup
{
    self.filter = nil;
    self.sourcePicture = nil;
    self.stillCamera = nil;
    self.photo = nil;
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

- (void)setPhotoState:(NSString *)state completion:(PFBooleanResultBlock)completion
{
    if (self.photo) {
        self.photo.state = state;
        self.photo.userInUse = [PFUser currentUser];
        [self.photo saveInBackgroundWithBlock:completion];
    }
    else {
        completion(NO, nil);
    }
}

- (void)uploadImage:(UIImage *)image progress:(PFProgressBlock)progress completion:(PFBooleanResultBlock)completion
{
    __weak typeof(self) weakSelf = self;

    if (![PFUser currentUser]) {
        completion(NO, nil);
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData) {
        completion(NO, nil);
    }
    

    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        weakSelf.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    }];
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        PFBooleanResultBlock backgroundTaskCompletion = ^(BOOL succeeded, NSError *error) {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            weakSelf.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
            completion(succeeded, error);
        };

        if (succeeded) {
            CLLocation *location = self.locationManager.location;
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            
            if (weakSelf.photo) {
                weakSelf.photo.locationFull = geoPoint;
                weakSelf.photo.imageFull = photoFile;
                weakSelf.photo.userFull = [PFUser currentUser];
                weakSelf.photo.state = @"full";
                [weakSelf.photo saveInBackgroundWithBlock:backgroundTaskCompletion];
                
            }
            else {
                PFObject *photo = [PFObject objectWithClassName:@"Photo"];
                photo.locationHalf = geoPoint;
                photo.imageHalf = photoFile;
                photo.user = [PFUser currentUser];
                photo.state = @"half";
                [photo saveInBackgroundWithBlock:backgroundTaskCompletion];
            }
            
            
        }
        else {
            backgroundTaskCompletion(NO, error);
        }

    } progressBlock:progress];
}

@end
