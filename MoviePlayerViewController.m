//
//  MoviePlayerViewController.m
//  SlowMoSlowPoke
//
//  Created by Will Devon-sand on 5/23/16.
//  Copyright © 2016 Will Devon-sand. All rights reserved.
//

#import "MoviePlayerViewController.h"



@interface MoviePlayerViewController ()
@end


@implementation MoviePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

[self syncUI];
    [self loadAssetFromFile];
    
    //creating the view controller to play in
    
    self.playerViewController = [[AVPlayerViewController alloc] init];
    [self.playerViewController.view setFrame:CGRectMake(0, 50, self.view.frame.size.width, self.view.bounds.size.height/1.5)];
    
    self.playerViewController.showsPlaybackControls = NO;
    
    [self.view addSubview:self.playerViewController.view];
    
}

- (void)syncUI {
    if ((self.player.currentItem != nil) &&
        ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        self.playButton.enabled = YES;
    }
    else {
        self.playButton.enabled = YES;
    }
}

- (void)loadAssetFromFile {
    //get the path from the collection view
    NSURL *fileURL = [NSURL fileURLWithPath:self.path];
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         
    // Define this constant for the key-value observation context.
    static const NSString *ItemStatusContext;
         
    // Completion handler block.
        dispatch_async(dispatch_get_main_queue(),
            ^{
                NSError *error;
                AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                            
                if (status == AVKeyValueStatusLoaded) {
                self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                    
                    
                // Register with the notification center after creating the player item.
                [[NSNotificationCenter defaultCenter]
                addObserver:self
                selector:@selector(playerItemDidReachEnd:)
                name:AVPlayerItemDidPlayToEndTimeNotification
                object:self.playerItem];
                    
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                    [self.playerViewController setPlayer:self.player];
                            }
                    else {
                    // You should deal with the error appropriately.
                    NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                            }
                        });
     }];
}

- (IBAction)backButton:(id)sender {
[self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)play:sender {
    
   
    [self.player play];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
if (object == self.player && [keyPath isEqualToString:@"status"]) {
    if (self.player.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
        }
    else if (self.player.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayer Ready to Play");
        }
    else if (self.player.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
        }
    }
}


- (IBAction)PlaySlowMotion:(id)sender {
     self.player.rate = 0.1;

}

//-(void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [
//}

@end
