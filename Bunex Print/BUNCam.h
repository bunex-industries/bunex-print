//
//  BUNCam.h
//  Bunex Print
//
//  Created by minibun on 26/02/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>
#import <AVFoundation/AVFoundation.h>


@interface BUNCam : NSObject
{
    
    
}

@property (strong) AVCaptureConnection* connection;;
@property (strong) AVCaptureStillImageOutput* output;
@property (strong) AVCaptureDevice* device;
@property (strong) AVCaptureDeviceInput* input;
@property (strong) AVCaptureSession * captureSession;

-(id)init;
-(void)takePictureAndSaveAt:(NSString*)path;

@end
