/*
     File: AppDelegate.h
 Abstract: The application delegate class used for installing our navigation controller.
  Version: 1.1
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UINavigationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{
    UIWindow *window;
    UITabBarController *myTabBarController;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *myTabBarController;

- (void)displayLogin;
- (void)logOutButtonTapAction:(id)sender;


@end
