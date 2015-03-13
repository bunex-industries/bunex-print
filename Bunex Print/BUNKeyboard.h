//
//  BUNKeyboard.h
//  Bunex Print
//
//  Created by minibun on 01/03/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BUNKeyboard : NSView
{
    BOOL caps;
    NSString * currentString;
    NSTextField * txt;
}

-(void)configure;

@end
