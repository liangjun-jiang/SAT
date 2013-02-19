/*
     File: TwoViewController.h
 Abstract: The view controller for page two.
  Version: 1.1
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"
#import "MenuViewController.h"

@interface TwoViewController : UITableViewController
{ }

- (IBAction)revealMenu:(id)sender;
@end