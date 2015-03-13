//
//  BUNHueCurvesView.m
//  RGBCurves
//
//  Created by Jean-François Roversi on 25/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import "BUNHueCurvesView.h"

@implementation BUNHueCurvesView
@synthesize hue;
@synthesize gain;
@synthesize Q;
@synthesize scale;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    
    
    NSBezierPath * lineV = [NSBezierPath bezierPath];
    [lineV setLineWidth:0.5];
    for (float i = 0; i < self.frame.size.width ; i+=10)
    {
        [lineV moveToPoint:NSMakePoint(i, 0)];
        [lineV lineToPoint:NSMakePoint(i, self.frame.size.height)];
    }
    [[NSColor colorWithDeviceWhite:0 alpha:0.25] setStroke];
    [lineV stroke];

    NSBezierPath * lineH = [NSBezierPath bezierPath];
    [lineH setLineWidth:0.5];
    for (float i = 0 ; i < self.frame.size.height/2 ; i+=10)
    {
        [lineH moveToPoint:NSMakePoint(0, self.frame.size.height/2+i)];
        [lineH lineToPoint:NSMakePoint(self.frame.size.width, self.frame.size.height/2+i)];
        [lineH moveToPoint:NSMakePoint(0, self.frame.size.height/2-i)];
        [lineH lineToPoint:NSMakePoint(self.frame.size.width, self.frame.size.height/2-i)];
    }
    [lineH stroke];
    
    NSBezierPath * p = [NSBezierPath bezierPath];
    for (int h = 0; h < self.frame.size.width; h++)
    {
        float hh = scale * 
        (gain * exp(-(10.0 + Q)*(h/self.frame.size.width-hue)*(h/self.frame.size.width-hue)) + 
        gain * exp(-(10.0 + Q)*(h/self.frame.size.width-hue+1)*(h/self.frame.size.width-hue+1)) + 
        gain * exp(-(10.0 + Q)*(h/self.frame.size.width-hue-1)*(h/self.frame.size.width-hue-1)));
        
        if (h == 0)
        {
            [p moveToPoint:NSMakePoint(h, self.frame.size.height/2 + hh * self.frame.size.height)];
        }
        else
        {
            [p lineToPoint:NSMakePoint(h, self.frame.size.height/2 + hh * self.frame.size.height)];
        }        
    }
    
    [p setLineWidth:2];
    [[NSColor darkGrayColor] setStroke];
    [p stroke];
}

@end
