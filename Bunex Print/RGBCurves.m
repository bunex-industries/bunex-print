//
//  BUNOpacityFilter.m
//  videoAccumulator
//
//  Created by Jean-François Roversi on 13/05/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import "RGBCurves.h"

@implementation RGBCurves



static CIKernel *_redChannelKernel = nil;
static CIKernel *_greenChannelKernel = nil;
static CIKernel *_blueChannelKernel = nil;
static CIKernel *_rgbChannelKernel = nil;

static CIKernel *_convert2hsl = nil;

static CIKernel *_hueChannelKernel = nil;
static CIKernel *_satChannelKernel = nil;
static CIKernel *_lumChannelKernel = nil;
static CIKernel *_hslChannelKernel = nil;

static CIKernel *_bwKernel = nil;
static CIKernel *_convert2rgb = nil;

static CIKernel *_hueOffset = nil;
static CIKernel *_satOffset = nil;
static CIKernel *_lumOffset = nil;

static CIKernel *_curveKernel = nil;

-(void)resetValuesTwentyOneMode:(int)twentyOne
{
    NSLog(@"filter reset with %d points", twentyOne>0? 21: 5);
    redPoints = [[NSMutableArray alloc] init];
    greenPoints= [[NSMutableArray alloc] init];
    bluePoints = [[NSMutableArray alloc] init];
    rgbPoints = [[NSMutableArray alloc] init];
    satPoints = [[NSMutableArray alloc] init];
    BW = NO;
    BWfirst = YES;
    lumMode = NO;
    selectedHue = 0.0;
    Q = 300.0;
    hueOffset = 0.0;
    satOffset = 0.0;
    lumOffset = 0.0;
    
    if (twentyOne != 0)
    {
        for (float i = 0 ; i < 21; i++)
        {
            [redPoints addObject:NSStringFromPoint(NSMakePoint(i/20, i/20))];
            [greenPoints addObject:NSStringFromPoint(NSMakePoint(i/20, i/20))];
            [bluePoints addObject:NSStringFromPoint(NSMakePoint(i/20, i/20))];
            [rgbPoints addObject:NSStringFromPoint(NSMakePoint(i/20, i/20))];
            [satPoints addObject:NSStringFromPoint(NSMakePoint(i/20, i/20))];
        }
    }
    else
    {
        for (float i = 0 ; i < 5; i++)
        {
            [redPoints addObject:NSStringFromPoint(NSMakePoint(i/4, i/4))];
            [greenPoints addObject:NSStringFromPoint(NSMakePoint(i/4, i/4))];
            [bluePoints addObject:NSStringFromPoint(NSMakePoint(i/4, i/4))];
            [rgbPoints addObject:NSStringFromPoint(NSMakePoint(i/4, i/4))];
            [satPoints addObject:NSStringFromPoint(NSMakePoint(i/4, i/4))];
        }
    }
    

}

- (id)init
{
    [CIPlugIn loadAllPlugIns];
        
    NSError * err;
    NSBundle    *bundle = [NSBundle mainBundle];
    NSString    *code = [NSString stringWithContentsOfFile:[bundle pathForResource:@"kernels" ofType: @"cikernel"] 
                                                  encoding:NSUTF8StringEncoding 
                                                     error:&err];
    
    NSArray     *kernels = [CIKernel kernelsWithString: code];
    NSLog(@"%d kernels found", (int)kernels.count);
    if(_redChannelKernel == nil)
    {
        _redChannelKernel = [kernels objectAtIndex:0];
    }
    if(_greenChannelKernel == nil)
    {
        _greenChannelKernel = [kernels objectAtIndex:1];
    }
    if(_blueChannelKernel == nil)
    {
        _blueChannelKernel = [kernels objectAtIndex:2];
    }
    if(_rgbChannelKernel == nil)
    {
        _rgbChannelKernel = [kernels objectAtIndex:3];
    }
    if(_convert2hsl == nil)
    {
        _convert2hsl = [kernels objectAtIndex:4];
    }
    if(_hueChannelKernel == nil)
    {
        _hueChannelKernel = [kernels objectAtIndex:5];
    }
    if(_satChannelKernel == nil)
    {
        _satChannelKernel = [kernels objectAtIndex:6];
    }
    if(_lumChannelKernel == nil)
    {
        _lumChannelKernel = [kernels objectAtIndex:7];
    }
    if(_hslChannelKernel == nil)
    {
        _hslChannelKernel = [kernels objectAtIndex:8];
    }
    if(_bwKernel == nil)
    {
        _bwKernel = [kernels objectAtIndex:9];
    }
    if(_convert2rgb == nil)
    {
        _convert2rgb = [kernels objectAtIndex:10];
    }
    if(_hueOffset == nil)
    {
        _hueOffset = [kernels objectAtIndex:11];
    }
    if(_satOffset == nil)
    {
        _satOffset = [kernels objectAtIndex:12];
    }
    if(_lumOffset == nil)
    {
        _lumOffset = [kernels objectAtIndex:13];
    }
    if(_curveKernel == nil)
    {
        _curveKernel = [kernels objectAtIndex:14];
    }
    
    [self resetValuesTwentyOneMode:NO];
    
    return [super init];
}


-(CIVector*)vectorWithPoint:(NSPoint)pt
{
    CIVector * vec = [CIVector vectorWithX:pt.x Y:pt.y];
    return vec;
}

-(CIImage*)toneCurve:(CIImage*) img points:(NSArray*)arr
{
    CIFilter *toneCurve = [CIFilter filterWithName:@"CIToneCurve" keysAndValues:
                            @"inputImage",img,
                            @"inputPoint0", [self vectorWithPoint:NSPointFromString([arr objectAtIndex:0])],
                            @"inputPoint1", [self vectorWithPoint:NSPointFromString([arr objectAtIndex:1])],
                            @"inputPoint2", [self vectorWithPoint:NSPointFromString([arr objectAtIndex:2])],
                            @"inputPoint3", [self vectorWithPoint:NSPointFromString([arr objectAtIndex:3])],
                            @"inputPoint4", [self vectorWithPoint:NSPointFromString([arr objectAtIndex:4])],
                            nil];
    
    return [toneCurve valueForKey:@"outputImage"];
}

-(NSArray*)floatListWith:(NSArray*)pts
{
    NSMutableArray * tmp = [NSMutableArray array];
    
    for (NSString * ptstr in pts)
    {
        NSPoint pt = NSPointFromString(ptstr);
        [tmp addObject:[NSNumber numberWithFloat:pt.x]];
        [tmp addObject:[NSNumber numberWithFloat:pt.y]];
    }
    
    return [NSArray arrayWithArray:tmp];
}

- (CIImage *)outputImage
{
    if (inputImage)
    {        
        CISampler *src = [CISampler samplerWithImage:inputImage];
        NSArray * extentArray = [NSArray arrayWithObjects:
                                 [NSNumber numberWithFloat:0], 
                                 [NSNumber numberWithFloat:0], 
                                 [NSNumber numberWithFloat:[inputImage extent].size.width],
                                 [NSNumber numberWithFloat:[inputImage extent].size.height],nil];
        
        NSDictionary * opts = [NSDictionary dictionaryWithObjectsAndKeys:extentArray, kCIApplyOptionExtent, nil];
        CIImage * rgbChannel;
        
        if (BW && BWfirst) {
            inputImage = [self apply:_bwKernel arguments:[NSArray arrayWithObjects:src, nil] options:opts];
            src = [CISampler samplerWithImage:inputImage];
        }
        
        CIImage * rChannel = [self apply:_redChannelKernel arguments:[NSArray arrayWithObjects:src, nil] options:opts];
        CIImage * gChannel = [self apply:_greenChannelKernel arguments:[NSArray arrayWithObjects:src, nil] options:opts];
        CIImage * bChannel = [self apply:_blueChannelKernel arguments:[NSArray arrayWithObjects:src, nil] options:opts];
        
        if (rgbPoints.count == 5)
        {
            rChannel = [self toneCurve:rChannel points:redPoints];
            gChannel = [self toneCurve:gChannel points:greenPoints];
            bChannel = [self toneCurve:bChannel points:bluePoints];
            
            rgbChannel = [self apply:_rgbChannelKernel arguments:[NSArray arrayWithObjects:rChannel,gChannel,bChannel, nil] options:opts];
            
            if (lumMode == NO)
            {
                rgbChannel = [self toneCurve:rgbChannel points:rgbPoints];
            }
            
            
            CIImage * hslChannel = [self apply:_convert2hsl arguments:[NSArray arrayWithObjects:rgbChannel, nil] options:opts];
            CIImage * hueChannel = [self apply:_hueChannelKernel arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
            CIImage * satChannel = [self apply:_satChannelKernel arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
            CIImage * lumChannel = [self apply:_lumChannelKernel arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
            
            
            satChannel = [self apply:_satOffset arguments:[NSArray arrayWithObjects:
                                                           hueChannel, 
                                                           satChannel, 
                                                           [NSNumber numberWithFloat:satOffset], 
                                                           [NSNumber numberWithFloat:selectedHue], 
                                                           [NSNumber numberWithFloat:Q], nil] options:opts];
            satChannel = [self toneCurve:satChannel points:satPoints];
            
            lumChannel = [self apply:_lumOffset arguments:[NSArray arrayWithObjects:
                                                           hueChannel, 
                                                           satChannel,
                                                           lumChannel,
                                                           [NSNumber numberWithFloat:lumOffset], 
                                                           [NSNumber numberWithFloat:selectedHue], 
                                                           [NSNumber numberWithFloat:Q], nil] options:opts];
            
            hueChannel = [self apply:_hueOffset arguments:[NSArray arrayWithObjects:
                                                           hueChannel, 
                                                           [NSNumber numberWithFloat:hueOffset], 
                                                           [NSNumber numberWithFloat:selectedHue], 
                                                           [NSNumber numberWithFloat:Q], nil] options:opts];
            
            if (lumMode == YES)
            {
                lumChannel = [self toneCurve:lumChannel points:rgbPoints];
            }
            
            hslChannel = [self apply:_hslChannelKernel arguments:[NSArray arrayWithObjects:hueChannel, satChannel, lumChannel, nil] options:opts];
            
            rgbChannel = [self apply:_convert2rgb arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
        }
        else if(rgbPoints.count == 21)
        {
            NSMutableArray * arguments;
            
            if (lumMode == NO)
            {
                //RGB
                arguments = [NSMutableArray array];
                [arguments addObject:rChannel];
                [arguments addObjectsFromArray:[self floatListWith:rgbPoints]];
                rChannel = [self apply:_curveKernel arguments:arguments options:opts];
                
                [arguments replaceObjectAtIndex:0 withObject:gChannel];
                gChannel = [self apply:_curveKernel arguments:arguments options:opts];
                
                [arguments replaceObjectAtIndex:0 withObject:bChannel];
                bChannel = [self apply:_curveKernel arguments:arguments options:opts];
            }

            
            //RED
            arguments = [NSMutableArray array];
            [arguments addObject:rChannel];
            [arguments addObjectsFromArray:[self floatListWith:redPoints]];
            rChannel = [self apply:_curveKernel arguments:arguments options:opts];
            
            //GREEN
            arguments = [NSMutableArray array];
            [arguments addObject:gChannel];
            [arguments addObjectsFromArray:[self floatListWith:greenPoints]];
            gChannel = [self apply:_curveKernel arguments:arguments options:opts];
            
            //BLUE
            arguments = [NSMutableArray array];
            [arguments addObject:bChannel];
            [arguments addObjectsFromArray:[self floatListWith:bluePoints]];
            bChannel = [self apply:_curveKernel arguments:arguments options:opts];
            
            rgbChannel = [self apply:_rgbChannelKernel arguments:[NSArray arrayWithObjects:rChannel, gChannel, bChannel, nil] options:opts];
            
            CIImage * hslChannel = [self apply:_convert2hsl arguments:[NSArray arrayWithObjects:rgbChannel, nil] options:opts];
            CIImage * hueChannel = [self apply:_hueChannelKernel arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
            CIImage * satChannel = [self apply:_satChannelKernel arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
            CIImage * lumChannel = [self apply:_lumChannelKernel arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
            
            
            satChannel = [self apply:_satOffset arguments:[NSArray arrayWithObjects:
                                                           hueChannel, 
                                                           satChannel, 
                                                           [NSNumber numberWithFloat:satOffset], 
                                                           [NSNumber numberWithFloat:selectedHue], 
                                                           [NSNumber numberWithFloat:Q], nil] options:opts];
            
            arguments = [NSMutableArray array];
            [arguments addObject:satChannel];
            [arguments addObjectsFromArray:[self floatListWith:satPoints]];
            satChannel = [self apply:_curveKernel arguments:arguments options:opts];
            
            lumChannel = [self apply:_lumOffset arguments:[NSArray arrayWithObjects:
                                                           hueChannel, 
                                                           satChannel,
                                                           lumChannel,
                                                           [NSNumber numberWithFloat:lumOffset], 
                                                           [NSNumber numberWithFloat:selectedHue], 
                                                           [NSNumber numberWithFloat:Q], nil] options:opts];
            
            hueChannel = [self apply:_hueOffset arguments:[NSArray arrayWithObjects:
                                                           hueChannel, 
                                                           [NSNumber numberWithFloat:hueOffset], 
                                                           [NSNumber numberWithFloat:selectedHue], 
                                                           [NSNumber numberWithFloat:Q], nil] options:opts];
            
            if (lumMode == YES)
            {
                arguments = [NSMutableArray array];
                [arguments addObject:lumChannel];
                [arguments addObjectsFromArray:[self floatListWith:rgbPoints]];
                lumChannel = [self apply:_curveKernel arguments:arguments options:opts];
            }
            
            hslChannel = [self apply:_hslChannelKernel arguments:[NSArray arrayWithObjects:hueChannel, satChannel, lumChannel, nil] options:opts];
            
            rgbChannel = [self apply:_convert2rgb arguments:[NSArray arrayWithObjects:hslChannel, nil] options:opts];
            
        }
        
        if (BW && !BWfirst) {
            rgbChannel = [self apply:_bwKernel arguments:[NSArray arrayWithObjects:rgbChannel, nil] options:opts];
        }
            
        return rgbChannel;
         
    }
    return nil;
}



+ (void)initialize
{
    [CIFilter registerFilterName:@"RGBCurves"
                     constructor:(id<CIFilterConstructor>)self
                 classAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                  @"RGBCurves", kCIAttributeFilterDisplayName,
                                   [NSArray arrayWithObjects:
                                    kCICategoryColorAdjustment, 
                                    kCICategoryVideo,
                                    kCICategoryStillImage,
                                    kCICategoryInterlaced,
                                    kCICategoryNonSquarePixels,nil], kCIAttributeFilterCategories,
                                   nil]];
}

+ (CIFilter *)filterWithName:(NSString *)name
{
    CIFilter  *filter;
    filter = [[self alloc] init];
    return filter;
}

@end
