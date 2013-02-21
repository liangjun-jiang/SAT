/*
     File: MyTableViewController.h
 Abstract: The main view controller of this app.
  Version: 1.3
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>


@protocol TestTableViewDelegate;
@interface TestTableViewController : UITableViewController
{
	UIView *myHeaderView;
//	UIView *myFooterView;
    UILabel *meaningLabel;
	
    UILabel *countLabel;
	NSMutableArray *tableArray;
    
    NSDictionary *problem;
    

}

@property (nonatomic, strong) IBOutlet UIView *myHeaderView;
@property (nonatomic, strong) IBOutlet UILabel *meaningLabel;
@property (nonatomic, strong) IBOutlet UILabel *countLabel;


//@property (nonatomic, strong) IBOutlet UIView *myFooterView;
@property (nonatomic, strong) NSMutableArray *tableArray;
@property (nonatomic, strong) NSDictionary *problem;
@property (nonatomic, strong) NSDictionary *guessedWord;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger totalCount;
@property (nonatomic, assign) id <TestTableViewDelegate> delegate;


- (IBAction)button1Action:(id)sender;
- (IBAction)button2Action:(id)sender;

//- (id)initWithPageNumber:(int)page andTotal:(int)total;
- (id)initWithProblem:(NSDictionary *)theProblem;

@end

@protocol TestTableViewDelegate

- (void)testTableViewNeedsToMove:(int)page;

@end
