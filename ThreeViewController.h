/*
     File: ThreeViewController.h
 Abstract: The view controller for page three.
  Version: 1.1
 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>

@interface ThreeViewController : UIViewController <UITextFieldDelegate>
{ }

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UITextField *badgeField;

- (IBAction)doneAction:(id)sender;

@end
