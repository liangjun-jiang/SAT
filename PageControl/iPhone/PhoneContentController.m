/*
     File: PhoneContentController.m 
 Abstract: Content controller used to manage the iPhone user interface for this app. 
  Version: 1.4 
  
 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "PhoneContentController.h"
#import "AppDelegate.h"
#import "WordViewController.h"
#import "TestTableViewController.h"


static NSString *NameKey = @"word";
static NSString *TypeKey = @"type";
static NSString *MeaningKey = @"meaning";

NSString * const BookmarkKey = @"bookmark";
NSString *MarkedGroupKey = @"markedGroupKey";
NSString *MarkedGroup = @"markedGroup";

NSString *MarkedPage = @"markedPage";

@interface PhoneContentController()

@property (nonatomic, assign) NSUInteger kNumberOfPages;
@property (nonatomic, assign) NSUInteger markedPageNumber;


@end


@interface ContentController (PrivateMethods)
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end


@implementation PhoneContentController

@synthesize scrollView, pageControl, viewControllers, contentList;
@synthesize kNumberOfPages , contentDictionary, markedPageNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.myTabBarController.tabBar setHidden:YES];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.contentDictionary[MarkedGroupKey];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"") style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    UIBarButtonItem *bookmarkButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Bookmark", @"") style:UIBarButtonSystemItemOrganize target:self action:@selector(onBookmark:)];
    self.navigationItem.rightBarButtonItem = bookmarkButton;
    
    self.contentList = self.contentDictionary[MarkedGroup];
    
    if ([self.contentList count] > 0) {
        kNumberOfPages = [self.contentList count];
    } else
        kNumberOfPages = 1;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < kNumberOfPages; i++)
    {
		[controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * kNumberOfPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor clearColor];
    
    pageControl.numberOfPages = kNumberOfPages;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:BookmarkKey] !=nil) {
        NSDictionary *bookmarkDict = [defaults objectForKey:BookmarkKey];
        if ([bookmarkDict[MarkedGroupKey] isEqualToString:self.contentDictionary[MarkedGroupKey]]) {
            markedPageNumber = [bookmarkDict[MarkedPage] integerValue];
            pageControl.currentPage = markedPageNumber;
            if (markedPageNumber -1 > 0) {
                [self changePage:nil];
            }
        }
    } else {
        pageControl.currentPage = 0;
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
    }
    
}

- (void)onDone:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.myTabBarController.tabBar setHidden:NO];
    }];
}

- (void)onBookmark:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = @{MarkedGroupKey:contentDictionary[MarkedGroupKey], MarkedPage:[NSNumber numberWithInt:pageControl.currentPage]};
  
    [defaults setObject:dict forKey:BookmarkKey];
    
    [defaults synchronize];
    
    NSString *message = [NSString stringWithFormat:@"current page : %d is remembered.",pageControl.currentPage];
    
    [[[UIAlertView alloc] initWithTitle:@"Bookmark" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
}

#pragma mark - helpers

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;
    if (page >= kNumberOfPages)
        return;
    
    // replace the placeholder if necessary
    TestTableViewController *controller = viewControllers[page];
    
    if ((NSNull *)controller == [NSNull null])
    {
//        controller = [[TestTableViewController alloc] initWithPageNumber:page andTotal:kNumberOfPages];
        NSDictionary *numberItem = (self.contentList)[page];
        
        int randomIndex0, randomIndex1, randomIndex2;
        if ([self.contentList count] !=0) {
            randomIndex0 = arc4random() % self.contentList.count;
            randomIndex1 = arc4random() % self.contentList.count;
            randomIndex2 = arc4random() % self.contentList.count;
        }
        NSDictionary *option0 = (self.contentList)[randomIndex0];
        NSDictionary *option1 = (self.contentList)[randomIndex1];
        NSDictionary *option2 = (self.contentList)[randomIndex2];
        
        NSDictionary *problem = @{@"WORD":numberItem, @"OPTIONS": @[option0, option1, option2]};
        
//        controller.problem = problem;
        
        controller = [[TestTableViewController alloc] initWithProblem:problem];
        
//        controller.meaningLabel.text = numberItem[MeaningKey];
        
        viewControllers[page] = controller;
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
        
//        NSDictionary *numberItem = (self.contentList)[page];
//        controller.meaningLabel.text = numberItem[MeaningKey];
//        
//        int randomIndex0, randomIndex1, randomIndex2;
//        if ([self.contentList count] !=0) {
//            randomIndex0 = arc4random() % self.contentList.count;
//            randomIndex1 = arc4random() % self.contentList.count;
//            randomIndex2 = arc4random() % self.contentList.count;
//        }
//        NSDictionary *option0 = (self.contentList)[randomIndex0];
//        NSDictionary *option1 = (self.contentList)[randomIndex1];
//        NSDictionary *option2 = (self.contentList)[randomIndex2];
//        
//        NSDictionary *problem = @{@"WORD":numberItem, @"OPTIONS": @[option0, option1, option2]};
//                                  
//        controller.problem = problem;
        //numberItem has key of word, type and meaning ...
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender
{
    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
}

@end
