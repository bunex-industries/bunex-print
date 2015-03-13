//
//  BUNFilter.h
//  RGBCurves
//
//  Created by Jean-François Roversi on 23/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "RGBCurves.h"
#import "BUNCurvesView.h"
#import "BUNHueCurvesView.h"
#import "BUNViewForPrint.h"
#import "BUNAdjustView.h"

@interface BUNFilter : NSObject
{
    
    IBOutlet BUNCurvesView * filterView;
    IBOutlet BUNAdjustView * adjustView;
    IBOutlet NSImageView * imgView;
    IBOutlet NSImageView * gradientView;

    IBOutlet NSPopUpButton * imageSourcePopUp;
    
    IBOutlet NSPopUpButton * twentyOnePopup;
    
    IBOutlet NSButton * plusButton;
    IBOutlet NSButton * minusButton;
    IBOutlet NSTextField * pointIndexField;
    
    IBOutlet NSButton * previewButton;
    IBOutlet NSButton * bwButton;
    IBOutlet NSButton * bwFirstButton;
    IBOutlet NSButton * lumModeButton;
    IBOutlet NSPopUpButton * channelButton;
    IBOutlet NSPopUpButton * presetButton;
    IBOutlet NSTextField * presetNameField;
    
    IBOutlet NSSlider * selectedHueSlider;
    IBOutlet NSSlider * QSlider;
    IBOutlet NSSlider * hueOffsetSlider;
    IBOutlet NSSlider * satOffsetSlider;
    IBOutlet NSSlider * lumOffsetSlider; 
    
    IBOutlet BUNHueCurvesView * hueCurve;
    IBOutlet BUNHueCurvesView * satCurve;
    IBOutlet BUNHueCurvesView * lumCurve; 
    
    BOOL curveEditing;
    
    CIFilter * filter;
    NSImage * loadedImage;
}


@property (strong) IBOutlet NSWindow *window;

-(id)init;
-(void)configure;

-(NSImage*)processImage:(NSImage * )img withPreset:(NSString*)preset;
-(CIImage*)processCIImage:(CIImage*)ciimg withPreset:(NSString*)preset;

-(void)curveChange;
-(void)pointDidAdjust;

-(IBAction)shoot:(id)sender;
-(IBAction)print:(id)sender;
-(IBAction)applyAndSave:(id)sender;

-(IBAction)imageImportation:(id)sender;
-(IBAction)settingDidChange:(id)sender;
-(IBAction)savePreset:(id)sender;
-(IBAction)reset:(id)sender;
-(IBAction)pointIndexChange:(id)sender;

-(NSDictionary * )presetWithName:(NSString*)presetName;

@end
