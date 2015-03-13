//
//  BUNAdjustView.m
//  RGBCurves
//
//  Created by Jean-François Roversi on 28/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import "BUNAdjustView.h"
#import "BUNFilter.h"

@implementation BUNAdjustView


@synthesize lumLevel;
@synthesize redLevel;
@synthesize greenLevel;
@synthesize blueLevel;

@synthesize xAxisPosition;
@synthesize yAxisPosition;
@synthesize zAxisPosition;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    
    return self;
}

-(void)reset
{
    self.xAxisPosition = 0.0;
    self.yAxisPosition = 0.0;
    self.zAxisPosition = 0.0;
    busyMode = 0;
}

-(void)awakeFromNib
{
    NSLog(@"awake");

    [self reset];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{

        for (float y = 0; y < self.frame.size.height; y++)
        {
            float l = 0.5*(y/self.frame.size.height) - 0.25;
            [[NSColor colorWithCalibratedWhite:lumLevel+l alpha:1] set];
            NSRectFill(NSMakeRect(0, y, 0.25*self.frame.size.width, 1));
        }
        
        [[NSColor orangeColor] set];
        NSRectFill(NSMakeRect(0, (2*zAxisPosition+0.5)*self.frame.size.height-1, 0.25*self.frame.size.width, 2));
        
        
        for (float x = 0.30*self.frame.size.width; x < self.frame.size.width; x++)
        {
            for (float y = 0; y < self.frame.size.height; y++)
            {
                float red = ((x - 0.30* self.frame.size.width)/(0.70 * self.frame.size.width))/2-0.25;
                float green = (y/self.frame.size.height)/2-0.25;
                
                [[NSColor colorWithCalibratedRed:redLevel+red+zAxisPosition green:greenLevel+green+zAxisPosition blue:blueLevel+zAxisPosition alpha:1] set];
                NSRectFill(NSMakeRect(x, y, 1, 1));
                
            }
        }
        
        [[NSColor orangeColor] set];
        [NSBezierPath setDefaultLineWidth:2];
        [[NSBezierPath bezierPathWithRect:NSMakeRect(0.30*self.frame.size.width + (2*xAxisPosition+0.5)*0.70*self.frame.size.width - 4, 
                                                     (2*yAxisPosition+0.5)*self.frame.size.height - 4, 
                                                     8, 
                                                     8)] stroke];
    
}


-(void)mouseDown:(NSEvent *)theEvent
{
    
    NSPoint pt = NSMakePoint(theEvent.locationInWindow.x - self.frame.origin.x, theEvent.locationInWindow.y - self.frame.origin.y);
    if (pt.x < self.frame.size.width*0.25)
    {
        busyMode = 1;
        zAxisPosition = 0.5*(pt.y / self.frame.size.height) - 0.25;
        
    }
    else if(pt.x >= self.frame.size.width*0.30)
    {
        busyMode = 2;
        xAxisPosition = 0.5*((pt.x - 0.30 * self.frame.size.width)/(0.70 * self.frame.size.width)) - 0.25;
        yAxisPosition = 0.5*(pt.y / self.frame.size.height) - 0.25;
    }
    [self setNeedsDisplay:YES];

}

-(void)mouseUp:(NSEvent *)theEvent
{
    busyMode = 0;
}

-(void)mouseDragged:(NSEvent *)theEvent
{

    NSPoint pt = NSMakePoint(theEvent.locationInWindow.x - self.frame.origin.x, theEvent.locationInWindow.y - self.frame.origin.y);
    if (pt.x < self.frame.size.width*0.25 && busyMode ==1)
    {
        zAxisPosition = 0.5*(pt.y / self.frame.size.height) - 0.25;
        zAxisPosition = MAX(MIN(zAxisPosition, 0.25), -0.25);
        [self setNeedsDisplay:YES];
    }
    else if(pt.x > self.frame.size.width*0.30 && busyMode ==2)
    {
        xAxisPosition = 0.5*((pt.x - 0.30 * self.frame.size.width)/(0.70 * self.frame.size.width)) - 0.25;
        yAxisPosition = 0.5*(pt.y / self.frame.size.height) - 0.25;
                
        xAxisPosition = MAX(MIN(xAxisPosition, 0.25), -0.25);
        yAxisPosition = MAX(MIN(yAxisPosition, 0.25), -0.25);
    }
    [self setNeedsDisplay:YES];
    [delegate pointDidAdjust];
}






@end
