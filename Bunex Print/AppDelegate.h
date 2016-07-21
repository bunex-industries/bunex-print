//
//  AppDelegate.h
//  ImageKit test
//
//  Created by minibun on 25/02/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "imageItem.h"
#import "UKKQueue.h"
#import "UKFileWatcher.h"
#import "ImageBrowserView.h"
#import "ImageBrowserCell.h"
#import "ImageBrowserBackgroundLayer.h"
#import "BUNCam.h"
#import "BUNFilter.h"
#import "BUNKeyboard.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    ImageBrowserView * imageBrowserView;
    BUNKeyboard * keyboard;
    NSMutableArray * files;
    NSMutableArray * importedFiles;
    IBOutlet NSScrollView *scrollView;
    IBOutlet NSSlider *zoomSlider;
    UKKQueue * queue;
    NSString *selectedImage;
    
    NSArray * editorArray;
    
    int lastSelected;

    BUNCam * cam;
    BUNFilter * bunFilter;
    
    IBOutlet NSButton *     autoFullScreenButton;
    IBOutlet NSTextField *  workingFolderField;
    IBOutlet NSButton *     workingFolderChooseButton;
    
    IBOutlet NSButton *     archiveOldButton;
    IBOutlet NSButton *     archivePrintedButton;
    IBOutlet NSButton *     archiveGifButton;
    IBOutlet NSButton *     archiveExtensionsButton;
    IBOutlet NSTextField *  archiveExtensionsField;
    
    IBOutlet NSButton *     useWebCamButton;
    IBOutlet NSButton *     takePhotoButton;
    IBOutlet NSButton *     printButton;
    IBOutlet NSButton *     gifButton;
    
    IBOutlet NSMatrix *     orientMatrix;
    IBOutlet NSTextField *  docWidthField;
    IBOutlet NSTextField *  docHeightField;
    IBOutlet NSButton *     shouldLayoutButton;
    
    IBOutlet NSButton *     chooseVerticalBackButton;
    IBOutlet NSTextField *  verticalBackField;
    IBOutlet NSButton *     chooseHorizontalBackButton;
    IBOutlet NSTextField *  horizontalBackField;
    
    IBOutlet NSPopUpButton * frontCompositingPopup;
    IBOutlet NSButton *     chooseVerticalFrontButton;
    IBOutlet NSTextField *  verticalFrontField;
    IBOutlet NSTextField *  verticalX;
    IBOutlet NSTextField *  verticalY;
    IBOutlet NSTextField *  verticalH;
    IBOutlet NSTextField *  verticalW;
    
    IBOutlet NSButton *     chooseHorizontalFrontButton;
    IBOutlet NSButton *     deleteFrontButton;
    IBOutlet NSButton *     deleteBackButton;
    IBOutlet NSTextField *  horizontalFrontField;
    IBOutlet NSTextField *  horizontalX;
    IBOutlet NSTextField *  horizontalY;
    IBOutlet NSTextField *  horizontalH;
    IBOutlet NSTextField *  horizontalW;
    
    IBOutlet NSTextField *  qrCodeMessageField;
    IBOutlet NSTextField *  qrCodeHAngle;
    IBOutlet NSTextField *  qrCodeHX;
    IBOutlet NSTextField *  qrCodeHY;
    IBOutlet NSTextField *  qrCodeHH;
    IBOutlet NSTextField *  qrCodeHW;
    IBOutlet NSTextField *  qrCodeVAngle;
    IBOutlet NSTextField *  qrCodeVX;
    IBOutlet NSTextField *  qrCodeVY;
    IBOutlet NSTextField *  qrCodeVH;
    IBOutlet NSTextField *  qrCodeVW;
    
    
    IBOutlet NSButton *     shouldPrintButton;
    IBOutlet NSPopUpButton * printersPopup;
    IBOutlet NSPopUpButton * printSettingsPopup;
    IBOutlet NSTextField *  printSettingsNameField;
    IBOutlet NSTextField *  printArgumentsField;
    IBOutlet NSButton *     testPrintButton;
    IBOutlet NSButton *     savePrintSettingButton;
    
    IBOutlet NSPopUpButton * filter1Popup;
    IBOutlet NSPopUpButton * filter2Popup;
    IBOutlet NSPopUpButton * filter3Popup;
    
    IBOutlet NSSlider * filter1Slider;
    IBOutlet NSSlider * filter2Slider;
    IBOutlet NSSlider * filter3Slider;
    
    IBOutlet NSButton *     filterEditorButton;
    
    IBOutlet NSButton *     shouldNotifyButton;
    IBOutlet NSTextField *  emailField;
    IBOutlet NSTextField *  subjectField;
    IBOutlet NSTextField *  messageField;
    
    
    IBOutlet NSButton *     shouldCreateGifButton;
    IBOutlet NSPopUpButton * gifFPSButton;
    IBOutlet NSTextField *  gifWidthField;
    IBOutlet NSTextField *  gifHeightField;
    IBOutlet NSTextField *  gifMinCountField;
    IBOutlet NSTextField *  gifMaxCountField;
    
}



@property (strong) NSString * todoFolder;
@property (strong) NSString * doneFolder;
@property (strong) NSString * archivesFolder;

@property (strong) IBOutlet NSWindow * preferencesWindow;

-(IBAction)prefChange:(id)sender;
-(IBAction)openPrefs:(id)sender;

-(IBAction)showViewer:(id)sender;


-(IBAction)zoom:(NSSlider*)sender;
-(IBAction)toggleFullScreen:(id)sender;
-(IBAction)next:(NSButton*)btn;
-(IBAction)prev:(NSButton*)btn;
-(IBAction)saveAndPrint:(NSButton*)btn;
-(IBAction)photo:(NSButton*)btn;
-(IBAction)makeGif:(NSButton*)btn;

-(IBAction)razPrefs:(NSButton*)btn;

@end

