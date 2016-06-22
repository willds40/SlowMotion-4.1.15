//
//  ViewController.h
//  SlowMoSlowPoke
//
//  Created by Will Devon-sand on 5/11/16.
//  Copyright © 2016 Will Devon-sand. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MovieCollectionViewController.h"

@interface ViewController : UIViewController<AVCaptureFileOutputRecordingDelegate>

@property (weak, nonatomic) IBOutlet UILabel *statusUpdate;
@property (weak, nonatomic) IBOutlet UIView *preview;
@property (weak, nonatomic) IBOutlet UISegmentedControl *FPSOutlet;
- (IBAction)FPSSwitch:(id)sender;
- (IBAction)recBtn:(id)sender;

@property (nonatomic) AVCaptureDeviceInput *deviceInput;
@property (weak, nonatomic) IBOutlet UIButton *recBtn;

@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;


@property (nonatomic, assign) NSTimer *timer;
@property (nonatomic, strong) UIImage *recStartImage;
@property (nonatomic, strong) UIImage *recStopImage;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic, getter=isSessionRunning) BOOL sessionRunning;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;




@end

