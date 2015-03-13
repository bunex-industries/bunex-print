//
//  BUNFilter.m
//  RGBCurves
//
//  Created by Jean-François Roversi on 23/08/13.
//  Copyright (c) 2013 Bunex-Industries. All rights reserved.
//

#import "BUNFilter.h"

@implementation BUNFilter

@synthesize window;



-(id)init
{
    self = [super init];
    if (self != nil)
    {
        
        return self;
    }
    return nil;
}

-(void)configure
{
    filterView.delegate = self;
    adjustView.delegate = self;
    
    [CIPlugIn loadAllPlugIns];
    filter = [CIFilter filterWithName:@"RGBCurves"];
    [filter class];
    NSLog(@"%@", filter != nil ? @"filter ON" : @"filter OFF");
    
    [twentyOnePopup removeAllItems];
    [twentyOnePopup addItemWithTitle:@"5 points spline"];
    [twentyOnePopup addItemWithTitle:@"21 points linear interpolation"];
    [twentyOnePopup addItemWithTitle:@"Curve assistant"];
    
    [imageSourcePopUp removeAllItems];
    [imageSourcePopUp addItemWithTitle:@"Choose..."];
    [[imageSourcePopUp menu] addItem:[NSMenuItem separatorItem]];
    NSError * err;
    NSArray * mireArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Mires"] error:&err];
    if (mireArray.count)
    {
        NSLog(@"%@", mireArray);
        for (NSString * mireName in mireArray)
        {
            [imageSourcePopUp addItemWithTitle:mireName];
        }
    }
    
    [imageSourcePopUp selectItemWithTitle:@"Mire Fujifilm.jpg"];
    [self imageImportation:imageSourcePopUp];
    
    [gradientView setImage:[NSImage imageNamed:@"gradientControl.jpg"]];
    
    
    [channelButton removeAllItems];
    [channelButton addItemWithTitle:@"RGB"];
    [channelButton addItemWithTitle:@"Red"];
    [channelButton addItemWithTitle:@"Green"];
    [channelButton addItemWithTitle:@"Blue"];
    [channelButton addItemWithTitle:@"Saturation"];
    
    [presetButton removeAllItems];
    
    NSArray * settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"specialFilterSettings"];
    for (NSDictionary * k  in settings)
    {
        [presetButton addItemWithTitle:[k objectForKey:@"name"]];
    }
    
    filterView.redPoints = [filter valueForKey:@"redPoints"];
    filterView.greenPoints = [filter valueForKey:@"greenPoints"];
    filterView.bluePoints = [filter valueForKey:@"bluePoints"];
    filterView.rgbPoints = [filter valueForKey:@"rgbPoints"];
    filterView.satPoints = [filter valueForKey:@"satPoints"];
    
    [filterView setNeedsDisplay:YES];
    
    filterView.selectedChannelPoints = filterView.rgbPoints;
    [presetButton selectItemWithTitle:@"Normal"];
    [presetButton validateEditing];
    
    [hueCurve setScale:1];
    [satCurve setScale:0.5];
    [lumCurve setScale:0.5];
    
    [imageSourcePopUp setAction:@selector(imageImportation:)];
    [presetButton setAction:@selector(settingDidChange:)];
}



-(void)processImage
{
    NSImage * img = [loadedImage copy];

    CIImage * ciimg = [CIImage imageWithData:[img TIFFRepresentation]];
    [filter setValue:ciimg forKey:@"inputImage"];
    
    [filter setValue:[NSNumber numberWithBool:[bwButton state]] forKey:@"BW"];
    [filter setValue:[NSNumber numberWithBool:[lumModeButton state]] forKey:@"lumMode"];
    [filter setValue:[NSNumber numberWithBool:[bwFirstButton state]] forKey:@"BWfirst"];
    
    [filter setValue:[NSNumber numberWithFloat:[selectedHueSlider floatValue]] forKey:@"selectedHue"];
    [filter setValue:[NSNumber numberWithFloat:[QSlider floatValue]] forKey:@"Q"];
    [filter setValue:[NSNumber numberWithFloat:[hueOffsetSlider floatValue]] forKey:@"hueOffset"];
    [filter setValue:[NSNumber numberWithFloat:[satOffsetSlider floatValue]] forKey:@"satOffset"];
    [filter setValue:[NSNumber numberWithFloat:[lumOffsetSlider floatValue]] forKey:@"lumOffset"];
    
    ciimg = [filter valueForKey:@"outputImage"];
    img = [[NSImage alloc] initWithData:[[[NSBitmapImageRep alloc] initWithCIImage:ciimg] TIFFRepresentation]];
    [imgView setImage:img];
    
    [filter setValue:[CIImage imageWithData:[[NSImage imageNamed:@"gradientControl.jpg"] TIFFRepresentation]] forKey:@"inputImage"];
    CIImage * ci_grad = [filter valueForKey:@"outputImage"];
    NSImage * grad = [[NSImage alloc] initWithData:[[[NSBitmapImageRep alloc] initWithCIImage:ci_grad] TIFFRepresentation]];
    [gradientView setImage:grad];
}



-(IBAction)imageImportation:(id)sender
{
    NSLog(@"image importation");
    NSString * imgPath;
    
    if (sender == imgView)
    {
        NSLog(@"from image view");
        loadedImage = [[imgView image] copy];
    }
    
    else if (sender == imageSourcePopUp)
    {
        if ([[imageSourcePopUp titleOfSelectedItem] isEqualToString:@"Choose..."])
        {
            NSLog(@"from file system");
            NSOpenPanel * panel = [NSOpenPanel openPanel];
            [panel setCanChooseFiles:YES];
            [panel setCanChooseDirectories:NO];
            [panel setCanCreateDirectories:NO];
            [panel setAllowsMultipleSelection:NO];
            [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"jpg",@"tif",@"png", nil]];
            [panel setTitle:@"Choose a picture"];
            
            if ([panel runModal] == NSModalResponseOK)
            {
                imgPath = [[[panel URLs] objectAtIndex:0] path];
            }
        }
        else
        {
            NSLog(@"from bundle");
            imgPath = [NSString stringWithFormat:@"%@/Mires/%@",[[NSBundle mainBundle] resourcePath], [imageSourcePopUp titleOfSelectedItem]];
        }
        
        
        if ([imgPath length])
        {
            NSLog(@"%@", imgPath);
            loadedImage = [[NSImage alloc] initWithContentsOfFile:imgPath];
            [imgView setImage:[loadedImage copy]];
        }
        
    }
    
    [self processImage];
}


-(void)curveChange
{
    [filter setValue:filterView.redPoints forKey:@"redPoints"];
    [filter setValue:filterView.greenPoints forKey:@"greenPoints"];
    [filter setValue:filterView.bluePoints forKey:@"bluePoints"];
    [filter setValue:filterView.rgbPoints forKey:@"rgbPoints"];
    [filter setValue:filterView.satPoints forKey:@"satPoints"];
    
//    if (filterView.pointIndex != -1)
//    {
//        [adjustView reset];
//        adjustView.lumLevel = NSPointFromString([filterView.rgbPoints objectAtIndex:filterView.pointIndex]).y;
//        adjustView.redLevel = NSPointFromString([filterView.redPoints objectAtIndex:filterView.pointIndex]).y;
//        adjustView.greenLevel = NSPointFromString([filterView.greenPoints objectAtIndex:filterView.pointIndex]).y;
//        adjustView.blueLevel = NSPointFromString([filterView.bluePoints objectAtIndex:filterView.pointIndex]).y;        
//        [adjustView setNeedsDisplay:YES];
//    }
    
    [self processImage];
}

-(IBAction)pointIndexChange:(id)sender
{
    int count = (int)filterView.rgbPoints.count;
    int currentIndex = filterView.pointIndex;
    
    
    if (sender == plusButton)
    {
        filterView.pointIndex = (currentIndex+1)%count;
        [pointIndexField setIntValue:filterView.pointIndex];
    }
    else if(sender == minusButton)
    {
        filterView.pointIndex = (currentIndex-1+(int)filterView.rgbPoints.count)%count;
        [pointIndexField setIntValue:filterView.pointIndex];
    }
    else if(sender == pointIndexField)
    {
        int entry = [pointIndexField intValue];
        entry = MAX(MIN(entry, ((int)filterView.rgbPoints.count-1)),0);
        [pointIndexField setIntValue:entry];
        filterView.pointIndex = entry;
    }
    else if(sender == filterView)
    {
        if (filterView.pointIndex != -1)
        {
            [pointIndexField setIntValue:filterView.pointIndex];
        }
        else
        {
            [pointIndexField setStringValue:@"..."];
        }
        
    }
    
    if (filterView.pointIndex != -1)
    {
        [adjustView reset];
        adjustView.lumLevel = NSPointFromString([filterView.rgbPoints objectAtIndex:filterView.pointIndex]).y;
        adjustView.redLevel = NSPointFromString([filterView.redPoints objectAtIndex:filterView.pointIndex]).y;
        adjustView.greenLevel = NSPointFromString([filterView.greenPoints objectAtIndex:filterView.pointIndex]).y;
        adjustView.blueLevel = NSPointFromString([filterView.bluePoints objectAtIndex:filterView.pointIndex]).y;        
    }
    [adjustView setNeedsDisplay:YES];
    [filterView setNeedsDisplay:YES];
}

-(void)pointDidAdjust
{
    if (filterView.pointIndex >0)
    {
        NSLog(@"pointDidAdjust");
        NSPoint rgbPt = NSPointFromString([filterView.rgbPoints objectAtIndex:filterView.pointIndex]);
        NSPoint redPt = NSPointFromString([filterView.redPoints objectAtIndex:filterView.pointIndex]);
        NSPoint greenPt = NSPointFromString([filterView.greenPoints objectAtIndex:filterView.pointIndex]);
        //NSPoint bluePt = NSPointFromString([filterView.bluePoints objectAtIndex:filterView.pointIndex]);
        
        [filterView.rgbPoints replaceObjectAtIndex:filterView.pointIndex withObject:NSStringFromPoint(NSMakePoint(rgbPt.x,      MAX(MIN(adjustView.lumLevel+adjustView.zAxisPosition,1), 0)))];
        [filterView.redPoints replaceObjectAtIndex:filterView.pointIndex withObject:NSStringFromPoint(NSMakePoint(redPt.x,      MAX(MIN(adjustView.redLevel+adjustView.xAxisPosition,1), 0)))];
        [filterView.greenPoints replaceObjectAtIndex:filterView.pointIndex withObject:NSStringFromPoint(NSMakePoint(greenPt.x,  MAX(MIN(adjustView.greenLevel+adjustView.yAxisPosition,1),0)))];
        
        [filterView setNeedsDisplay:YES];
        [self curveChange];
    }
    
    
}

-(NSImage*)processImage:(NSImage * )img withPreset:(NSString*)preset
{    
    CIImage * ciimg = [CIImage imageWithData:[img TIFFRepresentation]];
    [filter setValue:ciimg forKey:@"inputImage"];
    NSDictionary * settings = [self presetWithName:preset];
    
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"redPoints"]] forKey:@"redPoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"greenPoints"]] forKey:@"greenPoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"bluePoints"]] forKey:@"bluePoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"rgbPoints"]] forKey:@"rgbPoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"satPoints"]] forKey:@"satPoints"];
    
    [filter setValue:[settings objectForKey:@"selectedHue"] forKey:@"selectedHue"];
    [filter setValue:[settings objectForKey:@"Q"] forKey:@"Q"];
    [filter setValue:[settings objectForKey:@"hueOffset"] forKey:@"hueOffset"];
    [filter setValue:[settings objectForKey:@"satOffset"] forKey:@"satOffset"];
    [filter setValue:[settings objectForKey:@"lumOffset"] forKey:@"lumOffset"]; 

    [filter setValue:[settings objectForKey:@"BW"] forKey:@"BW"];
    [filter setValue:[settings objectForKey:@"lumMode"] forKey:@"lumMode"];
    [filter setValue:[settings objectForKey:@"BWfirst"] forKey:@"BWfirst"];
    
    
    ciimg = [filter valueForKey:@"outputImage"];
    img = [[NSImage alloc] initWithData:[[[NSBitmapImageRep alloc] initWithCIImage:ciimg] TIFFRepresentation]];
    
    return img;
}

-(CIImage*)processCIImage:(CIImage*)ciimg withPreset:(NSString*)preset
{
    [filter setValue:ciimg forKey:@"inputImage"];
    
    NSDictionary * settings = [self presetWithName:preset];
    
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"redPoints"]] forKey:@"redPoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"greenPoints"]] forKey:@"greenPoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"bluePoints"]] forKey:@"bluePoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"rgbPoints"]] forKey:@"rgbPoints"];
    [filter setValue:[NSMutableArray arrayWithArray:[settings objectForKey:@"satPoints"]] forKey:@"satPoints"];
    
    [filter setValue:[settings objectForKey:@"selectedHue"] forKey:@"selectedHue"];
    [filter setValue:[settings objectForKey:@"Q"] forKey:@"Q"];
    [filter setValue:[settings objectForKey:@"hueOffset"] forKey:@"hueOffset"];
    [filter setValue:[settings objectForKey:@"satOffset"] forKey:@"satOffset"];
    [filter setValue:[settings objectForKey:@"lumOffset"] forKey:@"lumOffset"];
    
    [filter setValue:[settings objectForKey:@"BW"] forKey:@"BW"];
    [filter setValue:[settings objectForKey:@"lumMode"] forKey:@"lumMode"];
    [filter setValue:[settings objectForKey:@"BWfirst"] forKey:@"BWfirst"];
    CIImage * res = [filter valueForKey:@"outputImage"];
    return res;
}



-(IBAction)savePreset:(id)sender    
{
    if ([[presetNameField stringValue] length] == 0)
    {
        NSAlert * al = [[NSAlert alloc ]init];
        [al setMessageText:@"Preset non-sauvegardé !"];
        [al setInformativeText:@"Veuiller entrer un nom pour ce preset."];
        if ([al runModal] == NSModalResponseOK)
        {
            return;
        }
    }
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [presetNameField stringValue], @"name",
                          [filter valueForKey:@"BW"], @"BW",
                          [filter valueForKey:@"BWfirst"], @"BWfirst",
                          [filter valueForKey:@"lumMode"], @"lumMode",
                          
                          [filter valueForKey:@"selectedHue"], @"selectedHue",
                          [filter valueForKey:@"Q"], @"Q",
                          [filter valueForKey:@"hueOffset"], @"hueOffset",
                          [filter valueForKey:@"satOffset"], @"satOffset",
                          [filter valueForKey:@"lumOffset"], @"lumOffset",
                          
                          [filter valueForKey:@"redPoints"], @"redPoints",
                          [filter valueForKey:@"greenPoints"], @"greenPoints",
                          [filter valueForKey:@"bluePoints"], @"bluePoints",
                          [filter valueForKey:@"rgbPoints"], @"rgbPoints",
                          [filter valueForKey:@"satPoints"], @"satPoints",nil];

    NSMutableArray * dd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"specialFilterSettings"] mutableCopy];
    NSDictionary * toRemove = [self presetWithName:[presetNameField stringValue]];
    if (toRemove != nil)
    {
        [dd removeObject:toRemove];
        NSLog(@"preset succesfully overwritten");
    }
    [dd addObject:dic];    
    
    [[NSUserDefaults standardUserDefaults] setObject:dd forKey:@"specialFilterSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"saved");
    
    [presetButton removeAllItems];
    NSArray * settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"specialFilterSettings"];
    for (NSDictionary * k  in settings)
    {
        [presetButton addItemWithTitle:[k objectForKey:@"name"]];
    }

    [presetButton selectItemWithTitle:[presetNameField stringValue]];
    [presetButton validateEditing];
    [presetNameField setStringValue:@""];
}

-(IBAction)settingDidChange:(id)sender
{
    if (sender == twentyOnePopup)
    {
        if ([twentyOnePopup indexOfSelectedItem] == 2)
        {
            curveEditing = YES;
            [filterView showTensors:YES];
            [self reset:nil];
        }
        else if([twentyOnePopup indexOfSelectedItem] == 1)
        {
            [filterView showTensors:NO];
            if (curveEditing == NO)
            {
                [self reset:nil];
            }
            else
            {
                curveEditing = NO;
            }
        }
        else if([twentyOnePopup indexOfSelectedItem] == 0)
        {
            [filterView showTensors:NO];
            curveEditing = NO;
            [self reset:nil];
            
        }
        
        [filterView setNeedsDisplay:YES];
        
    }
    if (sender == channelButton)
    {
        int index = (int)[channelButton indexOfSelectedItem];
        filterView.channel = index;
        if ([[channelButton titleOfSelectedItem] isEqualToString:@"RGB"])
        {
            filterView.selectedChannelPoints = [filter valueForKey:@"rgbPoints"];
        }
        else if([[channelButton titleOfSelectedItem] isEqualToString:@"Red"])
        {
            filterView.selectedChannelPoints = [filter valueForKey:@"redPoints"];
        }
        else if([[channelButton titleOfSelectedItem] isEqualToString:@"Green"])
        {
            filterView.selectedChannelPoints = [filter valueForKey:@"greenPoints"];
        }
        else if([[channelButton titleOfSelectedItem] isEqualToString:@"Blue"])
        {
            filterView.selectedChannelPoints = [filter valueForKey:@"bluePoints"];
        }
        else if([[channelButton titleOfSelectedItem] isEqualToString:@"Saturation"])
        {
            filterView.selectedChannelPoints = [filter valueForKey:@"satPoints"];
        }
    }

    if (sender == bwButton)
    {
        [self processImage];
    }
    if (sender == bwFirstButton)
    {
        [self processImage];
    }
    if (sender == lumModeButton)
    {
        [self processImage];
    }
    if ([sender class] == [NSSlider class])
    {
        [self processImage];

        hueCurve.Q = [QSlider floatValue];
        hueCurve.gain = [hueOffsetSlider floatValue];
        hueCurve.hue = [selectedHueSlider floatValue];
        
        satCurve.Q = [QSlider floatValue];
        satCurve.gain = [satOffsetSlider floatValue];
        satCurve.hue = [selectedHueSlider floatValue];
        
        lumCurve.Q = [QSlider floatValue];
        lumCurve.gain = [lumOffsetSlider floatValue];
        lumCurve.hue = [selectedHueSlider floatValue];
        
        [hueCurve setNeedsDisplay:YES];
        [satCurve setNeedsDisplay:YES];
        [lumCurve setNeedsDisplay:YES];
    }
    

    if (sender == previewButton)
    {
        if (previewButton.state)
        {
            [self processImage];
        }
        else
        {
            [imgView setImage:[loadedImage copy]];
            [gradientView setImage:[NSImage imageNamed:@"gradientControl.jpg"]];
        }
        
    }

    if (sender == presetButton)
    {
        NSDictionary * dict = [self presetWithName:[presetButton titleOfSelectedItem]];
        //NSLog(@"%@", dict);
        
        filterView.redPoints = [NSMutableArray arrayWithArray:[dict objectForKey:@"redPoints"]];
        filterView.greenPoints = [NSMutableArray arrayWithArray:[dict objectForKey:@"greenPoints"]];
        filterView.bluePoints = [NSMutableArray arrayWithArray:[dict objectForKey:@"bluePoints"]];
        filterView.rgbPoints = [NSMutableArray arrayWithArray:[dict objectForKey:@"rgbPoints"]];
        filterView.satPoints = [NSMutableArray arrayWithArray:[dict objectForKey:@"satPoints"]];
        filterView.selectedChannelPoints = filterView.rgbPoints;
        filterView.channel = 0;
        filterView.pointIndex = 0;
                    
        [twentyOnePopup selectItemAtIndex:([filterView.rgbPoints count]==21)];
        [bwButton setState:[[dict objectForKey:@"BW"] intValue]];
        [bwFirstButton setState:[[dict objectForKey:@"BWfirst"] intValue]];
        [lumModeButton setState:[[dict objectForKey:@"lumMode"] intValue]];
        
        [selectedHueSlider setFloatValue:[[dict objectForKey:@"selectedHue"] floatValue]];
        [QSlider setFloatValue:[[dict objectForKey:@"Q"] floatValue]];
        [hueOffsetSlider setFloatValue:[[dict objectForKey:@"hueOffset"] floatValue]];
        [satOffsetSlider setFloatValue:[[dict objectForKey:@"satOffset"] floatValue]];
        [lumOffsetSlider setFloatValue:[[dict objectForKey:@"lumOffset"] floatValue]];
        
        
        [channelButton selectItemWithTitle:@"RGB"];
        [self curveChange];
        [self settingDidChange:hueOffsetSlider];
        
    }
    

    [filterView setNeedsDisplay:YES];
    
    
}

-(IBAction)reset:(id)sender
{
    [(RGBCurves*)filter resetValuesTwentyOneMode:(int)[twentyOnePopup indexOfSelectedItem]];
    
    filterView.redPoints = [filter valueForKey:@"redPoints"];
    filterView.greenPoints = [filter valueForKey:@"greenPoints"];
    filterView.bluePoints = [filter valueForKey:@"bluePoints"];
    filterView.rgbPoints = [filter valueForKey:@"rgbPoints"];
    filterView.satPoints = [filter valueForKey:@"satPoints"];
    filterView.pointIndex = -1;
    [self pointIndexChange:filterView];
    
    [adjustView reset];
    
    [bwButton setState:NO];
    [lumModeButton setState:NO];
    [bwFirstButton setState:YES];
    
    [selectedHueSlider setFloatValue:[[filter valueForKey:  @"selectedHue"] floatValue]];
    [QSlider setFloatValue:[[filter valueForKey:            @"Q"] floatValue]];
    [hueOffsetSlider setFloatValue:[[filter valueForKey:    @"hueOffset"] floatValue]];
    [satOffsetSlider setFloatValue:[[filter valueForKey:    @"satOffset"] floatValue]];
    [lumOffsetSlider setFloatValue:[[filter valueForKey:    @"lumOffset"] floatValue]];
    
    [self settingDidChange:channelButton];
    [self settingDidChange:hueOffsetSlider];
    [filterView reset];
    [filterView setNeedsDisplay:YES];
    [self processImage];
    [adjustView setNeedsDisplay:YES];
}




-(IBAction)shoot:(id)sender
{
    NSLog(@"shoot");
}

-(IBAction)print:(id)sender
{
    NSSize size = NSMakeSize(300*102/25.4, 300*152/25.4); // size of the doc in px (w,h)
    NSLog(@"view size in px = %d x %d", (int)size.width, (int)size.height);
    
    BUNViewForPrint * viewForPrint = [[BUNViewForPrint alloc] initWithFrame:NSMakeRect(0, 0, size.width, size.height)];

    [filter setValue:[CIImage imageWithData:[loadedImage TIFFRepresentation]] forKey:@"inputImage"];
    CIImage* ciimg = [filter valueForKey:@"outputImage"];
    NSImage * img = [[NSImage alloc] initWithData:[[[NSBitmapImageRep alloc] initWithCIImage:ciimg] TIFFRepresentation]];
    
    viewForPrint.img = img;
    viewForPrint.presetName = [presetButton titleOfSelectedItem];
    
    [viewForPrint setNeedsDisplay:YES];
    
    NSPrintInfo* printInfo = [NSUnarchiver unarchiveObjectWithFile:@"/Users/zan/Desktop/preset_4x6"];
    

    
    
    [[printInfo dictionary] setObject:[NSNumber numberWithInt:1] forKey:NSPrintCopies];

        
    NSPrintOperation *operation = [NSPrintOperation printOperationWithView:viewForPrint printInfo:printInfo];
    [operation setShowsPrintPanel:NO];
    [operation setShowsProgressPanel:NO];
    [operation runOperation];
    
}



-(IBAction)applyAndSave:(id)sender
{
    
}

-(NSDictionary * )presetWithName:(NSString*)presetName
{
    NSArray * settings = [[NSUserDefaults standardUserDefaults] objectForKey:@"specialFilterSettings"];
    for (NSDictionary * dic in settings)
    {
        if ([[dic objectForKey:@"name"] isEqualToString:presetName])
        {
            return dic;
        }
    }
    return nil;
}




@end
