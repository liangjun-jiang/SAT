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



- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
//    NSLog(@"each section count :%@", dict);
    
    
//    self.albums = [NSMutableArray array];
//
//    NSURL *urlPrefix = [NSURL URLWithString:@"https://raw.github.com/ShadoFlameX/PhotoCollectionView/master/Photos/"];
//	
//    NSInteger photoIndex = 0;
//    
//    for (NSInteger a = 0; a < 12; a++) {
//        BHAlbum *album = [[BHAlbum alloc] init];
//        album.name = [NSString stringWithFormat:@"Photo Album %d",a + 1];
//        
//        NSUInteger photoCount = arc4random()%4 + 2;
//        for (NSInteger p = 0; p < photoCount; p++) {
//            // there are up to 25 photos available to load from the code repository
//            NSString *photoFilename = [NSString stringWithFormat:@"thumbnail%d.jpg",photoIndex % 25];
//            NSURL *photoURL = [urlPrefix URLByAppendingPathComponent:photoFilename];
//            BHPhoto *photo = [BHPhoto photoWithImageURL:photoURL];
//            [album addPhoto:photo];
//            
//            photoIndex++;
//        }
//        
//        [self.albums addObject:album];
//    }
    
    [self.collectionView registerClass:[BHAlbumPhotoCell class]
            forCellWithReuseIdentifier:PhotoCellIdentifier];
    [self.collectionView registerClass:[BHAlbumTitleReusableView class]
            forSupplementaryViewOfKind:BHPhotoAlbumLayoutAlbumTitleKind
                   withReuseIdentifier:AlbumTitleIdentifier];
    
//    self.thumbnailQueue = [[NSOperationQueue alloc] init];
//    self.thumbnailQueue.maxConcurrentOperationCount = 3;
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

    photoCell.imageView.image = [UIImage imageNamed:@"thumbnail0.jpg"];

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
    
    titleView.titleLabel.text = [NSString stringWithFormat:@"total: %d", [dict[key] count]];
    
    return titleView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = self.wordsByGroup[indexPath.section];
    NSString *key = self.sections[indexPath.section];
    NSArray *words = dict[key];
    
    PhoneContentController *contentController = [[PhoneContentController alloc] initWithNibName:@"PhoneContent" bundle:nil];
    NSDictionary *contentDictionary = @{MarkedGroupKey:key, MarkedGroup:words};
    contentController.contentDictionary = contentDictionary;
    
//    contentController.contentList = words;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:contentController];
    [self.navigationController pushViewController:contentController animated:YES];
    [self presentViewController:navController animated:YES completion:nil];
}

@end
