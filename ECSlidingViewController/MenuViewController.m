//
//  MenuViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "MenuViewController.h"
#import "TwoViewController.h"
#import "BHCollectionViewController.h"
#import "GameViewController.h"

typedef enum{
	learing = 0,
	autoplay,
	test,
	game
} SectionsTag;

@interface MenuViewController()
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) NSArray *settingsItems;
@end

@implementation MenuViewController
@synthesize menuItems;

- (void)awakeFromNib
{
  self.menuItems = @[@"Learning Mode", @"Autoplay Mode", @"Test Mode",  @"Game Mode"];
    self.settingsItems = @[@"Login"];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self.slidingViewController setAnchorRightRevealAmount:280.0f];
  self.slidingViewController.underLeftWidthLayout = ECFullWidth;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (section == 0)? @"Tasks":@"Settings";
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return  (sectionIndex == 0)? self.menuItems.count: self.settingsItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"MenuItemCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
  }
    if (indexPath.section == 0) {
         cell.textLabel.text = (self.menuItems)[indexPath.row];
    } else
        cell.textLabel.text = @"Logout";
 
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    UIViewController *newTopViewController = nil;
    
    UINavigationController *navController = nil;
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case learing:
            {
                identifier = @"NavigationTop";
                break;
            }
            case autoplay:
            {
                BHCollectionViewController *collectionViewController = [[BHCollectionViewController alloc] initWithNibName:@"BHCollectionViewController" bundle:nil];
                navController = [[UINavigationController alloc] initWithRootViewController:collectionViewController];
                break;
            }
            case test:
            {
                TwoViewController *groupedViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Grouped"];
                navController = [[UINavigationController alloc] initWithRootViewController:groupedViewController];
                break;
            }
            case game:
            {
                GameViewController *gameViewController = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
                navController = [[UINavigationController alloc] initWithRootViewController:gameViewController];
                break;
            }
            default:
                break;
        }
        
        
    }
    
    if (identifier != nil) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"iPhone" bundle:nil];
        newTopViewController = [storyBoard instantiateViewControllerWithIdentifier:@"NavigationTop"];
    } else if (navController != nil) {
        newTopViewController = navController;
    }
  
  [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
    CGRect frame = self.slidingViewController.topViewController.view.frame;
    self.slidingViewController.topViewController = newTopViewController;
    self.slidingViewController.topViewController.view.frame = frame;
    [self.slidingViewController resetTopView];
  }];
}

@end
