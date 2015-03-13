//
//  BUNCam.m
//  Bunex Print
//
//  Created by minibun on 26/02/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import "BUNCam.h"

@implementation BUNCam

@synthesize connection, output, input, device, captureSession;

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        NSError* erroor;
        self.device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
        
        /*
        [self.device lockForConfiguration:&erroor];
        NSLog(@"AVCaptureFocusModeLocked supported ? %@", [self.device isFocusModeSupported:AVCaptureFocusModeLocked] ? @"YES" : @"NO");
        NSLog(@"AVCaptureFocusModeContinuousAutoFocus supported ? %@", [self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus] ? @"YES" : @"NO");
        NSLog(@"AVCaptureFocusModeAutoFocus supported ? %@", [self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus] ? @"YES" : @"NO");
        
        NSLog(@"AVCaptureExposureModeLocked supported ? %@", [self.device isExposureModeSupported:AVCaptureExposureModeLocked] ? @"YES" : @"NO");
        NSLog(@"AVCaptureExposureModeContinuousAutoExposure supported ? %@", [self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure] ? @"YES" : @"NO");
        NSLog(@"AVCaptureExposureModeAutoExpose supported ? %@", [self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose] ? @"YES" : @"NO");
        
        [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];

        [self.device unlockForConfiguration];
        */        
        self.input = [AVCaptureDeviceInput deviceInputWithDevice: self.device error: &erroor];
        if (!self.input)
        {
            NSLog(@"CAM = %@", [erroor description]);
        }
        
        self.output = [AVCaptureStillImageOutput new];
        //[self.output setOutputSettings: @{(id)kCVPixelBufferPixelFormatTypeKey: @(k32BGRAPixelFormat)}];
        
        self.captureSession = [AVCaptureSession new];
        self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        
        [self.captureSession addInput: self.input];
        [self.captureSession addOutput: self.output];
        [self.captureSession startRunning];
        self.connection = [self.output connectionWithMediaType: AVMediaTypeVideo];
        
        
        return self;
    }
    return nil;
}




- (void)takePictureAndSaveAt:(NSString * )path
{
    if (!self.output.isCapturingStillImage && self.connection.isActive)
    {
        [self.output captureStillImageAsynchronouslyFromConnection: self.connection completionHandler: ^(CMSampleBufferRef sampleBuffer, NSError* error)
         {
             NSData * JPGData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
             BOOL d = [[NSFileManager defaultManager] createFileAtPath:path
                                                              contents:JPGData
                                                            attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSDate date],NSFileCreationDate, nil]];
             
             if (!d)
             {
                 NSLog(@"CAM = write error (path = %@ data ? %@)", path, JPGData != nil ? @"YES" : @"NO");
             }
             else
             {
                 NSLog(@"CAM = image written");
             }
             
         }];
    }
    
}


@end
