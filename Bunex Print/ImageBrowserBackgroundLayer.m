


#import "ImageBrowserBackgroundLayer.h"

@implementation ImageBrowserBackgroundLayer

@synthesize owner;


- (id) init
{
	if((self = [super init])){
		//needs to redraw when bounds change
		[self setNeedsDisplayOnBoundsChange:YES];
	}
	return self;
}


- (id<CAAction>)actionForKey:(NSString *)event
{
	return nil;
}


- (void)drawInContext:(CGContextRef)context
{
    float val = 232.0/255.0;
    CGContextSetFillColorWithColor(context, CGColorCreateGenericGray(val, 1.0));
    CGContextFillRect(context, (CGRect)[owner bounds]);
    
}

@end
