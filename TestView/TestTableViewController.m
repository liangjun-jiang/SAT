/*
     File: MyTableViewController.m
 Abstract: The main view controller of this app.
  Version: 1.3
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "TestTableViewController.h"
#import "PhoneContentController.h"

#define WORD_KEY @"WORD"
#define OPTIONS @"OPTIONS"
#define PAGEINFO @"PAGEINFO"

@implementation TestTableViewController

@synthesize myHeaderView;
//, myFooterView;
@synthesize meaningLabel, countLabel, page, totalCount;
@synthesize problem;
@synthesize guessedWord;
@synthesize tableArray;
@synthesize delegate;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}


- (id)initWithProblem:(NSDictionary *)theProblem
{
    if (self = [super initWithNibName:@"TestTableViewController" bundle:nil])
    {
        self.problem = theProblem;
        self.guessedWord = problem[WORD_KEY];
        
    }
    return self;
    
    
}


- (void)viewDidLoad
{
	// setup our table data
    self.guessedWord = problem[WORD_KEY];
    self.tableArray = problem[OPTIONS];
    
    NSDictionary *pageInfo = problem[PAGEINFO];
    page = [pageInfo[@"PAGE"] integerValue];
    totalCount = [pageInfo[@"COUNT"] integerValue];
    
    // total count
    self.countLabel.text = [NSString stringWithFormat:@"%d of %d", page + 1, totalCount];
    
    self.tableArray = [NSMutableArray arrayWithCapacity:4];
    [self.tableArray addObject:self.guessedWord];
    NSArray *optionsArray = problem[OPTIONS];
    [optionsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.tableArray addObject:obj];
    }];
    
    // we need shuffle the table array
    for (NSUInteger i = 0; i < [self.tableArray count]; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = [self.tableArray count] - i;
        NSInteger n = (arc4random() % nElements) + i;
        [self.tableArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
	
	// set up the table's header view based on our UIView 'myHeaderView' outlet
	CGRect newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.myHeaderView.frame.size.height);
	self.myHeaderView.backgroundColor = [UIColor clearColor];
	self.myHeaderView.frame = newFrame;
	self.tableView.tableHeaderView = self.myHeaderView;	// note this will override UITableView's 'sectionHeaderHeight' property
    
    self.meaningLabel.text = self.guessedWord[@"meaning"];
	
	// set up the table's footer view based on our UIView 'myFooterView' outlet
//	newFrame = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, self.myFooterView.frame.size.height);
//	self.myFooterView.backgroundColor = [UIColor clearColor];
//	self.myFooterView.frame = newFrame;
//	self.tableView.tableFooterView = self.myFooterView;	// note this will override UITableView's 'sectionFooterHeight' property
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	self.myHeaderView = nil;
//	self.myFooterView = nil;
	self.tableArray = nil;
}



#pragma mark -
#pragma mark UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
//	return @"Select one:";
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    NSDictionary *item = nil;
    item = tableArray[indexPath.row];
    cell.textLabel.text = item[@"word"];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // if there is a selected cell, we need to change its background to the default
    // This works but I am expecting a better way
    NSArray *cells = [tableView visibleCells];
    [cells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UITableViewCell *cell = (UITableViewCell *)obj;
        if (![cell.backgroundColor isEqual:[UIColor whiteColor]]) {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }];
    
    // then we will change the tableview cell background color for a correct guess or a false guess
    NSUInteger row = indexPath.row;
    NSDictionary *selectedItem = self.tableArray[row];
    NSString *correctWord = self.guessedWord[@"word"];
   
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *selectedWord = selectedCell.textLabel.text;
    
    if ([correctWord isEqualToString:selectedWord]) {
        selectedCell.backgroundColor = [UIColor greenColor];
        [self performSelector:@selector(loadNextPage) withObject:nil afterDelay:1];
    } else
        selectedCell.backgroundColor = [UIColor redColor];
    
}

#pragma mark - loadNext
- (void)loadNextPage
{
    if (page < totalCount) {
        [delegate testTableViewNeedsToMove:page + 1];
    }
    
}


#pragma mark -
#pragma mark Action methods

- (IBAction)button1Action:(id)sender
{
	// Button1 was pressed
}

- (IBAction)button2Action:(id)sender
{
	// Button2 was pressed
}

@end

