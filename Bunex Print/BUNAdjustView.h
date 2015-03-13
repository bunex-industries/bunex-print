//
//  BUNAdjustView.h
//  RGBCurves
//
//  Created by Jean-François Roversi on 28/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BUNFilter;



@interface BUNAdjustView : NSView
{
    int busyMode;
}

@property float lumLevel;
@property float redLevel;
@property float greenLevel;
@property float blueLevel;

@property float xAxisPosition;
@property float yAxisPosition;
@property float zAxisPosition;
@property (strong) BUNFilter*delegate;

-(void)reset;

@end
