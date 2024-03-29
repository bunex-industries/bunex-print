/* =============================================================================
	FILE:		UKMainThreadProxy.h
	PROJECT:	UKMainThreadProxy
    
    PURPOSE:    Send a message to object theObject to [theObject mainThreadProxy]
                instead and the message will be received on the main thread by
                theObject.

    COPYRIGHT:  (c) 2004 M. Uli Kusterer, all rights reserved.
    
	AUTHORS:	M. Uli Kusterer - UK
    
    LICENSES:   MIT License�

	REVISIONS:
		2006-03-13	UK	Clarified license.
		2004-10-14	UK	Created.
   ========================================================================== */

// -----------------------------------------------------------------------------
//  Headers:
// -----------------------------------------------------------------------------

#import "UKMainThreadProxy.h"


@implementation UKMainThreadProxy

-(id)	initWithTarget: (id)targ
{
	self = [super init];
	if( self )
		target = targ;
	
	return self;
}


// -----------------------------------------------------------------------------
//	Introspection overrides:
// -----------------------------------------------------------------------------

-(BOOL)	respondsToSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	
	return( does || [target respondsToSelector: itemAction] );
}


-(id)	performSelector: (SEL)itemAction
{
	BOOL	does = [super respondsToSelector: itemAction];
	if( does )
		return [NSObject performSelector: itemAction];
	
	if( ![target respondsToSelector: itemAction] )
		[self doesNotRecognizeSelector: itemAction];
	
	[target performSelectorOnMainThread: itemAction withObject: nil waitUntilDone: YES];
	
	return nil;
}


-(id)	performSelector: (SEL)itemAction withObject: (id)obj
{

    
    
	BOOL	does = [super respondsToSelector: itemAction];
	if( does )
    {
        return [NSObject performSelector: itemAction withObject: obj];
    }
		
	
	if( ![target respondsToSelector: itemAction] )
		[self doesNotRecognizeSelector: itemAction];
	

	[target performSelectorOnMainThread: itemAction withObject: obj waitUntilDone: YES];

	
	return nil;
}


// -----------------------------------------------------------------------------
//	Forwarding unknown methods to the target:
// -----------------------------------------------------------------------------

-(NSMethodSignature*)	methodSignatureForSelector: (SEL)itemAction
{
	NSMethodSignature*	sig = [super methodSignatureForSelector: itemAction];

	if( sig )
		return sig;
	
	return [target methodSignatureForSelector: itemAction];
}

-(void)	forwardInvocation: (NSInvocation*)invocation
{
    SEL itemAction = [invocation selector];

    if( [target respondsToSelector: itemAction] )
	{
		[invocation retainArguments];
		[invocation performSelectorOnMainThread: @selector(invokeWithTarget:) withObject: target waitUntilDone: YES];

	}
	else
        [self doesNotRecognizeSelector: itemAction];
}


// -----------------------------------------------------------------------------
//	Safety net:
// -----------------------------------------------------------------------------

-(id)	mainThreadProxy     // Just in case someone accidentally sends this message to a main thread proxy.
{
	return self;
}

-(id)	copyMainThreadProxy	// Just in case someone accidentally sends this message to a main thread proxy.
{
	return self;
}

@end


// -----------------------------------------------------------------------------
//	Shorthand notation for getting a main thread proxy:
// -----------------------------------------------------------------------------

@implementation NSObject (UKMainThreadProxy)

-(id)	mainThreadProxy
{
	return [[UKMainThreadProxy alloc] initWithTarget: self];
}

-(id)	copyMainThreadProxy
{
	return [[UKMainThreadProxy alloc] initWithTarget: self];
}

@end

