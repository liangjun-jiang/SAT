//
//  UnderRightViewController.m
//  ECSlidingViewController
//
//  Created by Michael Enriquez on 1/23/12.
//  Copyright (c) 2012 EdgeCase. All rights reserved.
//

#import "UnderRightViewController.h"

@interface UnderRightViewController()
@property (nonatomic, assign) CGFloat peekLeftAmount;
@property (nonatomic, strong) NSMutableDictionary *tested;
@property (nonatomic, strong) NSMutableDictionary *grouped;

@end

@implementation UnderRightViewController
@synthesize peekLeftAmount;
@synthesize tested, grouped;

- (void)viewDidLoad
{
  [super viewDidLoad];
    
    self.title = @"Study Progress";
  self.peekLeftAmount = 40.0f;
  [self.slidingViewController setAnchorLeftPeekAmount:self.peekLeftAmount];
  self.slidingViewController.underRightWidthLayout = ECVariableRevealWidth;
    
//    self.title = @"Summary";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"tested"];
    tested = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    data = [defaults objectForKey:@"grouped"];
    grouped = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController anchorTopViewOffScreenTo:ECLeft animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = 0.0f;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    self.view.frame = frame;
  } onComplete:nil];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [self.slidingViewController anchorTopViewTo:ECLeft animations:^{
    CGRect frame = self.view.frame;
    frame.origin.x = self.peekLeftAmount;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.height - self.peekLeftAmount;
    } else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
      frame.size.width = [UIScreen mainScreen].bounds.size.width - self.peekLeftAmount;
    }
    self.view.frame = frame;
  } onComplete:nil];
}

#pragma mark - tableview DataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title  = @"";
    switch (section) {
        case 0:
            title = @"Indexed Progress:";
            break;
        case 1:
            title = @"Grouped Progress:";
            break;
        case 2:
            title = @"Test Progress:";
            break;
        default:
            break;
    }
    
    return title;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSUInteger count = 0;
    switch (sectionIndex) {
        case 0:
            return 1;
            break;
        case 1:
            count = [[grouped allKeys] count];
            break;
        case 2:
            count = [[tested allKeys] count];
            break;
        default:
            break;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"myCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    NSString *title = @"";
    NSString *completed = @"has been completed!";
    NSString *key;
    NSUInteger location;
    switch (indexPath.section) {
        case 0:
            title = @"TBD";
            break;
        case 1:
        {
            key = [[grouped allKeys] objectAtIndex:indexPath.row];
            location = [grouped[key] integerValue];
            title = [NSString stringWithFormat:@" %d of %d for %@ %@", location, 1000,  key, completed];
            
            break;
        }
            
            case 2:
        {
            key = [[tested allKeys] objectAtIndex:indexPath.row];
            location = [tested[key] integerValue];
            title = [NSString stringWithFormat:@" %d of %d for %@ %@", location, 1000,  key, completed];
            
            
            break;
        }
        default:
            break;
    }
    cell.textLabel.text = title;
    
    return cell;
}

@end
