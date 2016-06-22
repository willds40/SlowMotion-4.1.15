//
//  CaptureManager.h
//  SlowMoSlowPoke
//
//  Created by Will Devon-sand on 5/11/16.
//  Copyright © 2016 Will Devon-sand. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface CaptureManager : NSObject
@property (nonatomic, strong) AVCaptureSession *captureSession;
@end
