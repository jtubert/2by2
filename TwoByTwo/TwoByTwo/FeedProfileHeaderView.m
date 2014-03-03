//
//  FeedHeaderView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FeedProfileHeaderView.h"
#import "EditProfileViewController.h"
#import "EverythingElseViewController.h"
#import "UIImageView+AFNetworking.h"


@interface FeedProfileHeaderView ()
//@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIButton *followButton;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *moreButton;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *numPhotosLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UILabel *bioLabel;
//@property (nonatomic, weak) IBOutlet UIView *controlView;
//@property (nonatomic, weak) IBOutlet UIButton *feedToggleButton;
//@property (nonatomic, weak) IBOutlet UILabel *exposureLabel;
//@property (nonatomic, weak) IBOutlet UIButton *exposureToggleButton;
@end


@implementation FeedProfileHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.imageView.layer.cornerRadius = 40.0;
    self.usernameLabel.text = @"Loading..";
    self.numPhotosLabel.text = @"Loading..";
    self.followingLabel.text = @"Loading..";
    self.followersLabel.text = @"Loading..";
    self.bioLabel.text = @"Loading..";
    
    self.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.followButton.titleLabel.font = [UIFont appMediumFontOfSize:12];
    self.editButton.titleLabel.font = [UIFont appMediumFontOfSize:14];
    self.usernameLabel.font = [UIFont appFontOfSize:14];
    self.numPhotosLabel.font = [UIFont appFontOfSize:14];
    self.followingLabel.font = [UIFont appFontOfSize:14];
    self.followersLabel.font = [UIFont appFontOfSize:14];
    self.bioLabel.font = [UIFont appFontOfSize:14];
    self.exposureLabel.font = [UIFont appMediumFontOfSize:12];
}


#pragma mark - Content

- (void)setUser:(PFUser *)user
{
    _user = user;

    if (user) {
        [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
            [self updateContent];
        }];
    }
    else {
        [self updateContent];
    }
}

- (void)updateContent
{
    PFUser *user = self.user;
    
    if([user.objectId isEqualToString:[PFUser currentUser].objectId]){
        user = nil;
    }
    
    if (user) {
//        self.followButton.hidden = NO; // Keep followButton hidden until the state is loaded.
        self.editButton.hidden = YES;
        self.moreButton.hidden = YES;
    }
    else {
        user = [PFUser currentUser];
        self.followButton.hidden = YES;
        self.editButton.hidden = NO;
        self.moreButton.hidden = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    
    self.titleLabel.text = [user[@"fullName"] uppercaseString];
    self.usernameLabel.text = user.username;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", user, user];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        weakSelf.numPhotosLabel.text = [NSString stringWithFormat:@"%d Photos", number];
    }];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Followers"];
    [followingQuery whereKey:@"userID" equalTo:user.objectId];
    [followingQuery selectKeys:@[@"followingUserID"]];
    [followingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        weakSelf.followingLabel.text = [NSString stringWithFormat:@"%d Following", number];
    }];
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Followers"];
    [followerQuery whereKey:@"followingUserID" equalTo:user.objectId];
    [followerQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        weakSelf.followersLabel.text = [NSString stringWithFormat:@"%d Followers", number];
    }];
    
    self.bioLabel.text = user[@"bio"];
    
    
    PFQuery *followedByMeQuery = [PFQuery queryWithClassName:@"Followers"];
    [followedByMeQuery whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
    [followedByMeQuery whereKey:@"followingUserID" equalTo:user.objectId];
    [followedByMeQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        weakSelf.followButton.hidden = NO;
        if (number > 0){
            [weakSelf.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
        }
        else {
            [weakSelf.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        }
    }];

    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", user[@"facebookId"]]];
    [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
}


#pragma mark - IBActions

- (IBAction)followButtonTapped:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    self.followButton.enabled = NO;
    [PFCloud callFunctionInBackground:@"follow"
                       withParameters:@{@"userID":[PFUser currentUser].objectId,@"username":[PFUser currentUser].username,@"followingUserID":self.user.objectId}
                                block:^(NSNumber *result, NSError *error) {
                                    weakSelf.followButton.enabled = YES;
                                    if (!error) {
                                        weakSelf.followButton.hidden = NO;
                                        if ([result isEqual:@0]){
                                            [weakSelf.followButton setTitle:@"Follow" forState:UIControlStateNormal];
                                        }
                                        else {
                                            // In this case, result == @"Notifications sent"
                                            [weakSelf.followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                                        }
                                    }
                                }];
}

- (IBAction)editButtonTapped:(UIButton *)sender
{
    EditProfileViewController *controller = [EditProfileViewController controller];
    UINavigationController *navController = (id)[AppDelegate delegate].window.rootViewController;
    NSAssert([navController isKindOfClass:[UINavigationController class]], @"rootViewController should be an UINavigationController!");
    [navController pushViewController:controller animated:YES];
}

- (IBAction)moreButtonTapped:(UIButton *)sender
{
    EverythingElseViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EverythingElseViewController"];
    UINavigationController *navController = (id)[AppDelegate delegate].window.rootViewController;
    NSAssert([navController isKindOfClass:[UINavigationController class]], @"rootViewController should be an UINavigationController!");
    [navController pushViewController:controller animated:YES];
}


#pragma mark - IBActions

+ (CGFloat)headerHeightForType:(FeedType)type
{
    return 225.0;
}

@end
