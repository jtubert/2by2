//
//  MainViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import "FeedViewController.h"
#import "EditProfileViewController.h"
#import "NotificationsViewController.h"
#import "CameraViewController.h"
#import "UIImage+Addon.h"
#import "UICollectionView+Addon.h"
#import "UICollectionView+Pagination.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "PopularContainerCell.h"
#import "PublicContainerCell.h"


@interface MainViewController ()
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@end


@implementation MainViewController

+ (instancetype)currentController
{
    id controller = [AppDelegate delegate].window.rootViewController;
    if ([controller isKindOfClass:self]) {
        return controller;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:NoficationDidUpdatePushNotificationCount object:nil];

    [self.collectionView registerCellClass:[PopularContainerCell class]];
    [self.collectionView registerCellClass:[PublicContainerCell class]];
    
    self.pageControl.numberOfPages = ContentTypeCount;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ContentTypeCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContentType type = indexPath.row;
    switch (type) {
            
        case ContentTypePopular:
        {
            PopularContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PopularContainerCell class]) forIndexPath:indexPath];
            [cell performQuery];
            return cell;
        }

        case ContentTypePublic:
        case ContentTypeFriends:
        case ContentTypeProfile:
        case ContentTypeNotifications:
        default:
        {
            PublicContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PublicContainerCell class]) forIndexPath:indexPath];
            [cell performQuery];
            return cell;
        }
    }
}


#pragma mark - IBAction

- (IBAction)cameraButtonTapped:(id)sender
{
    CameraViewController *controller = [CameraViewController controller];
    [self presentViewController:controller animated:YES completion:nil];
}


#pragma mark - Notification

- (void)updateNotificationCount:(NSNotification *)notification
{
    NSNumber *count = notification.userInfo[NoficationUserInfoKeyCount];
    if (count.integerValue) {
        UIImage *image = [UIImage circleWithNumber:count.integerValue radius:30];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(notificationButtonTapped:)];
        [self.navigationItem setRightBarButtonItem:item animated:YES];
    }
    else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)notificationButtonTapped:(id)sender
{
    [self showNotificationsAnimated:YES];
}

- (void)showNotificationsAnimated:(BOOL)animated
{
    [self.collectionView scrollToPage:ContentTypeNotifications];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = self.collectionView.currentPage;
}

@end