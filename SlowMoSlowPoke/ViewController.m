//
//  ViewController.m
//  SlowMoSlowPoke
//
//  Created by Will Devon-sand on 5/11/16.
//  Copyright © 2016 Will Devon-sand. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    NSTimeInterval startTime;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //creating background queue
    self.sessionQueue = dispatch_queue_create( "session queue", DISPATCH_QUEUE_SERIAL );
   
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetInputPriority;

    dispatch_async( self.sessionQueue, ^{
        
    //check for erros. (check to see if necessary later)
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        
        NSError *error = nil;
        
    //Get the live video feed
    AVCaptureDevice *inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
      
        
    //&error basically stores the error
    AVCaptureDeviceInput * deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
        
    //check to see if session can run this device
        
    [self.captureSession beginConfiguration];

    if ([self.captureSession canAddInput:deviceInput]) {
        [self.captureSession addInput:deviceInput];
        self.deviceInput = deviceInput;
        [self.captureSession canAddInput:deviceInput];
        }
        
    //Dispactches back to the main queue
    dispatch_async( dispatch_get_main_queue(), ^{
                // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                // can only be manipulated on the main thread.
                
                // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                // -[viewWillTransitionToSize:withTransitionCoordinator:].
                
                UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
                AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
                if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                    initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
                }
                
                //Setting up the live preview that you can see
                self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
                
                 //set it the preivew to fit the whole of the view
                self.previewLayer.frame = self.preview.bounds;
                self.previewLayer.contentsGravity = kCAGravityResizeAspectFill;
                self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                [self.preview.layer insertSublayer:self.previewLayer atIndex:0];
                
            } );
                   
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
            if ( ! audioDeviceInput ) {
                NSLog( @"Could not create audio device input: %@", error );
                   }
                if ( [self.captureSession canAddInput:audioDeviceInput] ) {
                       [self.captureSession addInput:audioDeviceInput];
                   }
                   else {
                       NSLog( @"Could not add audio device input to the session" );
                   }
   
        //Setting up the output to be a quicktime vieeo player
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ( [self.captureSession canAddOutput:movieFileOutput] ) {
            [self.captureSession addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ( connection.isVideoStabilizationSupported ) {
                connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
            self.movieFileOutput = movieFileOutput;
        }

        [self.captureSession commitConfiguration];
    
    } );
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    dispatch_async( self.sessionQueue, ^{
        
// Only setup observers and start the session running if setup succeeded.
//         [self addObservers];
    [self.captureSession startRunning];
    self.sessionRunning = self.captureSession.isRunning;

    } );
}

#pragma mark Orientation

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ! self.movieFileOutput.isRecording;
}

//supports all rotations of the camera.
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Updates the time for the statusUpdate Label
- (void)timerHandler:(NSTimer *)timer {
    
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval recorded = current - startTime;
    
    self.statusUpdate.text = [NSString stringWithFormat:@"%.2f", recorded];
}


- (IBAction)FPSSwitch:(id)sender {
    // Switch FPS
    
    CGFloat desiredFps = 60.0;
    

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
    [self switchFormatWithDesiredFPS:desiredFps];
        
                });
    

}

- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS
{
    //    BOOL isRunning = self.captureSession.isRunning;
    //
    //    if (isRunning)  [self.captureSession stopRunning];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int32_t maxWidth = 0;
    AVFrameRateRange *frameRateRange = nil;
    
    for (AVCaptureDeviceFormat *format in [videoDevice formats]) {
        
        for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
            
            CMFormatDescriptionRef desc = format.formatDescription;
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(desc);
            int32_t width = dimensions.width;
            
            if (range.minFrameRate <= desiredFPS && desiredFPS <= range.maxFrameRate && width >= maxWidth) {
                
                selectedFormat = format;
                frameRateRange = range;
                maxWidth = width;
            }
        }
    }
    
    if (selectedFormat) {
        
        if ([videoDevice lockForConfiguration:nil]) {
            
            NSLog(@"selected format:%@", selectedFormat);
            videoDevice.activeFormat = selectedFormat;
            videoDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)desiredFPS);
            [videoDevice unlockForConfiguration];
        }
    }
    
    //    if (isRunning) [self.captureSession startRunning];
}





- (IBAction)recBtn:(id)sender {
    
    {
// Disable the  the Record button until recording starts or finishes and the FPS Buttton
    self.recBtn.enabled = NO;
    self.FPSOutlet.enabled = NO;
    dispatch_async( self.sessionQueue, ^{
            if ( ! self.movieFileOutput.isRecording ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // timer start
                    startTime = [[NSDate date] timeIntervalSince1970];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:.00
                        target:self
                        selector:@selector(timerHandler:)
                        userInfo:nil
                        repeats:YES];
                });
                
                if ( [UIDevice currentDevice].isMultitaskingSupported ) {
                    // Setup background task. This is needed because the -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:]
                    // callback is not received until AVCam returns to the foreground unless you request background execution time.
                    // This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                    // To conclude this background execution, -endBackgroundTask is called in
                    // -[captureOutput:didFinishRecordingToOutputFileAtURL:fromConnections:error:] after the recorded file has been saved.
                    self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
               AVCaptureConnection *connection = [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
               
                connection.videoOrientation = self.previewLayer.connection.videoOrientation;
                
                 // change UI
                dispatch_async(dispatch_get_main_queue(), ^{
                     [self.recBtn setImage:self.recStopImage
                    forState:UIControlStateNormal];
                    
                });
                //save it to a temporary file path
                NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[outputFileName stringByAppendingPathExtension:@"mov"]];
                
                [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            }
            else {
                  // REC STOP
                [self.movieFileOutput stopRecording];
                
                //dispatched to main queue so that time could be updated. 
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.timer invalidate];
                    self.timer = nil;

            });
                
            }
        } );
    }
    
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    // Enable the Record button to let the user stop the recording.
    dispatch_async( dispatch_get_main_queue(), ^{
        self.recBtn.enabled = YES;
        [self.recBtn setTitle:NSLocalizedString( @"Stop", @"Recording button stop title") forState:UIControlStateNormal];
    });
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
//    // Note that currentBackgroundRecordingID is used to end the background task associated with this recording.
//    // This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's isRecording property
//    // is back to NO — which happens sometime after this method returns.
//    // Note: Since we use a unique file path for each recording, a new recording will not overwrite a recording currently being saved.
    UIBackgroundTaskIdentifier currentBackgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
   
    dispatch_block_t cleanup = ^{
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        if ( currentBackgroundRecordingID != UIBackgroundTaskInvalid ) {
            [[UIApplication sharedApplication] endBackgroundTask:currentBackgroundRecordingID];
        }
    };
    
    BOOL success = YES;
    
    if ( error ) {
        NSLog( @"Movie file finishing error: %@", error );
        success = [error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] boolValue];
    }
    if ( success ){
    //save to the nsdocumentary directory. Get access through phone.
        
        NSString *outputFileName = [NSProcessInfo processInfo].globallyUniqueString;
        
            NSData *videoData = [NSData dataWithContentsOfURL:outputFileURL];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *tempPath = [documentsDirectory stringByAppendingPathComponent:[outputFileName
            stringByAppendingPathExtension:@"mov"]];
                                  
            BOOL success = [videoData writeToFile:tempPath atomically:NO];
        
        }
     else {
        cleanup();
    }
    
    // Enable the Camera and Record buttons to let the user switch camera and start another recording.
    dispatch_async( dispatch_get_main_queue(), ^{
        // Only enable the ability to change camera if the device has more than one camera.
        self.recBtn.enabled = YES;
        [self.recBtn setImage:[UIImage imageNamed:@"recordButton.png"]forState:UIControlStateNormal];
    });
}

@end
