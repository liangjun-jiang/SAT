//
//  AppDelegate.h
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <GameKit/GameKit.h>
#import "ECSlidingViewController.h"

// Preferred method for testing for Game Center
//static BOOL isGameCenterAPIAvailable();

@interface AppDelegate : UIResponder <UIApplicationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

// currentPlayerID is the value of the playerID last time we authenticated.
//@property (retain,readwrite) NSString * currentPlayerID;
//
//// isGameCenterAuthenticationComplete is set after authentication, and authenticateWithCompletionHandler's completionHandler block has been run. It is unset when the application is backgrounded.
//@property (readwrite, getter=isGameCenterAuthenticationComplete) BOOL gameCenterAuthenticationComplete;
+ (AppDelegate *)appDelegate;
- (void)displayLogin;
- (void)logOutButtonTapAction:(id)sender;

@end
