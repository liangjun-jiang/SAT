/*
     File: OneViewController.m 
 Abstract: The view controller for page one. 
  Version: 1.1 
  
   
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "IndexViewController.h"
//#import "SubLevelViewController.h"
#import "SVProgressHUD.h"

#define MARKED_POSITION @"marked_position"

@interface IndexViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSArray *_sections;
    
    NSArray *_contents;
    
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
	
	// The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
}

@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) NSInteger savedScopeButtonIndex;
@property (nonatomic) BOOL searchWasActive;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchDisplayController;
@end

@implementation IndexViewController
@synthesize filteredListContent, savedScopeButtonIndex, searchWasActive, savedSearchTerm;
@synthesize searchBar, searchDisplayController;
@synthesize subLevel;

// this is called when its tab is first tapped by the user

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 44.0)];
    self.searchBar.delegate = self;
    self.searchBar.scopeButtonTitles = @[@"word",@"meaning"];
    self.tableView.tableHeaderView = self.searchBar;
    
    // The default is hidding
    
    [self.tableView setContentOffset:CGPointMake(0, 44)];
    
    self.searchDisplayController = [[UISearchDisplayController alloc]
                                    initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    
    // We know we have all letters starting with those characters
    _sections = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
    
    // read file, already be presorted alphabetically
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"plist"];
    _contents = [NSArray arrayWithContentsOfFile:sourcePath];
    
    // create a filtered list that will contain products for the search results table.
	self.filteredListContent = [NSMutableArray arrayWithCapacity:[_contents count]];
	
	// restore search settings if they were saved in didReceiveMemoryWarning.
    if (self.savedSearchTerm)
	{
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setSelectedScopeButtonIndex:self.savedScopeButtonIndex];
        [self.searchDisplayController.searchBar setText:savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
	
	[self.tableView reloadData];
	self.tableView.scrollEnabled = YES;
    
    // check if the user has been marked to somewhere he wants to go.
    // We scroll to there
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if([defaults objectForKey:MARKED_POSITION] !=nil ) {
//        NSDictionary *markedPosition = [defaults objectForKey:MARKED_POSITION];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[markedPosition[@"row"] intValue] inSection:[markedPosition[@"section"] intValue]];
//        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
	self.filteredListContent = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // save the state of the search UI so that it can be restored if the view is re-created
    self.searchWasActive = [self.searchDisplayController isActive];
    self.savedSearchTerm = [self.searchDisplayController.searchBar text];
    self.savedScopeButtonIndex = [self.searchDisplayController.searchBar selectedScopeButtonIndex];
}

#pragma mark - AppDelegate methods

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:MARKED_POSITION] !=nil ) {
        NSDictionary *markedPosition = [defaults objectForKey:MARKED_POSITION];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[markedPosition[@"row"] intValue] inSection:[markedPosition[@"section"] intValue]];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}


#pragma mark -
#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return 1;
    } else
        
        return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [self.filteredListContent count];
    } else {
        
        NSArray *sectionArray = [_contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"word beginswith[c] %@", _sections[section]]];
        
        return [sectionArray count];
    }
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    } else
        return  _sections;
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    } else
        return index;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return @"";
    } else
        return _sections[section];
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    
    NSDictionary *vocalbulary = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        vocalbulary = (self.filteredListContent)[indexPath.row];
    }
	else {
        NSArray *sectionArray = [_contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"word beginswith[c] %@", _sections[indexPath.section]]];
        vocalbulary = sectionArray[indexPath.row];
        
    }
    
    cell.textLabel.text = vocalbulary[@"word"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@,%@",vocalbulary[@"type"], vocalbulary[@"meaning"]];
    cell.detailTextLabel.numberOfLines  = 2;
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // todo: it doesn't work
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if([defaults objectForKey:MARKED_POSITION] !=nil ) {
//        NSDictionary *markedPosition = [defaults objectForKey:MARKED_POSITION];
//        NSIndexPath *markedIndexPath = [NSIndexPath indexPathForRow:[markedPosition[@"row"] intValue] inSection:[markedPosition[@"section"] intValue]];
//        
//        // I can't compare in this way
//        if ([markedIndexPath isEqual:indexPath]) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
//        NSUInteger markedSection = [markedPosition[@"section"] intValue];
//        NSUInteger markedRow = [markedPosition[@"row"] intValue];
//        
//        NSArray *sectionArray = [_contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"word beginswith[c] %@", _sections[markedSection]]];
//        NSDictionary * markedVocalbulary = sectionArray[markedRow];
//        
//        if ([markedVocalbulary isEqualToDictionary:vocalbulary]) {
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        }
        
//    }
    
    return cell;
}



#pragma mark - table Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *markedPosition = nil;
    //TODO: IT DOESN'T WORK
    // we create a marker, and remove an existing marker (if available)
//    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if([defaults objectForKey:MARKED_POSITION] != nil ) {
//        markedPosition = [defaults objectForKey:MARKED_POSITION];
//        NSIndexPath *markedIndexPath = [NSIndexPath indexPathForRow:[markedPosition[@"row"] intValue] inSection:[markedPosition[@"section"] intValue]];
//        UITableViewCell *markedCell = [tableView cellForRowAtIndexPath:markedIndexPath];
//        if (![markedIndexPath isEqual:indexPath]) {
//            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
//            markedCell.accessoryType = UITableViewCellAccessoryNone;
//        }
//        
//    }
    
    // we save the new position
    markedPosition = @{@"section":[NSNumber numberWithInt:indexPath.section], @"row":[NSNumber numberWithInt:indexPath.row]};
    [defaults setObject:markedPosition forKey:MARKED_POSITION];
    [defaults synchronize];
    
    // We then let the user know (or not)
    [SVProgressHUD showSuccessWithStatus:@"Location saved!"];
    
}

#pragma mark -
#pragma mark UIViewControllerRotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES; // support all orientations
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
	for (NSDictionary *dict in _contents)
	{
        NSString *search;
        
        if ([scope isEqualToString:@"word"])
        {
            search = dict[@"word"];
            NSComparisonResult result = [search compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
            if (result == NSOrderedSame)
            {
                [self.filteredListContent addObject:dict];
            }
        } else if ([scope isEqualToString:@"meaning"])// search by meaning
        {
            search = dict[@"meaning"];
            NSRange nameRange = [search rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound)
            {
                [self.filteredListContent addObject:dict];
            }
        }
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [self.searchDisplayController.searchBar scopeButtonTitles][searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

@end
