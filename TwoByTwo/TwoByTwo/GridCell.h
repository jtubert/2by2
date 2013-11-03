//
//  GridCell.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/2/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GridCell : UICollectionViewCell

@property (nonatomic, weak) PFObject *object;

- (void)updateContent;

@end