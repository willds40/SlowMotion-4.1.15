//
//  MovieCollectionViewController.h
//  SlowMoSlowPoke
//
//  Created by Will Devon-sand on 5/23/16.
//  Copyright © 2016 Will Devon-sand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoviePlayerViewController.h"


@interface MovieCollectionViewController : UICollectionViewController

@property (strong, nonatomic) NSMutableArray *movieFilesImages;

@property (strong, nonatomic)MoviePlayerViewController *moviePlayerViewController;

@property(strong,nonatomic) NSMutableArray *filePaths;

@end
