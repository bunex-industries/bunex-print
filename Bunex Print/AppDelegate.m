//
//  AppDelegate.m
//  ImageKit test
//
//  Created by minibun on 25/02/2015.
//  Copyright (c) 2015 minibun. All rights reserved.
//

#import "AppDelegate.h"

#define VariableName(arg) (@""#arg)


@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize todoFolder, doneFolder, archivesFolder, preferencesWindow;



-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    
    self.window.styleMask = NSTitledWindowMask  | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
    
    NSString * workingFolder = [[NSUserDefaults standardUserDefaults] objectForKey:@"workingFolderField"];
    if (workingFolder == nil)
    {
        NSAlert *al = [[NSAlert alloc] init];
        workingFolder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] stringByAppendingPathComponent:@"BUNEX_WORK"];
        [[NSUserDefaults standardUserDefaults] setObject:workingFolder forKey:@"workingFolderField"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [al setInformativeText:@"Le dossier de travail est absent ou mal configuré. Un dossier nommé BUNEX_WORK va être créé sur le bureau. Vous pouvez spécifier le dossier de travail dans les préférences."];
        [al runModal];
    }

    NSLog(@"workingFolder = %@", workingFolder);
    
    [self checkOrCreateFileSystemeWhithWorkingFolder:workingFolder];

    [self loadPreset];
    
    cam = [[BUNCam alloc] init];
    
    
    lastSelected = -1;
    
    imageBrowserView = [[ImageBrowserView alloc] initWithFrame:[self.window.contentView bounds]];
    
    [imageBrowserView setDataSource:self];
    [imageBrowserView setDelegate:self];
    [imageBrowserView setCellsStyleMask:IKCellsStyleNone];
    [imageBrowserView setAllowsReordering:NO];
    [imageBrowserView setAnimates:YES];
    [imageBrowserView setAllowsDroppingOnItems:NO];
    [imageBrowserView setAllowsMultipleSelection:YES];
    
    ImageBrowserBackgroundLayer *backgroundLayer = [[ImageBrowserBackgroundLayer alloc] init];
    [imageBrowserView setBackgroundLayer:backgroundLayer];
    backgroundLayer.owner = imageBrowserView;
    [imageBrowserView setIntercellSpacing:NSMakeSize(15, 15)];
    
    files = [NSMutableArray array];
    importedFiles = [NSMutableArray array];
    
    [scrollView setDocumentView:imageBrowserView];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutohidesScrollers:YES];
    [scrollView setScrollerStyle:NSScrollerStyleOverlay];
    
    queue = [UKKQueue sharedFileWatcher];
    [queue setDelegate:self];
    [queue addPathToQueue:todoFolder];
    
    [self addImagesWithPaths:[self dateOrderedFiles:[self pathsOfFilesInDirectory:todoFolder]]];
    [imageBrowserView reloadData];
    
    if ([[[ NSUserDefaults standardUserDefaults] objectForKey:@"autoFullScreenButton"] boolValue])
    {
        [self toggleFullScreen:nil];
    }
    
    
    
}






#pragma mark PREFERENCES MANAGEMENT
/////////////////////////////////////////////
///////     PREFERENCES MANAGEMENT     //////
/////////////////////////////////////////////


-(void)loadPreset
{
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]]];
    
    NSArray * filters = [[NSUserDefaults standardUserDefaults] objectForKey:@"filters"];
    NSArray * specialFilterSettings = [[NSUserDefaults standardUserDefaults] objectForKey:@"specialFilterSettings"];
    NSArray * printPresets = [[NSUserDefaults standardUserDefaults] objectForKey:@"printPresets"];
    
#pragma mark popups
    /////// POPUP ///////
    
    [frontCompositingPopup removeAllItems];
    [frontCompositingPopup addItemsWithTitles:@[@"Alpha", @"Addition", @"Screen", @"Produit", @"Incrustation", @"Lumière douce"]];
    
    [filter1Popup removeAllItems];
    [filter2Popup removeAllItems];
    [filter3Popup removeAllItems];

    [filter1Popup addItemWithTitle:@"rien"];
    [filter2Popup addItemWithTitle:@"rien"];
    [filter3Popup addItemWithTitle:@"rien"];
    
    for (NSDictionary *d in filters)
    {
        [filter1Popup addItemWithTitle:[d objectForKey:@"name"]];
        [filter2Popup addItemWithTitle:[d objectForKey:@"name"]];
        [filter3Popup addItemWithTitle:[d objectForKey:@"name"]];
    }
    [[filter1Popup menu]addItem:[NSMenuItem separatorItem]];
    [[filter2Popup menu]addItem:[NSMenuItem separatorItem]];
    [[filter3Popup menu]addItem:[NSMenuItem separatorItem]];
    
    for (NSDictionary *d in specialFilterSettings)
    {
        [filter1Popup addItemWithTitle:[d objectForKey:@"name"]];
        [filter2Popup addItemWithTitle:[d objectForKey:@"name"]];
        [filter3Popup addItemWithTitle:[d objectForKey:@"name"]];
    }
    [printSettingsPopup removeAllItems];
    [printSettingsPopup addItemWithTitle:@"---"];
    for (NSDictionary *f in printPresets)
    {
        [printSettingsPopup addItemWithTitle:[f objectForKey:@"name"]];
    }
    [printersPopup removeAllItems];
    [printersPopup addItemsWithTitles:[self getPrinters]];

#pragma mark get defaults
    /////// GET UserDefault ///////
    
    autoFullScreenButton.state = [[[NSUserDefaults standardUserDefaults] objectForKey:@"autoFullScreenButton"] boolValue];
    
    workingFolderField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"workingFolderField"];
    
    
    archiveOldButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"archiveOldButton"];
    archivePrintedButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"archivePrintedButton"];
    archiveGifButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"archiveGifButton"];
    archiveExtensionsButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"archiveExtensionsButton"];
    archiveExtensionsField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"archiveExtensionsField"];
    useWebCamButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"useWebCamButton"];
    takePhotoButton.hidden = !useWebCamButton.state;
    
    shouldLayoutButton.state = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shouldLayoutButton"] boolValue];
    [orientMatrix selectCellAtRow:[[[NSUserDefaults standardUserDefaults] objectForKey:@"orientMatrix"] integerValue] column:0];
    docWidthField.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"docWidthField"] integerValue];
    docHeightField.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"docHeightField"] integerValue];
    
    verticalBackField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"verticalBackField"];
    horizontalBackField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalBackField"];
    verticalFrontField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"verticalFrontField"];
    horizontalFrontField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalFrontField"];
    
    [frontCompositingPopup selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"frontCompositingPopup"]];

    verticalX.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verticalX"] integerValue];
    verticalY.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verticalY"] integerValue];
    verticalW.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verticalW"] integerValue];
    verticalH.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"verticalH"] integerValue];
    horizontalX.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalX"] integerValue];
    horizontalY.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalY"] integerValue];
    horizontalW.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalW"] integerValue];
    horizontalH.integerValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalH"] integerValue];
    
    [filter1Popup selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter1Popup"]];
    [filter2Popup selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter2Popup"]];
    [filter3Popup selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter3Popup"]];
    NSDictionary * filter1 = [[filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", [[NSUserDefaults standardUserDefaults] objectForKey:@"filter1Popup"]]] firstObject];
    filter1Slider.minValue = [[filter1 objectForKey:@"minValue"] floatValue];
    filter1Slider.maxValue = [[filter1 objectForKey:@"maxValue"] floatValue];
    filter1Slider.floatValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"filter1Slider"] floatValue];
    NSDictionary * filter2 = [[filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", [[NSUserDefaults standardUserDefaults] objectForKey:@"filter2Popup"]]] firstObject];
    filter2Slider.minValue = [[filter2 objectForKey:@"minValue"] floatValue];
    filter2Slider.maxValue = [[filter2 objectForKey:@"maxValue"] floatValue];
    filter2Slider.floatValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"filter2Slider"] floatValue];
    NSDictionary * filter3 = [[filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", [[NSUserDefaults standardUserDefaults] objectForKey:@"filter3Popup"]]] firstObject];
    filter3Slider.minValue = [[filter3 objectForKey:@"minValue"] floatValue];
    filter3Slider.maxValue = [[filter3 objectForKey:@"maxValue"] floatValue];
    filter3Slider.floatValue = [[[NSUserDefaults standardUserDefaults] objectForKey:@"filter3Slider"] floatValue];
    
    
    shouldPrintButton.state = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shouldPrintButton"] boolValue];
    [printersPopup selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"printersPopup"]];
    [printSettingsPopup selectItemWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"printSettingsPopup"]];
    NSDictionary * printSetting = [[printPresets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", [[NSUserDefaults standardUserDefaults] objectForKey:@"printSettingsPopup"]]] firstObject];
    if (printSetting != nil)
    {
        printArgumentsField.stringValue = [printSetting objectForKey:@"option"];
        printSettingsNameField.stringValue = @"";
    }
    else
    {
        [printSettingsPopup selectItemWithTitle:@"---"];
        printArgumentsField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"printArgumentsField"];
        printSettingsNameField.stringValue = @"";
    }
    shouldNotifyButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldNotifyButton"];
    emailField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"emailField"];
    subjectField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"subjectField"];
    messageField.stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"messageField"];
    
    shouldCreateGifButton.state = [[NSUserDefaults standardUserDefaults] boolForKey:@"shouldCreateGifButton"];
    gifButton.hidden = !shouldCreateGifButton.state;
    [gifFPSButton selectItemWithTitle:[[NSUserDefaults standardUserDefaults] stringForKey:@"gifFPSButton"]];
    gifWidthField.integerValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"gifWidthField"];
    gifHeightField.integerValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"gifHeightField"];
    gifMinCountField.integerValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"gifMinCountField"];
    gifMaxCountField.integerValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"gifMaxCountField"];
    
}

-(IBAction)prefChange:(id)sender
{
    
    NSArray * filters = [[NSUserDefaults standardUserDefaults] objectForKey:@"filters"];
    NSArray * printPresets = [[NSUserDefaults standardUserDefaults] objectForKey:@"printPresets"];
    
    NSLog(@"pref change");
    if(sender == autoFullScreenButton)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[autoFullScreenButton state]] forKey:@"autoFullScreenButton"];
    }
    
#pragma mark working folder & archives
    /////// WORKING FOLDER & divers ///////
    else if(sender == workingFolderField)
    {
        
        [queue removePathFromQueue:todoFolder];
        
        [[NSUserDefaults standardUserDefaults] setObject:workingFolderField.stringValue forKey:@"workingFolderField"];
        [self checkOrCreateFileSystemeWhithWorkingFolder:workingFolderField.stringValue];
        
        [queue addPathToQueue:todoFolder];
        [self addImagesWithPaths:[self dateOrderedFiles:[self pathsOfFilesInDirectory:todoFolder]]];
        [imageBrowserView reloadData];
    }
    else if(sender == workingFolderChooseButton)
    {
        [queue removePathFromQueue:todoFolder];
        
        NSString * f = [self chooseFolder];
        [[NSUserDefaults standardUserDefaults] setObject:f forKey:@"workingFolderField"];
        workingFolderField.stringValue = f;
        [self checkOrCreateFileSystemeWhithWorkingFolder:f];
        
        [queue addPathToQueue:todoFolder];
        [self addImagesWithPaths:[self dateOrderedFiles:[self pathsOfFilesInDirectory:todoFolder]]];
        [imageBrowserView reloadData];
    }
    else if (sender == archiveOldButton)
    {
        [[NSUserDefaults standardUserDefaults] setBool:archiveOldButton.state forKey:@"archiveOldButton"];
    }
    else if (sender == archivePrintedButton)
    {
        [[NSUserDefaults standardUserDefaults] setBool:archivePrintedButton.state forKey:@"archivePrintedButton"];
    }
    else if (sender == archiveGifButton)
    {
        [[NSUserDefaults standardUserDefaults] setBool:archiveGifButton.state forKey:@"archiveGifButton"];
    }
    else if (sender == archiveExtensionsButton)
    {
        [[NSUserDefaults standardUserDefaults] setBool:archiveExtensionsButton.state forKey:@"archiveExtensionsButton"];
    }
    else if (sender == archiveExtensionsField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:archiveExtensionsField.stringValue forKey:@"archiveExtensionsField"];
    }
    else if (sender == useWebCamButton)
    {
        [[NSUserDefaults standardUserDefaults] setBool:useWebCamButton.state forKey:@"useWebCamButton"];
        takePhotoButton.hidden = !useWebCamButton.state;
    }
    
    
#pragma mark format
    /////// FORMAT ///////
    else if(sender == orientMatrix)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:orientMatrix.selectedRow] forKey:@"orientMatrix"];
    }
    else if(sender == docWidthField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:docWidthField.integerValue] forKey:@"docWidthField"];
    }
    else if(sender == docHeightField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:docHeightField.integerValue] forKey:@"docHeightField"];
    }
    else if(sender == shouldLayoutButton)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[shouldLayoutButton state]] forKey:@"shouldLayoutButton"];
    }

    
#pragma mark back
    /////// BACK ///////
    else if(sender == chooseVerticalBackButton)
    {
        NSString * f = [self chooseFile];
        [[NSUserDefaults standardUserDefaults] setObject:f forKey:@"verticalBackField"];
        verticalBackField.stringValue = f;
    }
    else if(sender == verticalBackField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:verticalBackField.stringValue forKey:@"verticalBackField"];
    }
    else if(sender == chooseHorizontalBackButton)
    {
        NSString * f = [self chooseFile];
        [[NSUserDefaults standardUserDefaults] setObject:f forKey:@"horizontalBackField"];
        horizontalBackField.stringValue = f;
    }
    else if(sender == horizontalBackField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:horizontalBackField.stringValue forKey:@"horizontalBackField"];
    }
    
#pragma mark front
    /////// FRONT ///////
    else if(sender == frontCompositingPopup)
    {
        [[NSUserDefaults standardUserDefaults] setObject:frontCompositingPopup.titleOfSelectedItem forKey:@"frontCompositingPopup"];
    }
    else if(sender == chooseVerticalFrontButton)
    {
        NSString * f = [self chooseFile];
        [[NSUserDefaults standardUserDefaults] setObject:f forKey:@"verticalFrontField"];
        verticalFrontField.stringValue = f;
    }
    else if(sender == verticalFrontField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:verticalFrontField.stringValue forKey:@"verticalFrontField"];
    }
    else if(sender == chooseHorizontalFrontButton)
    {
        NSString * f = [self chooseFile];
        [[NSUserDefaults standardUserDefaults] setObject:f forKey:@"horizontalFrontField"];
        horizontalFrontField.stringValue = f;
    }
    else if(sender == horizontalFrontField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:horizontalFrontField.stringValue forKey:@"horizontalFrontField"];
    }
    
    else if (sender == deleteBackButton)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"verticalBackField"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"horizontalBackField"];
        verticalBackField.stringValue = @"";
        horizontalBackField.stringValue = @"";
    }
    else if (sender == deleteFrontButton)
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"verticalFrontField"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"horizontalFrontField"];
        verticalFrontField.stringValue = @"";
        horizontalFrontField.stringValue = @"";
    }
    
#pragma mark rects
    /////// RECTS ///////
    else if(sender == verticalX)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:verticalX.integerValue ] forKey:@"verticalX"];
    }
    else if(sender == verticalY)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:verticalY.integerValue ] forKey:@"verticalY"];
    }
    else if(sender == verticalH)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:verticalH.integerValue ] forKey:@"verticalH"];
    }
    else if(sender == verticalW)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:verticalW.integerValue ] forKey:@"verticalW"];
    }
    else if(sender == horizontalX)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:horizontalX.integerValue] forKey:@"horizontalX"];
    }
    else if(sender == horizontalY)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:horizontalY.integerValue] forKey:@"horizontalY"];
    }
    else if(sender == horizontalH)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:horizontalH.integerValue] forKey:@"horizontalH"];
    }
    else if(sender == horizontalW)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:horizontalW.integerValue] forKey:@"horizontalW"];
    }
    
#pragma mark print
    /////// PRINT ///////////
    else if(sender == shouldPrintButton)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:[shouldPrintButton state]] forKey:@"shouldPrintButton"];
    }
    else if(sender == printersPopup)
    {
        [[NSUserDefaults standardUserDefaults] setObject:printersPopup.titleOfSelectedItem forKey:@"printersPopup"];
    }
    else if(sender == printSettingsPopup)
    {
        [[NSUserDefaults standardUserDefaults] setObject:printSettingsPopup.titleOfSelectedItem forKey:@"printSettingsPopup"];
        NSDictionary * printSetting = [[printPresets filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", printSettingsPopup.titleOfSelectedItem]] firstObject];
        if (printSetting != nil)
        {
            printArgumentsField.stringValue = [printSetting objectForKey:@"option"];
            printSettingsNameField.stringValue = @"";
        }
        else
        {
            [printSettingsPopup selectItemWithTitle:@"---"];
            printArgumentsField.stringValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"printArgumentsField"];
            printSettingsNameField.stringValue = @"";
        }
    }
    else if(sender == printArgumentsField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:printArgumentsField.stringValue forKey:@"printArgumentsField"];
        [[NSUserDefaults standardUserDefaults] setObject:@"---" forKey:@"printSettingsPopup"];
        if([printSettingsPopup itemWithTitle:@"---"] == nil)
        {
            [printSettingsPopup addItemWithTitle:@"---"];
            [printSettingsPopup selectItemWithTitle:@"---"];
        }
        else
        {
            [printSettingsPopup selectItemWithTitle:@"---"];
        }
    }
    else if(sender == testPrintButton)
    {
        //
    }
    else if(sender == savePrintSettingButton)
    {
        if (printSettingsNameField.stringValue.length > 0)
        {
            NSDictionary * dd = [NSDictionary dictionaryWithObjectsAndKeys:printArgumentsField.stringValue, @"option",printSettingsNameField.stringValue, @"name", nil];
            NSMutableArray * tmp = [NSMutableArray array];
            for (NSDictionary * ddd in printPresets)
            {
                if ([[ddd objectForKey:@"name"] isEqualToString:printSettingsNameField.stringValue])
                {
                    [tmp addObject:dd];
                }
                else
                {
                    [tmp addObject:ddd];
                }
            }
            if (![tmp containsObject:dd])
            {
                [printSettingsPopup addItemWithTitle:[dd objectForKey:@"name"]];
                [tmp addObject:dd];
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:tmp] forKey:@"printPresets"];
        }
        else
        {
            NSAlert * alert = [[NSAlert alloc] init];
            [alert setInformativeText:@"Merci."];
            [alert setMessageText:@"Veuillez entrer un nom pour ce preset."];
            [alert runModal];
        }
    }
    
#pragma mark filters
    /////// FILTERS ///////////
    else if(sender == filter1Popup)
    {
        [[NSUserDefaults standardUserDefaults] setObject:filter1Popup.titleOfSelectedItem forKey:@"filter1Popup"];
        NSDictionary * filter = [[filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", [[NSUserDefaults standardUserDefaults] objectForKey:@"filter1Popup"]]] firstObject];
        if (filter !=nil)
        {
            filter1Slider.minValue = [[filter objectForKey:@"minValue"] floatValue];
            filter1Slider.maxValue = [[filter objectForKey:@"maxValue"] floatValue];
            filter1Slider.floatValue = [[filter objectForKey:@"defaultValue"] floatValue];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[[filter objectForKey:@"defaultValue"] floatValue]] forKey:@"filter1Slider"];
        }
    }
    else if(sender == filter1Slider)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:filter1Slider.floatValue] forKey:@"filter1Slider"];
    }
    else if(sender == filter2Popup)
    {
        [[NSUserDefaults standardUserDefaults] setObject:filter2Popup.titleOfSelectedItem forKey:@"filter2Popup"];
        NSDictionary * filter = [[filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", [[NSUserDefaults standardUserDefaults] objectForKey:@"filter2Popup"]]] firstObject];
        filter2Slider.minValue = [[filter objectForKey:@"minValue"] floatValue];
        filter2Slider.maxValue = [[filter objectForKey:@"maxValue"] floatValue];
        filter2Slider.floatValue = [[filter objectForKey:@"defaultValue"] floatValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[[filter objectForKey:@"defaultValue"] floatValue]] forKey:@"filter2Slider"];
    }
    else if(sender == filter2Slider)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:filter2Slider.floatValue] forKey:@"filter2Slider"];
    }
    else if(sender == filter3Popup)
    {
        [[NSUserDefaults standardUserDefaults] setObject:filter3Popup.titleOfSelectedItem forKey:@"filter3Popup"];
        NSDictionary * filter = [[filters filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", [[NSUserDefaults standardUserDefaults] objectForKey:@"filter3Popup"]]] firstObject];
        filter3Slider.minValue = [[filter objectForKey:@"minValue"] floatValue];
        filter3Slider.maxValue = [[filter objectForKey:@"maxValue"] floatValue];
        filter3Slider.floatValue = [[filter objectForKey:@"defaultValue"] floatValue];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:[[filter objectForKey:@"defaultValue"] floatValue]] forKey:@"filter3Slider"];
    }
    else if(sender == filter3Slider)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:filter3Slider.floatValue] forKey:@"filter3Slider"];
    }
    else if(sender == filterEditorButton)
    {
        if (bunFilter == nil)
        {
            bunFilter = [[BUNFilter alloc] init];
            NSArray * tmpArr;
            [[NSBundle mainBundle] loadNibNamed:@"BUNFilter" owner:bunFilter topLevelObjects:&tmpArr];
            editorArray = tmpArr;
            [bunFilter configure];
            
            
        }
        [bunFilter.window display];
        [bunFilter.window makeKeyAndOrderFront:nil];
        
    }
    
    
#pragma mark emails
    /////// NOTIFICATIONS ///////////
    else if(sender == shouldNotifyButton)
    {
        [[NSUserDefaults standardUserDefaults] setBool:shouldNotifyButton.state forKey:@"shouldNotifyButton"];
    }
    else if(sender == emailField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:emailField.stringValue forKey:@"emailField"];
    }
    else if(sender == subjectField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:subjectField.stringValue forKey:@"subjectField"];
    }
    else if(sender == messageField)
    {
        [[NSUserDefaults standardUserDefaults] setObject:messageField.stringValue forKey:@"messageField"];
    }
    
    
#pragma mark gif
    /////// GIF ///////////
    else if(sender == shouldCreateGifButton)
    {
        [[NSUserDefaults standardUserDefaults] setBool:shouldCreateGifButton.state forKey:@"shouldCreateGifButton"];
        gifButton.hidden = !shouldCreateGifButton.state;
    }
    else if(sender == gifFPSButton)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:[[gifFPSButton titleOfSelectedItem] integerValue] forKey:@"gifFPSButton"];
    }
    else if(sender == gifMinCountField)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:gifMinCountField.integerValue forKey:@"gifMinCountField"];
    }
    else if(sender == gifMaxCountField)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:gifMaxCountField.integerValue forKey:@"gifMaxCountField"];
    }
    else if(sender == gifHeightField)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:gifHeightField.integerValue forKey:@"gifHeightField"];
    }
    else if(sender == gifWidthField)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:gifWidthField.integerValue forKey:@"gifWidthField"];
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)chooseFile
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:NO];
    [panel setTitle:@"Choisissez une image"];
    
    if ([panel runModal] == NSModalResponseOK)
    {
        NSURL * url = [panel.URLs firstObject];
        return url.path;
    }
    return nil;
}
-(NSString*)chooseFolder
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanCreateDirectories:YES];
    [panel setTitle:@"Choisissez un dossier"];
    
    if ([panel runModal] == NSModalResponseOK)
    {
        NSURL * url = [panel.URLs firstObject];
        return url.path;
    }
    return nil;
}
-(NSArray*)getPrinters
{
    NSTask * list = [[NSTask alloc] init];
    [list setLaunchPath:@"/usr/bin/lpstat"];
    [list setArguments:[NSArray arrayWithObject:@"-p"]];
    
    NSPipe * out = [NSPipe pipe];
    [list setStandardOutput:out];
    
    [list launch];
    [list waitUntilExit];
    
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    
    NSMutableArray * a = [NSMutableArray array];
    NSArray *lines = [stringRead componentsSeparatedByString:@"\n"];
    for (NSString * line in lines)
    {
        if ([[line componentsSeparatedByString:@" "] count] >=2)
        {
            [a addObject:[[line componentsSeparatedByString:@" "] objectAtIndex:1]];
        }
    }
    return [NSArray arrayWithArray:a];
}

#pragma mark FILE MANAGEMENT
/////////////////////////////////////////////
///////        FILE MANAGEMENT         //////
/////////////////////////////////////////////

-(void) watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm forPath: (NSString*)fpath;
{
    [self addImagesWithPaths:[self dateOrderedFiles:[self pathsOfFilesInDirectory:todoFolder]]];
    [imageBrowserView reloadData];
}

-(void)checkOrCreateFileSystemeWhithWorkingFolder:(NSString*)wf
{
    [self testFolder:wf];
    
    todoFolder = [wf stringByAppendingPathComponent:@"todo"];
    doneFolder = [wf stringByAppendingPathComponent:@"done"];
    archivesFolder = [wf stringByAppendingPathComponent:@"archives"];
    
    [self testFolder:archivesFolder];
    [self testFolder:todoFolder];
    [self testFolder:doneFolder];
}

- (void)addImagesWithPaths:(NSArray *)paths
{
    [importedFiles removeAllObjects];
    
    NSInteger i, n;
    
    n = [paths count];
    for ( i= 0; i < n; i++)
    {
        imageItem *p;
        
        p = [[imageItem alloc] init];
        [p setPath:[paths objectAtIndex:i]];
        [importedFiles addObject:p];
        
    }
    [self updateDatasource];
    //[self performSelectorOnMainThread:@selector(updateDatasource) withObject:nil waitUntilDone:YES];
}


- (void)updateDatasource
{
    NSMutableArray * tmpAdd = [NSMutableArray array];
    NSMutableArray * tmpRemove = [NSMutableArray array];
    
    for (imageItem * im in importedFiles)
    {
        if (files.count == 0)
        {
            [tmpAdd addObject:im];
        }
        else
        {
            BOOL keep = YES;
            for (imageItem * iimm in files)
            {
                if ([im.imageUID isEqualToString:iimm.imageUID])
                {
                    keep = NO;
                }
            }
            if (keep)
            {
                [tmpAdd addObject:im];
            }
        }
    }
    
    [files addObjectsFromArray:tmpAdd];
    
    for (imageItem * im in files)
    {
        BOOL keep = NO;
        for (imageItem * iimm in importedFiles)
        {
            if ([im.imageUID isEqualToString:iimm.imageUID])
            {
                keep = YES;
                break;
            }
        }
        if (keep == NO)
        {
            [tmpRemove addObject:im];
        }
    }
    
    [files removeObjectsInArray:tmpRemove];
    
    if (tmpRemove.count)
    {
        if (files.count > 0)
        {
            lastSelected = MAX(0, lastSelected-1);
            [imageBrowserView setSelectionIndexes:[NSIndexSet indexSetWithIndex:lastSelected] byExtendingSelection:NO];
        }
        else
        {
            [imageBrowserView setSelectionIndexes:nil byExtendingSelection:NO];
            lastSelected = -1;
        }
    }
    
    if (tmpRemove.count==0  && tmpAdd.count==0)
    {
        NSLog(@"Nothing to add or remove");
    }
    
}


-(void)testFolder:(NSString*)folderPath
{
    NSError * err;
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if (err != nil)
    {
        NSLog(@"ERROR with folders : %@", err.description);
        return;
    }
    
    if (!exists || (exists && !isDir))
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&err];
        if (err != nil)
        {
            NSLog(@"Impossible de créer le dossier : %@", folderPath);
            return;
        }
    }
}


-(NSArray*)pathsOfFilesInDirectory:(NSString*)dir
{
    NSError * err;
    NSArray * fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&err];
    NSMutableArray * z = [NSMutableArray array];
    for (NSString * s in fileNames)
    {
        NSString * d = [dir stringByAppendingPathComponent:s];
        [z addObject:d];
    }
    return [NSArray arrayWithArray:z];
}


-(NSArray*)dateOrderedFiles:(NSArray*)f
{
    NSArray*  orderedFiles;
    orderedFiles = [f sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                    {
                        NSDictionary* first_properties  = [[NSFileManager defaultManager] attributesOfItemAtPath:obj1 error:nil];
                        NSDate*       first             = [first_properties  objectForKey:NSFileCreationDate];
                        NSDictionary* second_properties = [[NSFileManager defaultManager] attributesOfItemAtPath:obj2 error:nil];
                        NSDate*       second            = [second_properties objectForKey:NSFileCreationDate];
                        return [first compare:second];
                    }];
    
    return [self reverseArray:[self removeDSStoreInArray:orderedFiles]];
}

- (NSArray *)reverseArray:(NSArray*)arr
{
    NSDateComponents *componentsToday = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger todaysDay = componentsToday.day;
    NSInteger todaysMonth = componentsToday.month;
    NSInteger todaysYear = componentsToday.year;
    
    NSError * err;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[arr count]];
    NSEnumerator *enumerator = [arr reverseObjectEnumerator];
    for (id element in enumerator)
    {
        NSDictionary * dic = [[NSFileManager defaultManager] attributesOfItemAtPath:element error:&err];
        NSDate*fileDate = [dic objectForKey:NSFileCreationDate];
        if (fileDate == nil)
        {
            fileDate = [NSDate date];
        }
        NSDateComponents *componentsFile = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:fileDate];
        
        NSInteger day = componentsFile.day;
        NSInteger month = componentsFile.month;
        NSInteger year = componentsFile.year;
        
        if ((day == todaysDay && month == todaysMonth && year == todaysYear) &&
            ([[element pathExtension] isEqualToString:@"jpg"] ||
             [[element pathExtension] isEqualToString:@"JPG"] ||
             [[element pathExtension] isEqualToString:@"png"] ||
             [[element pathExtension] isEqualToString:@"PNG"] ||
             [[element pathExtension] isEqualToString:@"gif"] ||
             [[element pathExtension] isEqualToString:@"GIF"] ||
             [[element pathExtension] isEqualToString:@"mov"] ||
             [[element pathExtension] isEqualToString:@"MOV"]))
        {
            [array addObject:element];
        }
        else
        {
            NSString * dayFolder = [NSString stringWithFormat:@"%@/%.2ld-%.2ld-%.4ld", archivesFolder, day, month, year];
            [self testFolder:dayFolder];
            
            NSString * destinationPath = [dayFolder stringByAppendingPathComponent:[element lastPathComponent]];
            [[NSFileManager defaultManager] moveItemAtPath:element toPath:destinationPath error:&err];
        }
    }
    return array;
}



-(NSArray*)removeDSStoreInArray:(NSArray*)arr
{
    NSMutableArray * ar = [NSMutableArray array];
    for (NSString *s in arr)
    {
        if (![s isEqual:@".DS_Store"])
        {
            [ar addObject: s];
        }
    }
    return [NSArray arrayWithArray:ar];
}


#pragma mark IBACTIONS
/////////////////////////////////////////////
///////           IBACTIONS           ///////
/////////////////////////////////////////////


-(IBAction)next:(NSButton*)btn
{
/*
    [imageBrowserView setHidden:YES];
    keyboard = [[BUNKeyboard alloc] initWithFrame:NSMakeRect([self.window.contentView frame].size.width/2 - 880/2,
                                                             [self.window.contentView frame].size.height/2 - 320/2,
                                                             880,
                                                             400)];
    [self.window.contentView addSubview:keyboard];
    
    [keyboard configure];
    [keyboard setNeedsDisplay:YES];
*/
    

    if (files.count)
    {
        NSInteger d = ([[imageBrowserView selectionIndexes] firstIndex] + 1)%files.count;
        lastSelected = (int)d;
        [imageBrowserView setSelectionIndexes:[NSIndexSet indexSetWithIndex:d] byExtendingSelection:NO];
        [imageBrowserView scrollIndexToVisible:d];
    }
}


-(IBAction)prev:(NSButton*)btn
{
    if (files.count)
    {
        NSInteger d = ([[imageBrowserView selectionIndexes] firstIndex] +files.count- 1)%files.count;
        lastSelected = (int)d;
        [imageBrowserView setSelectionIndexes:[NSIndexSet indexSetWithIndex:d] byExtendingSelection:NO];
        [imageBrowserView scrollIndexToVisible:d];
    }
}


-(IBAction)showViewer:(id)sender
{
    [self.window display];
    [self.window makeKeyAndOrderFront:nil];
}

-(IBAction)toggleFullScreen:(id)sender
{
    NSLog(@"toggleFullScreen");
    NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:NO], NSFullScreenModeAllScreens,
                          [NSNumber numberWithInt:0], NSFullScreenModeWindowLevel,
                          [NSNumber numberWithInt:NSApplicationPresentationHideDock | NSApplicationPresentationHideMenuBar], NSFullScreenModeApplicationPresentationOptions,nil];
    
    if ([self.window.contentView isInFullScreenMode])
    {
        [self.window.contentView exitFullScreenModeWithOptions:opts];
        [self.window setStyleMask:NSTitledWindowMask  | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask];
        [self.window setFrame:NSInsetRect(self.window.frame, -2, -2)  display:YES];
    }
    else
    {
        self.window.styleMask = NSBorderlessWindowMask;
        [self.window.contentView enterFullScreenMode:[NSScreen mainScreen] withOptions:opts];
    }
}

-(IBAction)zoom:(NSSlider*)sender
{
    [imageBrowserView setZoomValue:sender.floatValue];
}

-(IBAction)photo:(NSButton*)btn
{
    NSString * date = [NSString stringWithFormat:@"%@", [NSDate date]];
    date = [date stringByReplacingOccurrencesOfString:@"+" withString:@""];
    date = [date stringByReplacingOccurrencesOfString:@" " withString:@""];
    date = [date stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString * newFile = [NSString stringWithFormat:@"%@/IMG_%@.jpg", todoFolder, date];
    [cam takePictureAndSaveAt:newFile];
}

-(IBAction)makeGif:(NSButton*)btn
{
    NSMutableArray *arr = [NSMutableArray array];

    for (imageItem * item in [files objectsAtIndexes:[imageBrowserView selectionIndexes]])
    {
        if (![[[[item imageUID] pathExtension] lowercaseString] isEqualToString:@"gif"] && ![[[[item imageUID] pathExtension] lowercaseString] isEqualToString:@"mov"])
        {
            [arr addObject:[item imageUID]];
        }
    }
    if (arr.count>=[[NSUserDefaults standardUserDefaults] integerForKey:@"gifMinCountField"] &&
        arr.count<=[[NSUserDefaults standardUserDefaults] integerForKey:@"gifMaxCountField"])
    {
        NSString* gifPath = [todoFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.gif", [NSDate date]]];
        [self makeAnimatedGIFWithImagePaths:[NSArray arrayWithArray:arr] size:NSMakeSize([[NSUserDefaults standardUserDefaults] floatForKey:@"gifWidthField"],
                                                                                         [[NSUserDefaults standardUserDefaults] floatForKey:@"gifHeightField"]) saveGifAtPath:gifPath];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldNotifyButton"])
        {
            [self performSelectorInBackground:@selector(sendEmailWithFile:) withObject:gifPath];
        }
        
    }
}

-(IBAction)openPrefs:(id)sender
{
    NSLog(@"openpref");
    [preferencesWindow display];
    [preferencesWindow makeKeyAndOrderFront:nil];
    [self loadPreset];
}

-(IBAction)saveAndPrint:(NSButton*)btn
{
    // lpr -P  Canon_CP910 -o media=Postcard\(4x6in\)_Type2.FullBleed /Users/benelux/Documents/A_D_K_ALL/Allée_du_kaai_photo/Portes_ouvertes_2014_10_29/Bruts/IMG_7905.JPG
    
    for (int i = 0; i<[[imageBrowserView selectionIndexes] count]; i++)
    {
        selectedImage = [[[files objectsAtIndexes:[imageBrowserView selectionIndexes]] objectAtIndex:i] imageUID];
        if (selectedImage != nil && !([[[selectedImage pathExtension] lowercaseString] isEqualToString:@"gif"] || [[[selectedImage pathExtension] lowercaseString] isEqualToString:@"mov"]))
        {
            NSError * err;
            NSString * destinationPath = [doneFolder stringByAppendingPathComponent:[selectedImage lastPathComponent]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:destinationPath])
            {
                [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:&err];
            }
            
            [[NSFileManager defaultManager] moveItemAtPath:selectedImage
                                                    toPath:destinationPath error:&err];
            
            if (err) return;
            
            [self performSelectorInBackground:@selector(processAndPrint:) withObject:destinationPath];
            
        }
    }
    
}




#pragma mark DATASOURCE & DELEGATE METHODS
/////////////////////////////////////////////
/////// DATASOURCE & DELEGATE METHODS ///////
/////////////////////////////////////////////

-(NSUInteger)imageBrowser:(IKImageBrowserView *)aBrowser writeItemsAtIndexes:(NSIndexSet *)itemIndexes toPasteboard:(NSPasteboard*)pasteboard
{
    return 0;
}

-(NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)aBrowser
{
    return files.count;
}

-(id)imageBrowser:(IKImageBrowserView *)aBrowser itemAtIndex:(NSUInteger)index;
{
    return  [files objectAtIndex:index];
}

-(void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{
    if ([[imageBrowserView selectionIndexes] count])
    {
        lastSelected = (int)[[imageBrowserView selectionIndexes] firstIndex];
        selectedImage = [[files objectAtIndex:[[imageBrowserView selectionIndexes] firstIndex]] imageUID];
    }
//    else
//    {
//        selectedImage = nil;
//        [imageBrowserView setSelectionIndexes:nil byExtendingSelection:NO];
//    }
}

-(void)imageBrowser:(IKImageBrowserView *) aBrowser cellWasDoubleClickedAtIndex:(NSUInteger) index
{
    [zoomSlider setFloatValue:zoomSlider.floatValue == 1 ? 0.3 : 1];
    [self zoom:zoomSlider];
}



#pragma mark GRAPHIC UTILITIES
/////////////////////////////////////////////
///////         GRAPHICS UTILS        ///////
/////////////////////////////////////////////


-(void)processAndPrint:(NSString*)destinationPath
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldLayoutButton"])
    {
        CIImage * image = [[CIImage alloc] initWithData:[[[NSImage alloc] initWithContentsOfFile:destinationPath] TIFFRepresentation]];
        NSRect imgExtent = image.extent;
        
        BOOL vertical = NO;
        if (imgExtent.size.height > imgExtent.size.width || [[NSUserDefaults standardUserDefaults] integerForKey:@"orientMatrix"] == 0) //image verticale
        {
            vertical = YES;
        }
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"orientMatrix"] == 1)
        {
            vertical = NO;
        }
        
        CIImage * front;
        CIImage * back;
        if (vertical)
        {
            front = [[CIImage alloc] initWithData:[[[NSImage alloc] initWithContentsOfFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"verticalFrontField"]] TIFFRepresentation]];
            back = [[CIImage alloc] initWithData:[[[NSImage alloc] initWithContentsOfFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"verticalBackField"]] TIFFRepresentation]];
            if (back == nil)
            {
                back = [[CIImage alloc] initWithColor:[CIColor colorWithRed:1 green:1 blue:1]];
                NSRect r = NSMakeRect(0, 0, [[NSUserDefaults standardUserDefaults] floatForKey:@"docHeightField"], [[NSUserDefaults standardUserDefaults] floatForKey:@"docWidthField"]);
                back = [back imageByCroppingToRect:r];
            }
        }
        else
        {
            front = [[CIImage alloc] initWithData:[[[NSImage alloc] initWithContentsOfFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalFrontField"]] TIFFRepresentation]];
            back = [[CIImage alloc] initWithData:[[[NSImage alloc] initWithContentsOfFile:[[NSUserDefaults standardUserDefaults] objectForKey:@"horizontalBackField"]] TIFFRepresentation]];
            if (back == nil)
            {
                back = [[CIImage alloc] initWithColor:[CIColor colorWithRed:1 green:1 blue:1]];
                NSRect r = NSMakeRect(0, 0, [[NSUserDefaults standardUserDefaults] integerForKey:@"docWidthField"], [[NSUserDefaults standardUserDefaults] integerForKey:@"docHeightField"]);
                back = [back imageByCroppingToRect:r];
            }
        }
        
        NSRect backExtent = back.extent;
        
        int wim = (int)(vertical ? [[NSUserDefaults standardUserDefaults] integerForKey:@"verticalW"] : [[NSUserDefaults standardUserDefaults] integerForKey:@"horizontalW"]);
        int him = (int)(vertical ? [[NSUserDefaults standardUserDefaults] integerForKey:@"verticalH"] : [[NSUserDefaults standardUserDefaults] integerForKey:@"horizontalH"]);
        int xim = (int)(vertical ? [[NSUserDefaults standardUserDefaults] integerForKey:@"verticalX"] : [[NSUserDefaults standardUserDefaults] integerForKey:@"horizontalX"]);
        int yim = (int)(vertical ? [[NSUserDefaults standardUserDefaults] integerForKey:@"verticalY"] : [[NSUserDefaults standardUserDefaults] integerForKey:@"horizontalY"]);
        
        image = [AppDelegate fillCIImage:image
                                 toWidth:wim
                               andHeight:him];
        
        image = [self filterImage:image withName:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter1Popup"] andValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"filter1Slider"] floatValue]];
        image = [self filterImage:image withName:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter2Popup"] andValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"filter2Slider"] floatValue]];
        image = [self filterImage:image withName:[[NSUserDefaults standardUserDefaults] objectForKey:@"filter3Popup"] andValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"filter3Slider"] floatValue]];
                
        NSAffineTransform *tr = [NSAffineTransform transform];
        [tr translateXBy:xim yBy:backExtent.size.height-(yim+him)];
        CIFilter * tra = [CIFilter filterWithName:@"CIAffineTransform"];
        [tra setValue:tr forKey:@"inputTransform"];
        [tra setValue:image forKey:@"inputImage"];
        CIImage * filledImage = [tra valueForKey:@"outputImage"];
        
        
        

        CIFilter * compo = [CIFilter filterWithName:@"CISourceOverCompositing"];
        [compo setValue:filledImage forKey:@"inputImage"];
        [compo setValue:back forKey:@"inputBackgroundImage"];
        back = [compo valueForKey:@"outputImage"];
        
        
        if (front != nil)
        {
            NSString * composition;
            if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"frontCompositingPopup"] isEqualToString:@"Addition"])
            {
                composition = @"CIAdditionCompositing";
            }
            else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"frontCompositingPopup"] isEqualToString:@"Produit"])
            {
                composition = @"CIMultiplyCompositing";
            }
            else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"frontCompositingPopup"] isEqualToString:@"Alpha"])
            {
                composition = @"CISourceOverCompositing";
            }
            else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"frontCompositingPopup"] isEqualToString:@"Incrustation"])
            {
                composition = @"CIOverlayBlendMode";
            }
            else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"frontCompositingPopup"] isEqualToString:@"Lumière douce"])
            {
                composition = @"CISoftLightBlendMode";
            }
            else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"frontCompositingPopup"] isEqualToString:@"Screen"])
            {
                composition = @"CIScreenBlendMode";
            }
            
            compo = [CIFilter filterWithName:composition];
            [compo setValue:front forKey:@"inputImage"];
            [compo setValue:back forKey:@"inputBackgroundImage"];
            back = [compo valueForKey:@"outputImage"];
        }
        
        back = [back imageByCroppingToRect:backExtent];
        
        
        NSImage * im = [[NSImage alloc]initWithSize:backExtent.size];
        [im lockFocus];
        [back drawAtPoint:NSZeroPoint fromRect:backExtent operation:NSCompositeSourceOver fraction:1.0];
        [im unlockFocus];
        
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:[im TIFFRepresentation]];
        NSData *JPGData = [rep representationUsingType:NSJPEGFileType
                                            properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                                                   forKey:NSImageCompressionFactor]];
        [[NSFileManager defaultManager] createFileAtPath:destinationPath
                                                contents:JPGData
                                              attributes:nil];
    }
    
    
    [self sendEmailWithFile:destinationPath];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shouldPrintButton"])
    {
        NSTask*task = [[NSTask alloc] init];
        NSPipe * outPipe = [NSPipe pipe];
        [task setStandardOutput:outPipe];
        [task setLaunchPath:@"/usr/bin/lpr"];
        
        NSMutableArray * margs = [NSMutableArray array];
        [margs addObject:@"-P"];
        [margs addObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"printersPopup"]];
        NSArray * printOptions = [[printArgumentsField stringValue] componentsSeparatedByString:@" "];
        for (NSString * printOption in printOptions)
        {
            if (printOption.length > 0)
            {
                [margs addObject:printOption];
            }
            
        }
        [margs addObject:destinationPath];
        //NSLog(@"PRINT COMMAND ARGS = \n%@", margs);
        [task setArguments:[NSArray arrayWithArray:margs]];
        task.terminationHandler = ^(NSTask *aTask)
        {
            NSLog(@"printed");
            
        };
        [task launch];
    }
}

-(void)initSpecialFilter
{
    if (bunFilter == nil)
    {
        bunFilter = [[BUNFilter alloc] init];
        NSArray * tmpArr;
        [[NSBundle mainBundle] loadNibNamed:@"BUNFilter" owner:bunFilter topLevelObjects:&tmpArr];
        editorArray = tmpArr;
        [bunFilter configure];
        [bunFilter.window close];
    }
}

-(CIImage*)filterImage:(CIImage*)image withName:(NSString*)name andValue:(float)val
{
    if ([name isEqualToString:@"rien"])
    {
        return image;
    }
    else if ([name isEqualToString:@"Gamma"])
    {
        CIFilter * filter = [CIFilter filterWithName:@"CIGammaAdjust"];
        [filter setValue:image forKey:@"inputImage"];
        [filter setValue:[NSNumber numberWithFloat:val] forKey:@"inputPower"];
        CIImage * result = [filter valueForKey:@"outputImage"];
        return result;
    }
    else if ([name isEqualToString:@"Exposition"])
    {
        CIFilter * filter = [CIFilter filterWithName:@"CIExposureAdjust"];
        [filter setValue:image forKey:@"inputImage"];
        [filter setValue:[NSNumber numberWithFloat:val] forKey:@"inputEV"];
        CIImage * result = [filter valueForKey:@"outputImage"];
        return result;
    }
    else if ([name isEqualToString:@"Saturation"])
    {
        CIFilter * filter = [CIFilter filterWithName:@"CIColorControls"];
        [filter setValue:image forKey:@"inputImage"];
        [filter setValue:[NSNumber numberWithFloat:val] forKey:@"inputSaturation"];
        [filter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputBrightness"];
        [filter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputContrast"];
        
        CIImage * result = [filter valueForKey:@"outputImage"];
        return result;
    }
    else if ([name isEqualToString:@"Netteté"])
    {
        CIFilter * filter = [CIFilter filterWithName:@"CISharpenLuminance"];
        [filter setValue:image forKey:@"inputImage"];
        [filter setValue:[NSNumber numberWithFloat:val] forKey:@"inputSharpness"];
        CIImage * result = [filter valueForKey:@"outputImage"];
        return result;
    }
    else if ([name isEqualToString:@"Vibrance"])
    {
        CIFilter * filter = [CIFilter filterWithName:@"CIVibrance"];
        [filter setValue:image forKey:@"inputImage"];
        [filter setValue:[NSNumber numberWithFloat:val] forKey:@"inputAmount"];
        CIImage * result = [filter valueForKey:@"outputImage"];
        return result;
    }
    else
    {
        if (bunFilter == nil)
        {
            [self performSelectorOnMainThread:@selector(initSpecialFilter) withObject:nil waitUntilDone:YES];
        }
        CIImage * result = [bunFilter processCIImage:image withPreset:name];
        return result;
    }
    return image;
}


+(CIImage*)fillCIImage:(CIImage*)img toWidth:(float)fitPixW andHeight:(float)fitPixH
{
    //TAILLE DE L'IMAGE ORIGINALE
    float imgW = [img extent].size.width;
    float imgH = [img extent].size.height;
    
    float magnificationFactor = 1;
    BOOL imageIsThickerThanFreeRect = (imgH/imgW) > (fitPixH/fitPixW);
    
    if (!imageIsThickerThanFreeRect)
    {
        magnificationFactor = fitPixH/imgH;
    }
    else
    {
        magnificationFactor = fitPixW/imgW;
    }
    
    float tmpW = floor(magnificationFactor * imgW);
    float tmpH = floor(magnificationFactor * imgH);
    
    //AFFINE CLAMP
    CIFilter * filter = [CIFilter filterWithName:@"CIAffineClamp"];
    [filter setValue:[NSAffineTransform transform] forKey:@"inputTransform"];
    [filter setValue:img forKey:@"inputImage"];
    img = [filter valueForKey:@"outputImage"];
    
    //RESCALE
    filter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
    [filter setValue:img forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:magnificationFactor] forKey:@"inputScale"];
    [filter setValue:[NSNumber numberWithFloat:1.000] forKey:@"inputAspectRatio"];
    img = [filter valueForKey:@"outputImage"];
    
    float cropX = floor((tmpW - fitPixW) / 2) ;
    float cropY = floor((tmpH - fitPixH) / 2) ;
    
    CIVector *cropRect =[CIVector vectorWithX:cropX Y:cropY Z:(fitPixW) W:(fitPixH)];
    filter = [CIFilter filterWithName:@"CICrop"];
    [filter setValue:img forKey:@"inputImage"];
    [filter setValue:cropRect forKey:@"inputRectangle"];
    img = [filter valueForKey:@"outputImage"];
    
    NSAffineTransform * translation = [NSAffineTransform transform];
    [translation translateXBy:-cropX yBy:-cropY];
    filter = [CIFilter filterWithName:@"CIAffineTransform"];
    [filter setValue:img forKey:@"inputImage"];
    [filter setValue:translation forKey:@"inputTransform"];
    img = [filter valueForKey:@"outputImage"];
    return img;
}


-(void)makeAnimatedGIFWithImagePaths:(NSArray*)jpegs size:(NSSize)size saveGifAtPath:(NSString*)filePath
{
    int count = 0;
    
    NSLog(@"Create GIF data container at path = %@", filePath);
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:filePath],
                                                                        kUTTypeGIF,
                                                                        jpegs.count,
                                                                        NULL);
    
    
    NSMutableDictionary *gifPropsDict = [[NSMutableDictionary alloc] init];
    [gifPropsDict setObject:(NSString*)kCGImagePropertyColorModelRGB forKey:(NSString*)kCGImagePropertyColorModel];
    [gifPropsDict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    [gifPropsDict setObject:[NSNumber numberWithInt:0] forKey:(NSString*)kCGImagePropertyGIFLoopCount];
    
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:gifPropsDict forKey:(NSString*)kCGImagePropertyGIFDictionary];
    
    float frameDuration = 1 / [[NSUserDefaults standardUserDefaults] floatForKey:@"gifFPSButton"];
    
    for (NSString * file in jpegs)
    {
        NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:frameDuration] forKey:(NSString*)kCGImagePropertyGIFDelayTime]
                                                                    forKey:(NSString*)kCGImagePropertyGIFDictionary];
        
        NSLog(@"Add image #%d to GIF", count);
        
        NSImage * img = [[NSImage alloc] initWithContentsOfFile:file];
        if (!NSEqualSizes(size, NSZeroSize))
        {
            CIImage *cimg = [CIImage imageWithData:[img TIFFRepresentation]];
            cimg = [AppDelegate fillCIImage:cimg toWidth:size.width andHeight:size.height];
            img = [[NSImage alloc] initWithData:[[[NSBitmapImageRep alloc] initWithCIImage:cimg] TIFFRepresentation]];
        }
        
        
        CGImageRef imageRef = [[NSBitmapImageRep imageRepWithData:[img TIFFRepresentation]] CGImageForProposedRect:nil context:nil hints:nil];
        CGImageDestinationAddImage(destination, imageRef,(__bridge CFDictionaryRef)(frameProperties));
        
        count++;
    }
    
    // SAVE GIF
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)(gifProperties));
    BOOL done = CGImageDestinationFinalize(destination);
    
    
    CFRelease(destination);
    NSLog(@"Finalize GIF... %@", done ? @"done" : @"ERROR !");
}


#pragma mark INTERNET UTILITIES
/////////////////////////////////////////////
///////         INTERNET UTILS        ///////
/////////////////////////////////////////////


-(void)sendEmailWithFile:(NSString*)file
{
    NSData * data = [NSData dataWithContentsOfFile:file];
    NSDictionary * di = [NSDictionary dictionaryWithObjectsAndKeys:
                         [[NSUserDefaults standardUserDefaults] stringForKey:@"emailField"],        @"to",
                         @"services@bunex-industries.com",                                          @"from",
                         [[NSUserDefaults standardUserDefaults] stringForKey:@"subjectField"],      @"subject",
                         [[NSUserDefaults standardUserDefaults] stringForKey:@"messageField"],      @"message",
                         [file pathExtension],                                                      @"extension",
                         file,                                                                      @"filepath",
                         [data base64EncodedStringWithOptions:0],                                   @"attached", nil];
    
    NSDictionary * resp = [self sendParams:di toService:@"http://bunex-industries.com/playground/send.php" withOptionnalFile:nil];
    NSLog(@"Email sending success = %@", [[resp objectForKey:@"success"] boolValue] ? @"YES" : @"NO");
}

-(NSDictionary*)sendParams:(NSDictionary*)dict toService:(NSString*)serviceURL withOptionnalFile:(NSData*)fileData
{
    NSError * err;
    if (YES)
    {
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:serviceURL]];
        NSString *boundary = @"0xKhTmLbOuNdArY";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        
        NSMutableData *postbody = [NSMutableData data];
        
        for (int i = 0; i < [[dict allKeys] count]; i++)
        {
            NSString * key = [[dict allKeys] objectAtIndex:i];
            [postbody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:[[NSString stringWithFormat:@"%@\r\n", [dict objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        if (fileData != nil)
        {
            [postbody appendData: [[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData: [[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"attached\"; filename=\"%@\"\r\n\r\n", @"attached"] dataUsingEncoding:NSUTF8StringEncoding]];
            [postbody appendData:fileData];
            [postbody appendData: [[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSString *postLength = [NSString stringWithFormat:@"%lu", [postbody length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPMethod:@"POST"];
        [request setValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postbody];
        
        
        NSURLResponse *response;
        NSData *POSTReply = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        //NSString * rawResponseString = [[NSString alloc] initWithData:POSTReply encoding:NSUTF8StringEncoding];
        NSDictionary * responseDict = [NSJSONSerialization JSONObjectWithData:POSTReply options:NSJSONReadingMutableContainers error:&err];
        return responseDict;
        
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"success", @"Pas connecté à internet", @"message", nil];
}




@end
