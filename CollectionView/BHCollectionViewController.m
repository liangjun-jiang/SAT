//
//  BHCollectionViewController.m
//  CollectionViewTutorial
//
//  Created by Bryan Hansen on 11/3/12.
//  Copyright (c) 2012 Bryan Hansen. All rights reserved.
//

#import "BHCollectionViewController.h"
#import "BHPhotoAlbumLayout.h"
#import "BHAlbumPhotoCell.h"
#import "BHAlbum.h"
#import "BHPhoto.h"
#import "BHAlbumTitleReusableView.h"
#import "PhoneContentController.h"
#import "GroupedWordViewController.h"

static NSString * const PhotoCellIdentifier = @"PhotoCell";
static NSString * const AlbumTitleIdentifier = @"AlbumTitle";


@interface BHCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *albums;
@property (nonatomic, strong) NSMutableArray *wordsByGroup;

@property (nonatomic, weak) IBOutlet BHPhotoAlbumLayout *photoAlbumLayout;
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;
@property (nonatomic, strong) ContentController *contentController;
@property (nonatomic, strong) NSArray *contents;
@property (nonatomic, strong) NSArray *sections;

@end

@implementation BHCollectionViewController

#pragma mark - Lifecycle
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithNibName:@"BHCollectionViewController" bundle:nil];
    if (self) {
        
    }
    
    return self;
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // shadowPath, shadowOffset, and rotation is handled by ECSlidingViewController.
    // You just need to set the opacity, radius, and color.
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }

    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"AutoPlay Mode";
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(revealMenu:)];
    self.navigationItem.leftBarButtonItem = menuItem;
    
    UIImage *patternImage = [UIImage imageNamed:@"concrete_wall"];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    
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
    
    
    [self.collectionView registerClass:[BHAlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.collectionView registerClass:[BHAlbumTitleReusableView class]
            forSupplementaryViewOfKind:BHPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - View Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.photoAlbumLayout.numberOfColumns = 3;
        
        // handle insets for iPhone 4 or 5
        CGFloat sideInset = [UIScreen mainScreen].preferredMode.size.width == 1136.0f ?
                            45.0f : 25.0f;
        
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, sideInset, 13.0f, sideInset);
        
    } else {
        self.photoAlbumLayout.numberOfColumns = 2;
        self.photoAlbumLayout.itemInsets = UIEdgeInsetsMake(22.0f, 22.0f, 13.0f, 22.0f);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{

    return [self.wordsByGroup count]; // should be 26
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BHAlbumPhotoCell *photoCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier
                                                  forIndexPath:indexPath];
    NSString *imageName = [NSString stringWithFormat:@"%@.png", self.sections[indexPath.section]];
    
    photoCell.imageView.image = [UIImage imageNamed:imageName];

    return photoCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    BHAlbumTitleReusableView *titleView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:AlbumTitleIdentifier
                                                  forIndexPath:indexPath];
    
    
    NSDictionary *dict = self.wordsByGroup[indexPath.section];
    NSString *key = self.sections[indexPath.section];
    
    NSUInteger markedPageNumber = 0;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *bookmarkDict = [defaults objectForKey:@"grouped"];
    markedPageNumber = [bookmarkDict[key] integerValue];
    titleView.titleLabel.text = [NSString stringWithFormat:@"%d of %d",markedPageNumber, [dict[key] count]];
    return titleView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.wordsByGroup[indexPath.section];
    NSString *key = self.sections[indexPath.section];
    NSArray *words = dict[key];
    
    NSDictionary *contentDictionary = @{MarkedGroupKey:key, MarkedGroup:words};
    GroupedWordViewController *groupedWordViewController = [[GroupedWordViewController alloc] initWithDataSource:contentDictionary];
    
    [self.navigationController pushViewController:groupedWordViewController animated:YES];

}

@end
