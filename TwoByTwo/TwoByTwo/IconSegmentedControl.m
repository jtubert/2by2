//
//  IconSegmentedControl.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "IconSegmentedControl.h"


@implementation IconSegmentedControl

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundImage:[UIImage new] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self setBackgroundImage:[UIImage new] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self setDividerImage:[UIImage new] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self addTarget:self action:@selector(updateImages) forControlEvents:UIControlEventValueChanged];
    [self updateImages];
}

- (void)updateImages
{
    for (NSUInteger i = 0; i < self.numberOfSegments; i++) {
        UIImage *image = [self imageForSegmentAtIndex:i];
        image = (i == self.selectedSegmentIndex) ? [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:image forSegmentAtIndex:i];
    }
}

@end