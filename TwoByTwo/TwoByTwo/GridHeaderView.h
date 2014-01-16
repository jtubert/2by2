//
//  GridHeaderView.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridViewController.h"


@interface GridHeaderView : UICollectionReusableView

@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) GridViewController *controller;

@end
