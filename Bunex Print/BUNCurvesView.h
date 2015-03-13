//
//  NSCurvesView.h
//  RGBCurves
//
//  Created by Jean-François Roversi on 23/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class BUNFilter;

@interface BUNCurvesView : NSView
{
    NSPoint blackPoint;
    NSPoint blackContrast;

    NSPoint whitePoint;
    NSPoint whiteContrast;
    BOOL tensorMode;
    int tensorIndex;

}

@property int channel;
@property int pointIndex;
@property (strong) BUNFilter*delegate;

@property (strong) NSMutableArray * selectedChannelPoints;

@property (strong) NSMutableArray * redPoints;
@property (strong) NSMutableArray * greenPoints;
@property (strong) NSMutableArray * bluePoints;

@property (strong) NSMutableArray * rgbPoints;
@property (strong) NSMutableArray * satPoints;

-(void)showTensors:(BOOL)show;
-(void)reset;
@end
