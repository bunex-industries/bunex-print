//
//  BUNOpacityFilter.h
//  videoAccumulator
//
//  Created by Jean-François Roversi on 13/05/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//


#import <Quartz/Quartz.h>


@interface RGBCurves : CIFilter
{
    CIImage *   inputImage;
    
    NSMutableArray * redPoints;
    NSMutableArray * greenPoints;
    NSMutableArray * bluePoints;
    NSMutableArray * rgbPoints;
    NSMutableArray * satPoints;
    
    BOOL BW;
    BOOL BWfirst;
    BOOL lumMode;
    

    float selectedHue;
    float Q;
    float hueOffset;
    float satOffset;
    float lumOffset;
}

-(void)resetValuesTwentyOneMode:(int)twentyOne;

@end
