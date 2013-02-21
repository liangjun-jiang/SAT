/*
     File: TwoViewController.m 
 Abstract: The view controller for page two. 
  Version: 1.1 
  
   
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "TwoViewController.h"
#import "PhoneContentController.h"

@interface TwoViewController () 
	@property (nonatomic, strong) NSArray *dataArray;
    @property (nonatomic, strong) NSMutableArray *wordsByGroup;
    @property (nonatomic, strong) NSArray *contents;
    @property (nonatomic, strong) NSArray *sections;
@end

@implementation TwoViewController

@synthesize dataArray;
@synthesize wordsByGroup;

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    self.slidingViewController.underRightViewController = nil;
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    // reload in case new location saved
    [self.tableView reloadData];
}

// this is called when its tab is first tapped by the user
- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.title = @"Test Mode";
	
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuItem;
    
    // Set up the word list
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"words" ofType:@"plist"];
    self.contents = [NSArray arrayWithContentsOfFile:sourcePath];
    
    self.sections = @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"];
    
    self.wordsByGroup = [NSMutableArray arrayWithCapacity:[self.sections count]];
    // We should put those into dictionary
    [self.sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSArray *sectionArray = [self.contents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"word beginswith[c] %@", self.sections[idx]]];
        [dict setObject:sectionArray forKey:self.sections[idx]];
        [self.wordsByGroup addObject:dict];
    }];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
	self.dataArray = nil;
}



#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellID];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
    
    NSDictionary *dict = self.wordsByGroup[indexPath.row];
    NSString *key = self.sections[indexPath.row];
    
    
    cell.textLabel.text = key;
    
    NSUInteger markedPageNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"tested"];
    NSMutableDictionary *bookmarkDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    markedPageNumber = [bookmarkDict[key] integerValue];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d of %d",markedPageNumber, [dict[key] count]];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *dict = self.wordsByGroup[indexPath.row];
    NSString *key = self.sections[indexPath.row];
    NSArray *words = dict[key];
    
    NSDictionary *contentDictionary = @{MarkedGroupKey:key, MarkedGroup:words};
    PhoneContentController *contentController = [[PhoneContentController alloc] initWithNibName:@"PhoneContent" bundle:nil];
    contentController.contentDictionary = contentDictionary;
    
    [self.navigationController pushViewController:contentController animated:YES];
    
}


#pragma mark -
#pragma mark UIViewControllerRotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES; // support all orientations
}

@end
