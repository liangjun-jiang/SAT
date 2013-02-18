/*
     File: MyTableViewController.h
 Abstract: The main view controller of this app.
  Version: 1.3
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>

@interface TestTableViewController : UITableViewController
{
	UIView *myHeaderView;
//	UIView *myFooterView;
    UILabel *meaningLabel;
	
	NSMutableArray *tableArray;
    
    NSDictionary *problem;
}

@property (nonatomic, strong) IBOutlet UIView *myHeaderView;
@property (nonatomic, strong) IBOutlet UILabel *meaningLabel;

//@property (nonatomic, strong) IBOutlet UIView *myFooterView;
@property (nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) NSDictionary *problem;
@property (nonatomic, strong) NSDictionary *guessedWord;

- (IBAction)button1Action:(id)sender;
- (IBAction)button2Action:(id)sender;

//- (id)initWithPageNumber:(int)page andTotal:(int)total;
- (id)initWithProblem:(NSDictionary *)theProblem;

@end
