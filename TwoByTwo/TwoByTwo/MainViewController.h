//
//  MainViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainViewController : UIViewController

+ (instancetype)currentController;
- (void)showNotificationsAnimated:(BOOL)animated;

@end
