//
//  AppDelegate.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "AppDelegate.h"
#import "FeaturedViewController.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"

@implementation AppDelegate

@synthesize window = _window;
//@synthesize currentPlayerID, gameCenterAuthenticationComplete;
//
//// Check for the availability of Game Center API.
//static BOOL isGameCenterAPIAvailable()
//{
//    // Check for presence of GKLocalPlayer API.
//    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
//    
//    // The device must be running running iOS 4.1 or later.
//    NSString *reqSysVer = @"4.1";
//    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
//    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
//    
//    return (gcClass && osVersionSupported);
//}

+ (AppDelegate *)appDelegate{		// Static accessor
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
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
    
    [self displayLogin];
    
    // this is important. we will use this again & again
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Set defaults of preferences
    if ([defaults objectForKey:@"tested"] == nil || [defaults objectForKey:@"grouped"]) {
        NSLog(@"always inited?!");
//        NSMutableDictionary *indexed = [NSMutableDictionary dictionaryWithCapacity:26];
        NSMutableDictionary *grouped = [NSMutableDictionary dictionaryWithCapacity:26];
        NSMutableDictionary *tested = [NSMutableDictionary dictionaryWithCapacity:26];
        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:indexed];
//        [defaults setObject:data forKey:@"indexed"];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:grouped];
        [defaults setObject:data forKey:@"grouped"];
        
        data = [NSKeyedArchiver archivedDataWithRootObject:tested];
        [defaults setObject:data forKey:@"tested"];
    }
    
    
    
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

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
        self.window.rootViewController = logInViewController;
        [self.window makeKeyAndVisible];
        
    } else
        NSLog(@"user logged in");
    
    
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
//    [self.myTabBarController dismissViewControllerAnimated:NO completion:nil];
    self.window.rootViewController = [self rootViewController];
    [self.window makeKeyAndVisible];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
//    [self.myTabBarController dismissViewControllerAnimated:YES completion:nil];
    self.window.rootViewController = [self rootViewController];
    [self.window makeKeyAndVisible];
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
//    [self.myTabBarController dismissViewControllerAnimated:YES completion:nil];
    //    [self dismissViewControllerAnimated:YES completion:NULL];
    self.window.rootViewController = [self rootViewController];
    [self.window makeKeyAndVisible];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
    self.window.rootViewController = [self rootViewController];
}



// this one shouldn't be here
- (void)logOutButtonTapAction:(id)sender {
    [PFUser logOut];
//    [self.myTabBarController dismissViewControllerAnimated:NO completion:nil];
    [self displayLogin];
}

#pragma mark - rootviewController
-(UIViewController *)rootViewController {
    UIStoryboard *storyboard;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        storyboard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        storyboard = [UIStoryboard storyboardWithName:@"iPad" bundle:nil];
    }
    
    return [storyboard instantiateInitialViewController];
    
    //   return [storyboard instantiateViewControllerWithIdentifier:@"FirstTop"];
}

@end
