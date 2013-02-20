//
//  LJViewController.m
//  UniversalHangman
//
//  Created by LIANGJUN JIANG on 11/11/12.
//  Copyright (c) 2012 LJApps. All rights reserved.
//

#import "GameViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <iAd/iAd.h>
#import "GameKitHelper.h"
@interface GameViewController ()<ADBannerViewDelegate, GameKitHelperProtocol>
@property (nonatomic, retain) ADBannerView *bannerView;
@property (nonatomic, retain) UIPopoverController *settingPopover;
@end

@implementation GameViewController
@synthesize player;

@synthesize directionsLabel=_directionsLabel;
@synthesize wordLabel=_wordLabel;
@synthesize guessedLettersLabel=_guessedLettersLabel;
@synthesize remainingGuessesLabel=_remainingGuessesLabel;
@synthesize equivalenceClass=_equivalenceClass;
@synthesize guessesLeft=_guessesLeft;
@synthesize numLetters=_numLetters;
@synthesize guessedLetters=_guessedLetters;
@synthesize isEvil = _isEvil;
@synthesize hintButton = _hintButton;
@synthesize bannerView = _bannerView;
@synthesize settingPopover;
@synthesize gameCenterButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        // Set defaults of preferences
        [defaults registerDefaults:[NSDictionary dictionaryWithContentsOfFile:
                                    [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]]];
    }
    
    return self;
}


// init
//- (void)initDict
//{
//    self.equivalenceClass = [[EquivalenceClass alloc] init];
//}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"PURCHASED"]) {
        self.bannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0)];
        self.bannerView.delegate = self;
    }
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
//    if (![self.slidingViewController.underRightViewController isKindOfClass:[UnderRightViewController class]]) {
//        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"UnderRight"];
//    }
//    
//    [self.view addGestureRecognizer:self.slidingViewController.panGesture];

    
}


- (void)viewDidLoad
{
     self.title = @"Hangman";
    
    UIBarButtonItem *settingsItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(newGame)];
   self.navigationItem.rightBarButtonItem = settingsItem;
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(revealMenu:)];
     self.navigationItem.leftBarButtonItem = menuItem;
    
    
    
    
    [self newGame];
    
    
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)newGame
{
        
    // update the directions
    self.directionsLabel.text = NSLocalizedString(@"Enter a letter to guess the word", @"Enter a letter to guess the word");
    self.directionsLabel.textColor = [UIColor whiteColor];
    self.wordLabel.textColor = [UIColor whiteColor];
    
    // get num of letters in word and num guesses remaining from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.guessesLeft = [[defaults objectForKey:@"numGuesses"] intValue];
    self.numLetters = [[defaults objectForKey:@"numLetters"] intValue];
    self.isEvil = [defaults boolForKey:@"isEvil"];
    
   
    
    self.equivalenceClass = [[EquivalenceClass alloc] init];
    self.equivalenceClass.evil = self.isEvil;
    // reset the possible words
    //    [self.equivalenceClass setEvil:self.isEvil];
    [self.equivalenceClass resetWords:self.numLetters];
    
    // create a new guessed letters
    self.guessedLetters = [[NSMutableArray alloc] initWithCapacity:26];
    
    // make the guessed letters line-breaking and word-wrapping
    self.guessedLettersLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.guessedLettersLabel.numberOfLines = 0;
    
    // got this from iOS_Hangman_Profiling movie
    // set the word with number of letters given in user preferences
    NSMutableString *blanks = [NSMutableString stringWithCapacity:self.numLetters];
    for (int i = 0; i < self.numLetters; i++) {
        [blanks appendString: @"-"];
    }
    self.wordLabel.text = blanks;
    
    [self updateGuessedLettersAndCount];
    
    self.hintButton.hidden = YES;
    self.hintButton.highlighted = NO;
    
    self.gameCenterButton.hidden = YES;
    self.gameCenterButton.enabled = NO;
    [self enableButtons:YES];
    
    // this is actually a word lookup button
    self.hintButton.hidden = YES;
    
}

//Letter button pressed
- (IBAction)buttonPressed:(id)sender {
    UIButton *letterButton = (UIButton *)sender;
    [letterButton setHighlighted:YES]; // no real effect
    [letterButton setEnabled:NO];
    [letterButton setBackgroundImage:[UIImage imageNamed:@"cross"] forState:UIControlStateDisabled];
    NSString *guessedLetter = letterButton.titleLabel.text;
    
    unichar firstLetter = [[guessedLetter capitalizedString] characterAtIndex: 0];
    if ((firstLetter >= 'A') && (firstLetter <= 'Z'))
    {
        // if it's already been guessed
        int found = [self findLetter:guessedLetter];
        if (found == NO)
        {
            // add this letter to the guessed letters list
            [self.guessedLetters addObject:guessedLetter];
            //            NSLog(@"Guessed letters count is: %i", self.guessedLetters.count);
            
            // make a guess to find out what the biggest equivalence class is
            NSString *word;
            
            if (self.isEvil){
                word = [self.equivalenceClass guess:guessedLetter];
            }
            else {
                word = [self.equivalenceClass guess:guessedLetter withGuessed:self.wordLabel.text];
            }
            
            // subtract the number of guesses left if the guess is incorrect
            if (self.equivalenceClass.correctGuess == NO)
            {
                self.guessesLeft = self.guessesLeft - 1;
                //                NSLog(@"MainViewController: INCORRECT guess %@. Number of guesses: %d",guessedLetter, self.guessesLeft);
                
            } else
            {
                //                NSLog(@"MainViewController: CORRECT guess %@. Number of guesses: %d",guessedLetter, self.guessesLeft);
            }
            
            // update the word on the screen
            self.wordLabel.text = word;
            
            // update the UI based on the results
            [self updateGuessedLettersAndCount];
            
            // check if we lost or won the game
            [self checkResult];
        }
        
    }
    else
    {
        UIAlertView *error = [[UIAlertView alloc] initWithTitle: nil
                                                        message: NSLocalizedString(@"INVALIDINPUT", @"Please enter a letter a-z or A-Z")
                                                       delegate: self
                                              cancelButtonTitle: NSLocalizedString(@"OK","Ok")
                                              otherButtonTitles: nil];
        [error show];
    }
    
}


// this is based on code from Section.zip
// example of method returning an int
- (int) findLetter:(NSString *)letterToCheck
{
    
    //    NSLog (@"Input %@", letterToCheck);
    
    int a = NO;
    
    //NSLog(@"Count in guessedLetters %i", self.guessedLetters.count);
    
    for (NSString * item in self.guessedLetters) {
        
        if ([item isEqualToString:letterToCheck]) {
            a = YES;
            //NSLog (@"Checking %@", item);
            break;
        }
    }
    
    return a;
}

// update the display of number of guesses and letters guessed
- (void) updateGuessedLettersAndCount
{
    NSMutableString *guessedString = [[NSMutableString alloc] initWithCapacity:52];
    for (NSString * item in self.guessedLetters) {
        [guessedString appendString:item];
        [guessedString appendString:@" "];
    }
    
    self.guessedLettersLabel.text = [NSString stringWithFormat:@"%@: %@",
                                     NSLocalizedString(@"LETTERS_GUESSED", @"Letters guessed"),
                                     guessedString];
    
    self.remainingGuessesLabel.text = [NSString stringWithFormat:@"%@: %i",
                                       NSLocalizedString(@"GUESSES_LEFT", @"Number of guesses left"),
                                       self.guessesLeft];
    
}

- (void)checkResult
{
    BOOL unguessed = NO;
    // if the word does not contain any dashes, user guessed the word and won
    int len = self.wordLabel.text.length;
    for (int i=0; i<len; i++)
    {
        if ([self.wordLabel.text characterAtIndex:i] == '-')
        {
            unguessed = YES;
            break;
        }
    }
    
    if (unguessed == NO)
    {
        [self win];
    }
    else if (self.guessesLeft == 0)
    {
        // if there are no more guesses left, user lost
        [self lose];
    }
}

// method to perform when the user guesses the word correctly
- (void)win
{
    
    // update the directions
    self.directionsLabel.text = NSLocalizedString(@"WIN", @"You win! Tap GameCenter to submit your score!");
    self.directionsLabel.textColor = [UIColor orangeColor];
    // We also need to disable those buttons
    [self enableButtons:NO];
    
    // show the word meaning
    self.hintButton.hidden = NO;
    self.hintButton.highlighted = YES;
    
    self.gameCenterButton.hidden = NO;
    self.gameCenterButton.enabled = YES;
//    self.gameCenterButton.highlighted = YES;
    
}

// method to perform when the user runs out of guesses
- (void)lose
{
    // update the directions
    self.directionsLabel.text = NSLocalizedString(@"LOSE", @"The correct word is");
    
    // update the word
    if (self.isEvil) {
        self.wordLabel.text = self.equivalenceClass.getTheWord;
    } else
        self.wordLabel.text = self.equivalenceClass.word;
    
    self.wordLabel.textColor = [UIColor redColor];
    // let the user learn the word
    self.hintButton.hidden = NO;
    self.hintButton.highlighted = YES;
    
    [self enableButtons:NO];
    
}

#pragma mark - Delegate methods

- (void)flipsideViewControllerDidFinish:(GameSettingViewController *)controller
{
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.settingPopover dismissPopoverAnimated:YES];
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // We need to refresh the screen
    [self newGame];
}


//- (void)wordLookupViewControllerDidFinish:(WordLookupViewController *)controller
//{
//    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        [self.settingPopover dismissPopoverAnimated:YES];
//    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//    {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    
//}

- (IBAction)showInfo:(id)sender
{
    GameSettingViewController *controller = [[GameSettingViewController alloc] initWithNibName:@"GameSettingViewController" bundle:nil];
    controller.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.settingPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        //        self.settingPopover.popoverContentSize=CGSizeMake(320.0, 460.0);
        [self.settingPopover presentPopoverFromBarButtonItem:sender  permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:navController animated:YES completion:nil];
        
    }
    
}


- (IBAction)showHint:(id)sender
{
    UIReferenceLibraryViewController* wlvc = [[UIReferenceLibraryViewController alloc] initWithTerm: self.wordLabel.text];
//    [self presentModalViewController:dictionaryView animated:YES];
//    
//    WordLookupViewController *wlvc = [[WordLookupViewController alloc] initWithWord:self.wordLabel.text];
//    wlvc.delegate = self;
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.settingPopover = [[UIPopoverController alloc] initWithContentViewController:wlvc];
        [self.settingPopover presentPopoverFromRect:self.hintButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        
        //        self.settingPopover.popoverContentSize=CGSizeMake(320.0, 460.0);
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        wlvc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:wlvc animated:YES completion:nil];
       
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    //    NSLog(@"MainViewController viewDidUnload");
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma private method
- (void)enableButtons:(BOOL)enabled
{
    for (int i = 50; i<= 75; i++){
        UIButton *letterButton = (UIButton *)[self.view viewWithTag:i];
        if (letterButton.enabled!=enabled) {
            letterButton.enabled = enabled;
        }
        
        if (enabled) {
            [letterButton setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
    
}

#pragma mark - Leaderboard method
- (IBAction)showLeaderboardButtonAction:(id)event 
{
//    NSString * leaderboardCategory = @"com.appledts.GameCenterSampleApps.leaderboard.seconds";
    NSString * leaderboardCategory = @"com.ljsportapps.hangman.scoreboard";
    
    // The intent here is to show the leaderboard and then submit a score. If we try to submit the score first there is no guarentee
    // the server will have recieved the score when retreiving the current list
    [self showLeaderboard:leaderboardCategory];
    [self insertCurrentTimeIntoLeaderboard:leaderboardCategory];
}

#pragma mark -
#pragma mark Example of a score to be inserted

// Using time as as an int of seconds from 1970 gives us a good rolling number to test against
- (void)insertCurrentTimeIntoLeaderboard:(NSString*)leaderboard
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float score = [[defaults objectForKey:@"numLetters"] floatValue] / [[defaults objectForKey:@"numGuesses"] floatValue] ;
    int64_t finalScore =  (int64_t)(self.isEvil)?10000*score:100*score;
//    NSLog(@"waht's the score to be sent: %lld",finalScore);
    GKScore * submitScore = [[GKScore alloc] initWithCategory:leaderboard];
    [submitScore setValue:finalScore];
    
    // New feature in iOS5 tells GameCenter which leaderboard is the default per user.
    // This can be used to show a user's favorite course/track associated leaderboard, or just show the latest score submitted.
    [submitScore setShouldSetDefaultLeaderboard:YES];
    
    // New feature in iOS5 allows you to set the context to which the score was sent. For instance this will set the context to be
    //the count of the button press per run time. Information stored in context isn't accessable in standard GKLeaderboardViewController,
    //instead it's accessable from GKLeaderboard's loadScoresWithCompletionHandler:
    [submitScore setContext:context++];
    
    [self.player submitScore:submitScore];
   
}

// Example of how to bring up a specific leaderboard
- (void)showLeaderboard:(NSString *)leaderboard
{
    GKLeaderboardViewController * leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    [leaderboardViewController setCategory:leaderboard];
    [leaderboardViewController setLeaderboardDelegate:self];
    
    if  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        leaderboardViewController.modalPresentationStyle = UIModalPresentationFormSheet;

    }
    [self presentViewController:leaderboardViewController animated:YES completion:nil];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

// Disable GameCenter options from view
- (void)enableGameCenter:(BOOL)enableGameCenter
{
//    [showLeaderboardButton setEnabled:enableGameCenter];
}

#pragma mark banner ad
// banner view delegate methods

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //    [self layoutAnimated:YES];
    [self.view addSubview:self.bannerView];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //    [self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}


@end
