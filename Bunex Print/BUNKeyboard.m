//
//  BUNKeyboard.m
//  Bunex Print
//
//  Created by minibun on 01/03/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import "BUNKeyboard.h"

@implementation BUNKeyboard

-(id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self != nil)
    {
        NSLog(@"keyboard init");
        [self setFrame:frameRect];
        currentString = @"";
        return self;
    }
    return nil;
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    /*
    [[NSColor lightGrayColor] set];
    [[NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:5 yRadius:5] fill];
    */
}

-(void)configure
{
    int w = 50;
    int ec = 10;
    
    [[NSArray arrayWithArray:[self subviews]] makeObjectsPerformSelector:@selector(removeFromSuperviewWithoutNeedingDisplay)];
    
    
    
    NSString * line0 = caps ? @"#1234567890°_" : @"@&é\"'(_è!çà)-";
    NSString * line1 = caps ? @"AZERTYUIOP¨€" : @"azertyuiop^$";
    NSString * line2 = caps ? @"QSDFGHJKLM%*" : @"qsdfghjklmù`";
    NSString * line3 = caps ? @"<>WXCVBN?./+" : @"<>wxcvbn,;:=";
    
    NSBezelStyle bs = NSTexturedSquareBezelStyle;
    NSButtonType bt = NSMomentaryPushInButton;

    for (int i = 0; i< line0.length; i++)
    {
        NSString * chr = [line0 substringWithRange:NSMakeRange(i, 1)];
        NSButton * btn = [[NSButton alloc] initWithFrame:NSMakeRect(i*(w+ec) + 10, 4*(w+ec)+ec, w, w)];
        [btn setTarget:self];
        [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
        [btn setAction:@selector(pressed:)];
        [btn setTitle:chr];
        [btn setButtonType:bt];
        [btn setBezelStyle:bs];
        [self addSubview:btn];
    }
    for (int i = 0; i< line1.length; i++)
    {
        NSString * chr = [line1 substringWithRange:NSMakeRange(i, 1)];
        NSButton * btn = [[NSButton alloc] initWithFrame:NSMakeRect(i*(w+ec) + ec + 70, 3*(w+ec)+ec, w, w)];
        [btn setTarget:self];
        [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
        [btn setAction:@selector(pressed:)];
        [btn setTitle:chr];
        [btn setButtonType:bt];
        [btn setBezelStyle:bs];
        [self addSubview:btn];
    }
    for (int i = 0; i< line2.length; i++)
    {
        NSString * chr = [line2 substringWithRange:NSMakeRange(i, 1)];
        NSButton * btn = [[NSButton alloc] initWithFrame:NSMakeRect(i*(w+ec) + ec + 10 + 75, 2*(w+ec)+ec, w, w)];
        [btn setTarget:self];
        [btn setAction:@selector(pressed:)];
        [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
        [btn setTitle:chr];
        [btn setButtonType:bt];
        [btn setBezelStyle:bs];
        [self addSubview:btn];
    }
    for (int i = 0; i< line3.length; i++)
    {
        NSString * chr = [line3 substringWithRange:NSMakeRange(i, 1)];
        NSButton * btn = [[NSButton alloc] initWithFrame:NSMakeRect(i*(w+ec) + 10 , 1*(w+ec)+ec, w, w)];
        [btn setTarget:self];
        [btn setAction:@selector(pressed:)];
        [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
        [btn setTitle:chr];
        [btn setButtonType:bt];
        [btn setBezelStyle:bs];
        [self addSubview:btn];
    }
    
    NSButton * btn = [[NSButton alloc] initWithFrame:NSMakeRect(0*(w+ec) + 10, 2*(w+ec)+ec, 75, w)];
    [btn setTarget:self];
    [btn setAction:@selector(pressed:)];
    [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
    [btn setTitle:@"⇪"];
    [btn setState:caps];
    [btn setButtonType:NSToggleButton];
    [btn setBezelStyle:bs];
    [self addSubview:btn];
    
    btn = [[NSButton alloc] initWithFrame:NSMakeRect(line0.length*(w+ec) + 10, 4*(w+ec)+ec, 75, w)];
    [btn setTarget:self];
    [btn setAction:@selector(pressed:)];
    [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
    [btn setTitle:@"⇚"];
    [btn setButtonType:bt];
    [btn setBezelStyle:bs];
    [self addSubview:btn];
    
    btn = [[NSButton alloc] initWithFrame:NSMakeRect((line0.length-1)*(w+ec) + 75 + 10 + ec, 2*(w+ec)+ec, w, 2*w+ec)];
    [btn setTarget:self];
    [btn setAction:@selector(pressed:)];
    [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
    [btn setTitle:@"↵"];
    [btn setButtonType:bt];
    [btn setBezelStyle:bs];
    [self addSubview:btn];
    
    btn = [[NSButton alloc] initWithFrame:NSMakeRect(3*(w+ec) + 10, ec, 10*w,w)];
    [btn setTarget:self];
    [btn setAction:@selector(pressed:)];
    [btn setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:20]];
    [btn setTitle:@" "];
    [btn setButtonType:bt];
    [btn setBezelStyle:bs];
    [self addSubview:btn];
    
    txt = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 5*(w+ec)+ec+ec, self.frame.size.width-20, w)];
    [txt setFont:[NSFont fontWithName:@"DINAlternate-Bold" size:30]];
    [txt setBackgroundColor:[NSColor colorWithWhite:220.0/255.0 alpha:1]];
    [txt setBordered:NO];

    [txt setTextColor:[NSColor darkGrayColor]];
    [self addSubview:txt];
    [txt setSelectable:NO];
    [txt setEditable:NO];
    [txt setStringValue:currentString];
    
    NSLog(@"btn count = %lu", self.subviews.count);
    [self setNeedsDisplay: YES];
}

-(void)pressed:(NSButton*)sender
{
    
    NSString * chr = [sender title];
    
    if ([chr isEqualToString:@"⇪"])
    {
        NSLog(@"caps = %lu", sender.state);
        caps = sender.state;
        [self configure];
    }
    else if ([chr isEqualToString:@"⇚"])
    {
        if (currentString.length)
        {
            currentString = [currentString substringToIndex:currentString.length-1];
            [txt setStringValue:currentString];
        }
    }
    else if ([chr isEqualToString:@"↵"])
    {
        NSLog(@"validate string = %@ %@", currentString, [self checkEmail:currentString] ? @"(email valide)" : @"(invalide)");
    }
    else
    {
        currentString = [currentString stringByAppendingString:chr];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"^a" withString:@"â"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"^e" withString:@"ê"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"^i" withString:@"î"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"^o" withString:@"ô"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"^u" withString:@"û"];
        
        currentString = [currentString stringByReplacingOccurrencesOfString:@"¨a" withString:@"ä"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"¨e" withString:@"ë"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"¨i" withString:@"ï"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"¨o" withString:@"ö"];
        currentString = [currentString stringByReplacingOccurrencesOfString:@"¨u" withString:@"ü"];
        [txt setStringValue:currentString];
        [txt setBackgroundColor:[self checkEmail:currentString] ? [NSColor colorWithRed:0.2 green:1 blue:0 alpha:0.5]: [NSColor colorWithWhite:220.0/255.0 alpha:1]];
    }
    [self setNeedsDisplay: YES];
}

-(BOOL)checkEmail:(NSString*)str
{
    ////    email check
    ////    ^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,4}|com|be|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)$
    ////    ^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+)\.([a-zA-Z]{2,4}|com|be|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)$
    
    BOOL isValid = NO;
    NSError * error;
    NSString * regexString = @"^([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+)\\.([a-zA-Z]{2,4}|com|be|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)$";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSArray * arr = [regex matchesInString:str options:0 range:NSMakeRange(0, [str length])];
    if (arr.count)
    {
        isValid = YES;
    }
    return isValid;
}





@end
