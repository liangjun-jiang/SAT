/*
     File: AppDelegate.m 
 Abstract: The application delegate class used for installing our navigation controller. 
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "AppDelegate.h"
#import "FeaturedViewController.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"

#define kCustomizeTabBar        0   // compile time option to turn on or off custom tab bar appearance

NSString *kWhichTabPrefKey		= @"kWhichTab";
NSString *kTabBarOrderPrefKey	= @"kTabBarOrder";

#define kDefaultTabSelection    0	// default tab value is 0 (tab #1)


@implementation AppDelegate

@synthesize window, myTabBarController;

- (void)displayLogin
{
    if (![PFUser currentUser]) { // No user logged in
        // Customize the Log In View Controller
        MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
        [logInViewController setFields:PFLogInFieldsUsernameAndPassword | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsDismissButton];
        
        // Customize the Sign Up View Controller
        MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
        [signUpViewController setDelegate:self];
        [signUpViewController setFields:PFSignUpFieldsDefault | PFSignUpFieldsAdditional];
        [logInViewController setSignUpController:signUpViewController];
        
        
        // Present the log in view controller
        [self.myTabBarController presentViewController:logInViewController animated:NO completion:nil];
        
        //        [self presentViewController:logInViewController animated:YES completion:NULL];
    } else
        NSLog(@"user logged in");
    
    
}


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    
    // ****************************************************************************
    // Fill in with your Parse, Facebook and Twitter credentials:
    // ****************************************************************************
    
    [Parse setApplicationId:@"6ZU4jWcEKDQsD95sSUJnG2hKNCuegf3pYtgELKz6" clientKey:@"6ByQlofzH2naCSXCsFGnEYTCEEhiCBtCnNJAJo1i"];
//    [PFFacebookUtils initializeWithApplicationId:@"your_facebook_app_id"];
//    [PFTwitterUtils initializeWithConsumerKey:@"your_twitter_consumer_key" consumerSecret:@"your_twitter_consumer_secret"];
    
    
    // Set defualt ACLs
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // add the tab bar controller's current view as a subview of the window
	[window addSubview:myTabBarController.view];
  	[window makeKeyAndVisible];
    
  	// test for "kWhichTabPrefKey" key value
    NSUInteger testValue = [[NSUserDefaults standardUserDefaults] integerForKey:kWhichTabPrefKey];
	if (testValue == 0)
	{
		// no default source value has been set, create it here
		//
		
		// since no default values have been set (i.e. no preferences file created), create it here
		NSDictionary *appDefaults = @{kWhichTabPrefKey: @kDefaultTabSelection};
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
	}
	
	// customize the More page's navigation bar color
	self.myTabBarController.moreNavigationController.navigationBar.tintColor = [UIColor grayColor];
	
#if kCustomizeTabBar
    // use the custom appearance feature found in iOS 5.0 or later by customizing the
    // appearance of our UITabBar.
    //
    // note:
    // first check if these classes respond to these selectors (call them only for iOS 5.0 or later)
    //
    if ([myTabBarController.tabBar respondsToSelector:@selector(setTintColor:)])
        self.myTabBarController.tabBar.tintColor = [UIColor darkGrayColor];
    if ([myTabBarController.tabBar respondsToSelector:@selector(setSelectedImageTintColor:)])
        self.myTabBarController.tabBar.selectedImageTintColor = [UIColor yellowColor];
    
    // note:
    // 1) you can also apply additional custom appearance to UITabBar using:
    // "backgroundImage" and "selectionIndicatorImage"
    // 2) you can also customize the appearance of individual UITabBarItems as well.
#endif
    
	// restore the tab-order from prefs
	NSArray* classNames = [[NSUserDefaults standardUserDefaults] arrayForKey:kTabBarOrderPrefKey];
	if (classNames.count > 0)
	{
		NSMutableArray* controllers = [[NSMutableArray alloc] init];
		for (NSString* className in classNames)
		{
			for (UIViewController* controller in self.myTabBarController.viewControllers)
			{
				NSString* controllerClassName = nil;
				
				if ([controller isKindOfClass:[UINavigationController class]])
				{
					controllerClassName = NSStringFromClass([[(UINavigationController*)controller topViewController] class]);
				}
				else
				{
					controllerClassName = NSStringFromClass([controller class]);
				}
				
				if ([className isEqualToString:controllerClassName])
				{
					[controllers addObject:controller];
					break;
				}
			}
		}
		
		if (controllers.count == self.myTabBarController.viewControllers.count)
		{
			self.myTabBarController.viewControllers = controllers;
		}
		
	}
	
	// re-store previously selected tab from prefs
	//
	// if the More navigation controller was last selected, you must change the value of the "selectedViewController" property instead.
	if ([[NSUserDefaults standardUserDefaults] integerForKey:kWhichTabPrefKey] == NSNotFound)
	{
		self.myTabBarController.selectedViewController = self.myTabBarController.moreNavigationController;
	}
	else
	{
		self.myTabBarController.selectedIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kWhichTabPrefKey];
	}
	
	// listen for changes in view controller from the More screen
	self.myTabBarController.moreNavigationController.delegate = self;
    
    // choose to make one of our view controllers ("FeaturedViewController"),
    // not movable/reorderable in More's edit screen
    //
    NSMutableArray *customizeableViewControllers = (NSMutableArray *)self.myTabBarController.viewControllers;
    for (UIViewController *viewController in customizeableViewControllers)
    {
        if ([viewController isKindOfClass:[FeaturedViewController class]])
        {
            [customizeableViewControllers removeObject:viewController];
            break;
        }
    }
    self.myTabBarController.customizableViewControllers = customizeableViewControllers;
    
    [self displayLogin];
    
}

- (void)saveTabOrder
{
	// store the tab-order to preferences
	//
	NSMutableArray* classNames = [[NSMutableArray alloc] init];
	for (UIViewController* controller in self.myTabBarController.viewControllers)
	{
		if ([controller isKindOfClass:[UINavigationController class]])
		{
			UINavigationController *navController = (UINavigationController *)controller;
			
			[classNames addObject:NSStringFromClass([navController.topViewController class])];
		}
		else
		{
			[classNames addObject:NSStringFromClass([controller class])];
		}
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:classNames forKey:kTabBarOrderPrefKey];
	
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // In iOS 4 and above, this will store off tab ordering.
    [self saveTabOrder];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// This will store off tab ordering in all iOS versions.
	[self saveTabOrder];
}



#pragma mark -
#pragma mark UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	// store the selected tab for next time:
	//		normally we can do this at "applicationDidTerminate", but this is a convenient spot
	// note: if the user has the "More" tab selected, then the value stored is "NSNotFound"
	//
	[[NSUserDefaults standardUserDefaults] setInteger:[tabBarController selectedIndex] forKey:kWhichTabPrefKey];
}


#pragma mark -
#pragma mark UINavigationControllerDelegate (More screen)

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController == (self.myTabBarController.moreNavigationController.viewControllers)[0])
	{
		// returned to the More page
	}
}

// Facebook oauth callback
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}



#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length && password.length) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self.myTabBarController dismissViewControllerAnimated:NO completion:nil];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.myTabBarController dismissViewControllerAnimated:YES completion:nil];
    
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || !field.length) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self.myTabBarController dismissViewControllerAnimated:YES completion:nil];
//    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}



// this one shouldn't be here
- (void)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
    [self.myTabBarController dismissViewControllerAnimated:NO completion:nil];
    [self displayLogin];
}

@end

