//
//  iCarouselExampleViewController.m
//  iCarouselExample
//
//  Created by Nick Lockwood on 03/04/2011.
//  Copyright 2011 Charcoal Design. All rights reserved.
//

#import "GroupedWordViewController.h"
#import "AppDelegate.h"
#import "PhoneContentController.h"
#import "SVProgressHUD.h"

#define SCROLL_SPEED 0.3 //items per second, can be negative or fractional


static NSString *NameKey = @"word";
static NSString *TypeKey = @"type";
static NSString *MeaningKey = @"meaning";

@interface GroupedWordViewController ()

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, assign) NSTimer *scrollTimer;
@property (nonatomic, assign) NSTimeInterval lastTime;

@end


@implementation GroupedWordViewController

@synthesize carousel;
@synthesize items;
@synthesize scrollTimer;
@synthesize lastTime;
@synthesize contentDictionary;
@synthesize contentList;



#pragma mark -
#pragma mark View lifecycle
-(id)initWithDataSource:(NSDictionary *)dataSource
{
    self = [super initWithNibName:@"GroupedWordViewController"  bundle:nil];
    if (self) {
        self.contentDictionary = dataSource;
        self.contentList = self.contentDictionary[MarkedGroup];
    }
    
    return self;
    
}


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil

{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.contentDictionary[MarkedGroupKey];
    
    self.contentList = self.contentDictionary[MarkedGroup];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:MARKED_POSITION] !=nil ) {
        NSDictionary *markedPosition = [defaults objectForKey:MARKED_POSITION];
        NSString *rememebered = self.contentList[[markedPosition[@"row"] integerValue]][NameKey];
        
        NSString *message = [NSString stringWithFormat:@"Your last review was at %@ keep up!",rememebered];
        [SVProgressHUD  showSuccessWithStatus:message];
    }
    
    //configure carousel
    carousel.type = iCarouselTypeCylinder;
    
    //start scrolling
    [self startScrolling];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    //free up memory by releasing subviews
    self.carousel = nil;
    
    //stop timer
    [scrollTimer invalidate];
    
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    //this is true even if your project is using ARC, unless
    //you are targeting iOS 5 as a minimum deployment target
    carousel.delegate = nil;
    carousel.dataSource = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    return [contentList count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *nameLabel = nil;
    UILabel *typeLabel = nil;
    UILabel *meaningLabel = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        
        float padding = 5.0f;
        float width = 200.0f;
        float singleHeight = 30.0f;
        
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, 200.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        
        CGRect labelRect = CGRectMake(padding, 2*padding, width-2*padding, singleHeight);
        nameLabel = [[UILabel alloc] initWithFrame:labelRect];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:25];
        nameLabel.textColor = [UIColor redColor];
        nameLabel.tag = 11;
        [view addSubview:nameLabel];
        
        
        labelRect = CGRectMake(padding, singleHeight+4*padding, width, singleHeight);
        typeLabel = [[UILabel alloc] initWithFrame:labelRect];
        typeLabel.backgroundColor = [UIColor clearColor];
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.font = [UIFont fontWithName:@"ChalkboardSE-Light" size:25];
        typeLabel.tag = 12;
        [view addSubview:typeLabel];
        
        labelRect = CGRectMake(padding, 2*singleHeight+6*padding, width-2*padding, 2*singleHeight);
        
        meaningLabel = [[UILabel alloc] initWithFrame:labelRect];
        meaningLabel.backgroundColor = [UIColor clearColor];
        meaningLabel.textAlignment = NSTextAlignmentCenter;
        meaningLabel.font = [UIFont fontWithName:@"ChalkboardSE-Regular" size:14];
        meaningLabel.numberOfLines = 2;
        meaningLabel.lineBreakMode = NSLineBreakByWordWrapping;
        meaningLabel.tag = 13;
        [view addSubview:meaningLabel];
        
    }
    else
    {
        //get a reference to the label in the recycled view
        nameLabel = (UILabel *)[view viewWithTag:11];
        typeLabel = (UILabel *)[view viewWithTag:12];
        meaningLabel = (UILabel *)[view viewWithTag:13];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    
    NSDictionary *numberItem = (self.contentList)[index];
    nameLabel.text = numberItem[NameKey];
    typeLabel.text = numberItem[TypeKey];
    meaningLabel.text = numberItem[MeaningKey];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    switch (option)
    {
        case iCarouselOptionSpacing:
            return value * 1.1;
        default:
            return value;
    }
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    [SVProgressHUD showSuccessWithStatus:@"Location Saved"];
    
}

#pragma mark -
#pragma mark Autoscroll

- (void)startScrolling
{
    [scrollTimer invalidate];
    scrollTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0
                                                    target:self
                                                 selector:@selector(scrollStep)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)stopScrolling
{
    [scrollTimer invalidate];
    scrollTimer = nil;
}

- (void)scrollStep
{
    //calculate delta time
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    float delta = lastTime - now;
    lastTime = now;
    
    //don't autoscroll when user is manipulating carousel
    if (!carousel.dragging && !carousel.decelerating)
    {
        //scroll carousel
        carousel.scrollOffset += delta * (float)(SCROLL_SPEED);
    }
}

@end
