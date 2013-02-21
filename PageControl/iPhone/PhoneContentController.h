/*
     File: PhoneContentController.h 
 Abstract: Content controller used to manage the iPhone user interface for this app. 
  Version: 1.4 
  
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "ContentController.h"
#import "TestTableViewController.h"

extern NSString * const BookmarkKey;
extern const NSString *MarkedGroup;
extern const NSString *MarkedGroupKey;
extern const NSString *MarkedPage;

@interface PhoneContentController : UIViewController <UIScrollViewDelegate, TestTableViewDelegate>
{   
    UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
    
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
}
@property (nonatomic, strong) NSArray *contentList;
@property (nonatomic, strong) NSDictionary *contentDictionary;

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;

@property (nonatomic, strong) NSMutableArray *viewControllers;

- (IBAction)changePage:(id)sender;
- (void)loadScrollViewWithPage:(int)page;

@end