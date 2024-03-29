//
//  PFObject+User.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/12/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "PFObject+User.h"

NSString * const PFFullNameKey = @"fullName";
NSString * const PFFacebookIDKey = @"facebookId";
NSString * const PFTwitterProfileImageKey = @"TwitterProfileImage";
NSString * const PFNotificationWasAccessedKey = @"notificationWasAccessed";

NSString * const PFCommentsEmailAlertKey = @"commentsEmailAlert";
NSString * const PFDigestEmailAlertKey = @"digestEmailAlert";
NSString * const PFFollowsEmailAlertKey = @"followsEmailAlert";
NSString * const PFFriendTookPhotoEmailAlertKey = @"friendTookPhotoEmailAlert";
NSString * const PFLikesEmailAlertKey = @"likesEmailAlert";
NSString * const PFOverexposeEmailAlertKey = @"overexposeEmailAlert";

NSString * const PFCommentsPushAlertKey = @"commentsPushAlert";
NSString * const PFFollowsPushAlertKey = @"followsPushAlert";
NSString * const PFFriendTookPhotoPushAlertKey = @"friendTookPhotoPushAlert";
NSString * const PFLikesPushAlertKey = @"likesPushAlert";
NSString * const PFOverexposePushAlertKey = @"overexposePushAlert";


@implementation PFObject (User)

- (NSString *)fullName
{
    return self[PFFullNameKey];
}

- (void)setFullName:(NSString *)fullName
{
    self[PFFullNameKey] = fullName;
}

- (NSString *)facebookID
{
    return self[PFFacebookIDKey];
}

- (void)setFacebookID:(NSString *)facebookID
{
    self[PFFacebookIDKey] = facebookID;
}

- (NSString *)twitterProfileImageURL
{
    return self[PFTwitterProfileImageKey];
}

- (void)setTwitterProfileImageURL:(NSString *)twitterProfileImageURL
{
    self[PFTwitterProfileImageKey] = twitterProfileImageURL;
}

- (NSDate *)notificationWasAccessed
{
    return self[PFNotificationWasAccessedKey];
}

- (void)setNotificationWasAccessed:(NSDate *)notificationWasAccessed
{
    self[PFNotificationWasAccessedKey] = notificationWasAccessed;
}

#pragma mark -

- (BOOL)commentsEmailAlert
{
    return [self[PFCommentsEmailAlertKey] boolValue];
}

- (void)setCommentsEmailAlert:(BOOL)commentsEmailAlert
{
    self[PFCommentsEmailAlertKey] = @(commentsEmailAlert);
}

- (BOOL)digestEmailAlert
{
    return [self[PFDigestEmailAlertKey] boolValue];
}

- (void)setDigestEmailAlert:(BOOL)digestEmailAlert
{
    self[PFDigestEmailAlertKey] = @(digestEmailAlert);
}

- (BOOL)followsEmailAlert
{
    return [self[PFFollowsEmailAlertKey] boolValue];
}

- (void)setFollowsEmailAlert:(BOOL)followsEmailAlert
{
    self[PFFollowsEmailAlertKey] = @(followsEmailAlert);
}

- (BOOL)friendTookPhotoEmailAlert
{
    return [self[PFFriendTookPhotoEmailAlertKey] boolValue];
}

- (void)setFriendTookPhotoEmailAlert:(BOOL)friendTookPhotoEmailAlert
{
    self[PFFriendTookPhotoEmailAlertKey] = @(friendTookPhotoEmailAlert);
}

- (BOOL)likesEmailAlert
{
    return [self[PFLikesEmailAlertKey] boolValue];
}

- (void)setLikesEmailAlert:(BOOL)likesEmailAlert
{
    self[PFLikesEmailAlertKey] = @(likesEmailAlert);
}

- (BOOL)overexposeEmailAlert
{
    return [self[PFOverexposeEmailAlertKey] boolValue];
}

- (void)setOverexposeEmailAlert:(BOOL)overexposeEmailAlert
{
    self[PFOverexposeEmailAlertKey] = @(overexposeEmailAlert);
}

#pragma mark -

- (BOOL)commentsPushAlert
{
    return [self[PFCommentsPushAlertKey] boolValue];
}

- (void)setCommentsPushAlert:(BOOL)commentsPushAlert
{
    self[PFCommentsPushAlertKey] = @(commentsPushAlert);
}

- (BOOL)followsPushAlert
{
    return [self[PFFollowsPushAlertKey] boolValue];
}

- (void)setFollowsPushAlert:(BOOL)followsPushAlert
{
    self[PFFollowsPushAlertKey] = @(followsPushAlert);
}

- (BOOL)friendTookPhotoPushAlert
{
    return [self[PFFriendTookPhotoPushAlertKey] boolValue];
}

- (void)setFriendTookPhotoPushAlert:(BOOL)friendTookPhotoPushAlert
{
    self[PFFriendTookPhotoPushAlertKey] = @(friendTookPhotoPushAlert);
}

- (BOOL)likesPushAlert
{
    return [self[PFLikesPushAlertKey] boolValue];
}

- (void)setLikesPushAlert:(BOOL)likesPushAlert
{
    self[PFLikesPushAlertKey] = @(likesPushAlert);
}

- (BOOL)overexposePushAlert
{
    return [self[PFOverexposePushAlertKey] boolValue];
}

- (void)setOverexposePushAlert:(BOOL)overexposePushAlert
{
    self[PFOverexposePushAlertKey] = @(overexposePushAlert);
}

@end
