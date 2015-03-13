//
//  NSCurvesView.m
//  RGBCurves
//
//  Created by Jean-François Roversi on 23/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import "BUNCurvesView.h"
#import "BUNFilter.h"


static double Bezier(double t, double P0, double P1, double P2,
                     double P3) {
    return 
    pow(1-t,3)*P0 + 
    3*pow(1-t,2)*t*P1 +
    3*(1-t)*pow(t,2)*P2 +
    pow(t,3)*P3;
}


@implementation BUNCurvesView

@synthesize channel;
@synthesize selectedChannelPoints;
@synthesize redPoints;
@synthesize greenPoints;
@synthesize bluePoints;
@synthesize rgbPoints;
@synthesize satPoints;
@synthesize pointIndex;
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        channel = 0;
        pointIndex = -1;
        tensorMode = NO;

    }
    return self;
}

-(NSColor*)colorForChannel
{
    NSColor * col;
    switch (channel) {
        case 0:
            col = [NSColor darkGrayColor];
            break;
        case 1:
            col = [NSColor redColor];
            break;
        case 2:
            col = [NSColor greenColor];
            break;
        case 3:
            col = [NSColor blueColor];
            break;
        case 4:
            col = [NSColor lightGrayColor];
            break;
            
            
        default:
            break;
    }
    
    return col;
}

-(void)showTensors:(BOOL)show
{
    tensorMode = show;
    if (show)
    {
        [self reset];
    }
    
    
}

-(void)reset
{
    blackPoint = NSMakePoint(0, 0);
    blackContrast = NSMakePoint(0.25, 0.25);
    whitePoint = NSMakePoint(1, 1);
    whiteContrast = NSMakePoint(0.75, 0.75);
}
- (void)drawRect:(NSRect)dirtyRect
{
    float factor = 0.95;
    float margin = self.frame.size.width * ((1-factor)/2);
    float visibleW = self.frame.size.width * factor;
    
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
    [NSBezierPath setDefaultLineWidth:1];
    [[NSColor colorWithCalibratedWhite:0 alpha:0.1] setStroke];
    for (int i = 0; i<rgbPoints.count; i++)
    {
        //Verticaux
        [NSBezierPath strokeLineFromPoint:NSMakePoint(margin+(i*visibleW/4),    margin) 
                                  toPoint:NSMakePoint(margin+i*visibleW/4,      margin + visibleW)];
        
        //horizontaux
        [NSBezierPath strokeLineFromPoint:NSMakePoint(margin,                   i*visibleW/4 + margin) 
                                  toPoint:NSMakePoint(margin+visibleW,          i*visibleW/4 + margin)];
    }
    
    [[NSGraphicsContext currentContext] saveGraphicsState];
    
    [NSBezierPath setDefaultLineWidth:0.004];
    [[self colorForChannel] set];
    
    NSAffineTransform * tr = [NSAffineTransform transform];
    [tr translateXBy:margin yBy:margin];
    [tr scaleBy:visibleW];
    
    [tr concat];
    
    
    NSPoint ppp = NSPointFromString([selectedChannelPoints objectAtIndex:0]);
    NSBezierPath * path = [NSBezierPath bezierPath];
    [path moveToPoint:ppp];
    if (tensorMode == NO)
    {
        if (pointIndex != 0)
        {
            [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(ppp.x - 0.02, ppp.y - 0.02, 0.04, 0.04)] stroke];
        }
        else
        {
            [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(ppp.x - 0.02, ppp.y - 0.02, 0.04, 0.04)] fill];
        }
    }
    for (int i = 1; i<rgbPoints.count; i++)
    {

        NSPoint p = NSPointFromString([selectedChannelPoints objectAtIndex:i]);
        [path lineToPoint:p];
        if (tensorMode == NO)
        {
            if (i != pointIndex)
            {
                [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(p.x - 0.02, p.y - 0.02, 0.04, 0.04)] stroke];
            }
            else
            {
                [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(p.x - 0.02, p.y - 0.02, 0.04, 0.04)] fill];
            }
        }
        
        
    }
    [path stroke];
    

    if (tensorMode)
    {
        [[NSColor orangeColor] set];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(blackPoint.x - 0.02, blackPoint.y - 0.02, 0.04, 0.04)] stroke];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(blackContrast.x - 0.02, blackContrast.y - 0.02, 0.04, 0.04)] stroke];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(whitePoint.x - 0.02, whitePoint.y - 0.02, 0.04, 0.04)] stroke];
        [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(whiteContrast.x - 0.02, whiteContrast.y - 0.02, 0.04, 0.04)] stroke];
        
        [NSBezierPath strokeLineFromPoint:blackPoint toPoint:blackContrast];
        [NSBezierPath strokeLineFromPoint:whitePoint toPoint:whiteContrast];
        
    }

    [[NSGraphicsContext currentContext] restoreGraphicsState];
    
    if (pointIndex >= 0)
    {
        NSString * IN = [NSString stringWithFormat:@"IN = %d", (int)(255*NSPointFromString([selectedChannelPoints objectAtIndex:pointIndex]).x)];
        NSString * OUT = [NSString stringWithFormat:@"OUT = %d", (int)(255*NSPointFromString([selectedChannelPoints objectAtIndex:pointIndex]).y)];
        
        NSMutableParagraphStyle * pgs = [[NSMutableParagraphStyle alloc] init];
        [pgs setAlignment:NSLeftTextAlignment];
        
        [[NSString stringWithFormat:@"\t%@\n\t%@",IN, OUT] drawInRect:NSMakeRect(0, self.frame.size.height - 50, self.frame.size.width, 30) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:pgs, NSParagraphStyleAttributeName, nil]];
    }
}


-(void)mouseDown:(NSEvent *)theEvent
{
    float factor = 0.95;
    float margin = self.frame.size.width * ((1-factor)/2);
    float visibleW = self.frame.size.width * factor;
    
    NSPoint pt = NSMakePoint(([theEvent locationInWindow].x-self.frame.origin.x - margin) / visibleW, 
                             ([theEvent locationInWindow].y-self.frame.origin.y - margin) / visibleW);
    
    if (tensorMode == NO)
    {
        BOOL ok = NO;
        for (int i = 0 ; i < rgbPoints.count; i++)
        {
            NSPoint pp = NSPointFromString([selectedChannelPoints objectAtIndex:i]);
            if (sqrt(powf(pp.x-pt.x, 2) + powf(pp.y-pt.y, 2)) < 0.04) 
            {
                self.pointIndex = i;
                ok = YES;
                break;
            }
        }
        if (!ok)
        {
            self.pointIndex = -1;
        }
        [delegate pointIndexChange:self];

    }
    else
    {
        NSArray * tensors = [NSArray arrayWithObjects:[NSValue valueWithPoint:blackPoint], [NSValue valueWithPoint:blackContrast], [NSValue valueWithPoint:whitePoint], [NSValue valueWithPoint:whiteContrast], nil];
        for (int i = 0 ; i < tensors.count ; i++)
        {
            NSPoint  pp = [[tensors objectAtIndex:i] pointValue];
            if (sqrt(powf(pp.x-pt.x, 2) + powf(pp.y-pt.y, 2)) < 0.04) 
            {
                tensorIndex = i;
                break;
            }
        }
    }
    [self setNeedsDisplay:YES];
}

-(void)mouseUp:(NSEvent *)theEvent
{
    //pointIndex = -1;
}

-(void)mouseDragged:(NSEvent *)theEvent
{

    float factor = 0.95;
    float margin = self.frame.size.width * ((1-factor)/2);
    float visibleW = self.frame.size.width * factor;
    
    NSPoint pt = NSMakePoint(([theEvent locationInWindow].x-self.frame.origin.x-margin) / visibleW, 
                             ([theEvent locationInWindow].y-self.frame.origin.y -margin) / visibleW);
    
    pt = NSMakePoint(pt.x > 1 ? 1:pt.x<0 ? 0 : pt.x, pt.y > 1 ? 1:pt.y<0 ? 0 : pt.y);
    
    if (tensorMode == NO)
    {
        if (pointIndex >= 0)
        {            
            [selectedChannelPoints replaceObjectAtIndex:pointIndex withObject:NSStringFromPoint(pt)];            
            [delegate curveChange];
            
        }
    }
    else
    {
        switch (tensorIndex) {
            case 0:
                blackPoint = pt;
                break;
            case 1:
                blackContrast = pt;
                break;
            case 2:
                whitePoint = pt;
                break;
            case 3:
                whiteContrast = pt;
                break;
                
                
            default:
                break;
        }
        

        for (int i = 0; i < 21; i++)
        {
            float t = (float)i/20;
            float xx = Bezier(t, blackPoint.x, blackContrast.x, whiteContrast.x, whitePoint.x);
            float yy = Bezier(t, blackPoint.y, blackContrast.y, whiteContrast.y, whitePoint.y);
            NSPoint newPoint = NSMakePoint(xx, yy);
            
            [selectedChannelPoints replaceObjectAtIndex:i withObject:NSStringFromPoint(newPoint)];
            
        }
        [delegate curveChange];
        
    }
    [self setNeedsDisplay:YES];
}

@end
