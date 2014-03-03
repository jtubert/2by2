//
//  MainViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const NoficationDidUpdatePushNotificationCount;
extern NSString * const NoficationUserInfoKeyCount;

typedef NS_ENUM(NSUInteger, FeedType) {
    FeedTypeSingle = 0,
    FeedTypeGlobal,
    FeedTypeFollowing,
    FeedTypeYou,
    FeedTypeNotifications,
    FeedTypeFriend,
};


@interface MainViewController : UIViewController
- (void)showControllerWithType:(FeedType)type;
@end
