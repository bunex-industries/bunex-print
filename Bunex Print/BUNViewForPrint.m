//
//  BUNViewForPrint.m
//  RGBCurves
//
//  Created by Jean-François Roversi on 26/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import "BUNViewForPrint.h"


@implementation BUNViewForPrint
@synthesize img;
@synthesize presetName;


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSImage *)rotateImage: (NSImage *)image clockwise:(BOOL)clockwise
{
    NSImage *existingImage = image;
    NSSize existingSize;
    
    existingSize.width = [(NSBitmapImageRep*)[[existingImage representations] objectAtIndex:0] pixelsWide];
    existingSize.height = [(NSBitmapImageRep*)[[existingImage representations] objectAtIndex:0] pixelsHigh];
    
    NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:newSize];
    
    [rotatedImage lockFocus];
    
    NSAffineTransform *rotateTF = [NSAffineTransform transform];
    NSPoint centerPoint = NSMakePoint(newSize.width / 2, newSize.height / 2);
    
    [rotateTF translateXBy: centerPoint.x yBy: centerPoint.y];
    [rotateTF rotateByDegrees: (clockwise) ? - 90 : 90];
    [rotateTF translateXBy: -centerPoint.y yBy: -centerPoint.x];
    [rotateTF concat];
    
    NSRect r1 = NSMakeRect(0, 0, newSize.height, newSize.width);
    [(NSBitmapImageRep*)[[existingImage representations] objectAtIndex:0] drawInRect: r1];
    
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}


- (void)drawRect:(NSRect)dirtyRect
{

    NSFont * font = [NSFont fontWithName:@"Courier" size:50];
    
    if (img != nil && presetName != nil)
    {
        if (img.size.width > img.size.height)
        {
            img = [self rotateImage:img clockwise:YES];
        }

        NSRect drawingRect;
        if ((img.size.width/img.size.height) > (self.frame.size.width/self.frame.size.height))
        {
            drawingRect = NSMakeRect(0, 0, self.frame.size.width, self.frame.size.width/(img.size.width/img.size.height));
        }
        else
        {
            drawingRect = NSMakeRect(0, 0, self.frame.size.height*(img.size.width/img.size.height), self.frame.size.height);   
        }
        
        //[NSGraphicsContext saveGraphicsState];
        [self lockFocus];
        
            [img drawInRect:drawingRect 
                   fromRect:NSMakeRect(0, 0, img.size.width, img.size.height) 
                  operation:NSCompositeSourceOver 
                   fraction:1.0];
        
        NSMutableParagraphStyle * pgs = [[NSMutableParagraphStyle alloc] init];
        [pgs setAlignment:NSCenterTextAlignment];
        [[NSColor whiteColor] set];
        NSRect labelRect = NSMakeRect(10, 30, 300, 70);
        [[NSBezierPath bezierPathWithRect:labelRect] fill];
        [presetName drawInRect:labelRect
                withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                pgs, NSParagraphStyleAttributeName,
                                font, NSFontAttributeName, 
                                [NSColor blackColor], NSForegroundColorAttributeName ,nil]];

        
        [self unlockFocus];
        //[NSGraphicsContext restoreGraphicsState];
        
        
        
    }
}




@end
