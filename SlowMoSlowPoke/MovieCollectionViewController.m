//
//  MovieCollectionViewController.m
//  SlowMoSlowPoke
//
//  Created by Will Devon-sand on 5/23/16.
//  Copyright © 2016 Will Devon-sand. All rights reserved.
//

#import "MovieCollectionViewController.h"
#import "VideoImageCell.h"
# import <AVFoundation/AVFoundation.h>

@interface MovieCollectionViewController ()


@end

@implementation MovieCollectionViewController

static NSString * const reuseIdentifier = @"VideoImageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    
    
    self.collectionView.delegate = self;

    self.installsStandardGestureForInteractiveMovement = TRUE;


    // LOAD UP THE NIB FILE FOR THE CELL
    UINib *nib = [UINib nibWithNibName:@"VideoImageCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // additional setup here if required.
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{

    //get movies from documetns directory.
  [self getMoviesFromDevice];

}
-(void)getMoviesFromDevice{
    
    self.movieFilesImages = [[NSMutableArray alloc]init];
    
    // Fetch directory path of document for local application.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // NSFileManager is the manager organize all the files on device.
    NSFileManager *manager = [NSFileManager defaultManager];
    
    // This function will return all of the files' Name as an array of NSString.
    NSArray *files = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    self.filePaths = [[NSMutableArray alloc]init];

    for (int i = 0; i < files.count; i++) {
        NSString *fpath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, files[i]];
        
        //add paths to mutable array
        [self.filePaths addObject:fpath];
        NSURL *fileURL = [NSURL fileURLWithPath:fpath];
        
        //add images to an array
        UIImage *img = [self thumbnailImageFromURL:fileURL];
        [self.movieFilesImages addObject:img];
        
    }
    
    [self.collectionView reloadData];

}

- (UIImage *)thumbnailImageFromURL:(NSURL *)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL: videoURL options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime requestedTime = CMTimeMake(1, 60);     // To create thumbnail image
    CGImageRef imgRef = [generator copyCGImageAtTime:requestedTime actualTime:NULL error:&err];
    NSLog(@"err = %@, imageRef = %@", err, imgRef);
    
    UIImage *thumbnailImage = [[UIImage alloc] initWithCGImage:imgRef];
    CGImageRelease(imgRef);    // MUST release explicitly to avoid memory leak
    
    
    //change the orientation to portrait mode
    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: thumbnailImage.CGImage
                                                         scale: 1.0
                                                   orientation: UIImageOrientationRight];
        return PortraitImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.movieFilesImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
   VideoImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.VideoImage.image =[self.movieFilesImages objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
        
    
    self.moviePlayerViewController= [[MoviePlayerViewController alloc]initWithNibName:@"MoviePlayerViewController" bundle:nil];
    
    self.moviePlayerViewController.path = [self.filePaths objectAtIndex:indexPath.row]; 
    
    
    [self presentViewController:self.moviePlayerViewController animated:YES completion:nil];


}
/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
