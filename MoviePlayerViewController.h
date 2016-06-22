//
//  MoviePlayerViewController.h
//  SlowMoSlowPoke
//
//  Created by Will Devon-sand on 5/23/16.
//  Copyright © 2016 Will Devon-sand. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>


@import AVKit;



@interface MoviePlayerViewController : UIViewController 



@property (strong,nonatomic)AVPlayer *player;
@property (strong, nonatomic)AVPlayerViewController *playerViewController;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic, weak) IBOutlet UIButton *playButton;

- (IBAction)PlaySlowMotion:(id)sender;

//This is the file path of the movie that is taken from the previous view controller
@property (nonatomic, strong)NSString *path;
@property (nonatomic,strong)NSURL *fileURL; 
- (IBAction)backButton:(id)sender;


- (IBAction)play:sender;

@end
