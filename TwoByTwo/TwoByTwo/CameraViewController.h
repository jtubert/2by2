//
//  CameraViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"


@interface CameraViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic, weak) Photo *photo;
@property (nonatomic, weak) PFObject *object;
@property (nonatomic, strong) CLLocationManager *locationManager;

+ (instancetype)controller;

@end
