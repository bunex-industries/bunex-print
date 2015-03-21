
#import "ImageBrowserCell.h"
#import "imageItem.h"
//---------------------------------------------------------------------------------
// setBundleImageOnLayer
//
// utilty function that creates, and sets the image (from the bundle) on the layer
//---------------------------------------------------------------------------------
//static void setBundleImageOnLayer(CALayer *layer, CFStringRef imageName)
//{
//    CGImageRef image = NULL;
//    NSString *path = [[NSBundle mainBundle] pathForResource:[(__bridge NSString *)imageName stringByDeletingPathExtension] ofType:[(__bridge NSString *)imageName pathExtension]];
//    if (!path) {
//        return;
//    }
//    
//    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL);
//    if (!imageSource) {
//        return;
//    }
//    
//    image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
//    if (!image) {
//        CFRelease(imageSource);
//        return;
//    }
//    
//    [layer setContents:(__bridge id)image];
//    
//    CFRelease(imageSource);
//    CFRelease(image);
//}


@implementation ImageBrowserCell

//---------------------------------------------------------------------------------
// layerForType:
//
// provides the layers for the given types
//---------------------------------------------------------------------------------
- (CALayer *) layerForType:(NSString*) type
{
	CGColorRef color;
	
	NSRect frame = [self frame];
	NSRect imageFrame = [self imageFrame];
	NSRect relativeImageFrame = NSMakeRect(imageFrame.origin.x - frame.origin.x, imageFrame.origin.y - frame.origin.y, imageFrame.size.width, imageFrame.size.height);
    
    
	if(type == IKImageBrowserCellForegroundLayer){
		//no foreground layer on place holders
		if([self cellState] != IKImageStateReady)
			return nil;
		
		//create a foreground layer that will contain several childs layer
		CALayer *layer = [CALayer layer];
        layer.frame =  CGRectMake(0, 0, frame.size.width, frame.size.height);

        
        if ([[[[self.representedItem imageUID] pathExtension] lowercaseString] isEqualToString:@"gif"] && ([self.representedItem anim]==nil) && gifLayer==nil)
        {
            NSLog(@"gif animated layer");
            CAKeyframeAnimation *animation = [self createGIFAnimation:[NSData dataWithContentsOfFile:[self.representedItem imageUID]]];
            [self.representedItem setAnim:animation];
            gifLayer = [CALayer layer];
            gifLayer.frame = relativeImageFrame;
            [gifLayer addAnimation:[self.representedItem anim] forKey:@"contents"];
        }
        
        if (gifLayer) {
            
            relativeImageFrame = NSMakeRect(imageFrame.origin.x - frame.origin.x, imageFrame.origin.y - frame.origin.y, imageFrame.size.width, imageFrame.size.height);
            gifLayer.frame = relativeImageFrame;
            [layer addSublayer:gifLayer];
            
        }
        
        
        
//		NSRect imageContainerFrame = [self imageContainerFrame];
//		NSRect relativeImageContainerFrame = NSMakeRect(imageContainerFrame.origin.x - frame.origin.x, imageContainerFrame.origin.y - frame.origin.y, imageContainerFrame.size.width, imageContainerFrame.size.height);
		
//		//add a glossy overlay
//		CALayer *glossyLayer = [CALayer layer];
//		glossyLayer.frame = *(CGRect*) &relativeImageContainerFrame;
//      setBundleImageOnLayer(glossyLayer, CFSTR("glossy.png"));
//		[layer addSublayer:glossyLayer];
        
//      //add a pin icon
//		CALayer *pinLayer = [CALayer layer];
//        if (self.imageBrowserView.zoomValue > 0.8)
//        {
//            setBundleImageOnLayer(pinLayer, CFSTR("whoareyou_layout.png"));
//        }
//        else if (self.imageBrowserView.zoomValue > 0.5)
//        {
//            setBundleImageOnLayer(pinLayer, CFSTR("whoareyou_layout_mid.png"));
//        }
//        else if (self.imageBrowserView.zoomValue > 0.2)
//        {
//            setBundleImageOnLayer(pinLayer, CFSTR("whoareyou_layout_little.png"));
//        }
//        else
//        {
//            
//        }
//        NSRect ee = *(CGRect*) &relativeImageContainerFrame;
//        ee = NSInsetRect(ee,
//                         (ee.size.width - imageFrame.size.width)/2,
//                         (ee.size.height - imageFrame.size.height)/2);
//        
//		pinLayer.frame = *(CGRect*) &ee;
//		[layer addSublayer:pinLayer];
		
		return layer;
	}

	/* selection layer */
	if(type == IKImageBrowserCellSelectionLayer){

        
		CALayer *selectionLayer = [CALayer layer];
		selectionLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		
		double fillComponents[4] = {1.0, 0.7, 0.0, 0.7};
		double strokeComponents[4] = {1.0, 0.7, 0.0, 1.0};
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		color = CGColorCreate(colorSpace, fillComponents);
		[selectionLayer setBackgroundColor:color];
		CFRelease(color);
		
		color = CGColorCreate(colorSpace, strokeComponents);
        CFRelease(colorSpace);
		[selectionLayer setBorderColor:color];
		CFRelease(color);

		[selectionLayer setBorderWidth:2.0];
		[selectionLayer setCornerRadius:5];
		
		return selectionLayer;
	}
	
	/* background layer */
	if(type == IKImageBrowserCellBackgroundLayer)
    {
		if([self cellState] != IKImageStateReady)
			return nil;

		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		
		NSRect backgroundRect = NSMakeRect(0, 0, frame.size.width, frame.size.height);		
		
		CALayer *photoBackgroundLayer = [CALayer layer];
		photoBackgroundLayer.frame = *(CGRect*) &backgroundRect;
				
		double fillComponents[4] = {0.95, 0.95, 0.95, 1.0};
		double strokeComponents[4] = {0.2, 0.2, 0.2, 0.5};

		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		color = CGColorCreate(colorSpace, fillComponents);
		[photoBackgroundLayer setBackgroundColor:color];
		CFRelease(color);
		
		color = CGColorCreate(colorSpace, strokeComponents);
		[photoBackgroundLayer setBorderColor:color];
		CFRelease(color);

		[photoBackgroundLayer setBorderWidth:1.0];
		[photoBackgroundLayer setShadowOpacity:0.3];
		[photoBackgroundLayer setCornerRadius:7];
        CFRelease(colorSpace);
        
        [layer addSublayer:photoBackgroundLayer];
        

        CATextLayer *gifTag = [[CATextLayer alloc] init];
        gifTag.frame = NSMakeRect(10, 0, 30, 9);
        gifTag.alignmentMode = kCAAlignmentLeft;
        gifTag.string=[[[[self representedItem] imageUID] pathExtension] uppercaseString];
        gifTag.font = (__bridge CFTypeRef)[NSFont fontWithName:@"DINAlternate-Bold" size:12];
        gifTag.fontSize = 8;
        gifTag.foregroundColor = (__bridge CGColorRef)[NSColor colorWithWhite:100.0/255.0 alpha:1.0];
        
        [layer addSublayer:gifTag];
        
		return layer;
	}
	
	return nil;
}


- (NSRect) imageFrame
{
	NSRect imageFrame = [super imageFrame];
	
	if(imageFrame.size.height == 0 || imageFrame.size.width == 0) return NSZeroRect;
	
	float aspectRatio =  imageFrame.size.width / imageFrame.size.height;
	
	NSRect container = [self imageContainerFrame];
	container = NSInsetRect(container, 8, 8);
	
	if(container.size.height <= 0) return NSZeroRect;
	
	float containerAspectRatio = container.size.width / container.size.height;
	
	if(containerAspectRatio > aspectRatio){
		imageFrame.size.height = container.size.height;
		imageFrame.origin.y = container.origin.y + container.size.height/2 - imageFrame.size.height/2;
		imageFrame.size.width = imageFrame.size.height * aspectRatio;
		imageFrame.origin.x = container.origin.x + (container.size.width - imageFrame.size.width)*0.5;
	}
	else{
		imageFrame.size.width = container.size.width;
		imageFrame.origin.x = container.origin.x;		
		imageFrame.size.height = imageFrame.size.width / aspectRatio;
		imageFrame.origin.y = container.origin.y  + container.size.height/2 - imageFrame.size.height/2;
	}
	
	imageFrame.origin.x = floorf(imageFrame.origin.x);
	imageFrame.origin.y = floorf(imageFrame.origin.y);
	imageFrame.size.width = ceilf(imageFrame.size.width);
	imageFrame.size.height = ceilf(imageFrame.size.height);
	
	return imageFrame;
}

- (NSRect) imageContainerFrame
{
	NSRect container = [super frame];
	
	return container;
}


- (NSRect) titleFrame
{
	NSRect titleFrame = [super titleFrame];

	return titleFrame;
}


- (NSRect) selectionFrame
{
	return NSInsetRect([self frame], -5, -5);
}


- (CAKeyframeAnimation *)createGIFAnimation:(NSData *)data{
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:data];
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)(data), nil);
    NSNumber *frameCount = [rep valueForProperty:@"NSImageFrameCount"];
    
    // Total loop time
    float time = 0;
    
    // Arrays
    NSMutableArray *framesArray = [NSMutableArray array];
    NSMutableArray *tempTimesArray = [NSMutableArray array];
    
    // Loop
    for (int i = 0; i < frameCount.intValue; i++){
        
        // Frame default duration
        float frameDuration = 1.0f;
        
        // Frame duration
        CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src,i,nil);
        NSDictionary *frameProperties = (__bridge NSDictionary*)cfFrameProperties;
        NSDictionary *gifProperties = frameProperties[(NSString*)kCGImagePropertyGIFDictionary];
        
        // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
        NSNumber *delayTimeUnclampedProp = gifProperties[(NSString*)kCGImagePropertyGIFUnclampedDelayTime];
        if(delayTimeUnclampedProp) {
            frameDuration = [delayTimeUnclampedProp floatValue];
        } else {
            NSNumber *delayTimeProp = gifProperties[(NSString*)kCGImagePropertyGIFDelayTime];
            if(delayTimeProp) {
                frameDuration = [delayTimeProp floatValue];
            }
        }
        
        // Make sure its not too small
        if (frameDuration < 0.011f){
            frameDuration = 0.100f;
        }
        
        [tempTimesArray addObject:[NSNumber numberWithFloat:frameDuration]];
        
        // Release
        CFRelease(cfFrameProperties);
        
        // Add frame to array of frames
        CGImageRef frame = CGImageSourceCreateImageAtIndex(src, i, nil);
        [framesArray addObject:(__bridge id)(frame)];
        
        // Compile total loop time
        time = time + frameDuration;
    }
    
    NSMutableArray *timesArray = [NSMutableArray array];
    float base = 0;
    for (NSNumber* duration in tempTimesArray){
        //duration = [NSNumber numberWithFloat:(duration.floatValue/time) + base];
        base = base + (duration.floatValue/time);
        [timesArray addObject:[NSNumber numberWithFloat:base]];
    }
    
    // Create animation
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    animation.duration = time;
    animation.repeatCount = HUGE_VALF;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.values = framesArray;
    animation.keyTimes = timesArray;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.calculationMode = kCAAnimationDiscrete;
    
    return animation;
}


@end
