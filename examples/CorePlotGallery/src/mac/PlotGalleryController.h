//
//  PlotGalleryController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/5/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <CorePlot/CorePlot.h>

#import "PlotGallery.h"
#import "PlotView.h"

@interface PlotGalleryController : NSObject <NSSplitViewDelegate,
                                             PlotViewDelegate>
{
    IBOutlet NSSplitView        *splitView;
    IBOutlet NSScrollView       *scrollView;
    IBOutlet IKImageBrowserView *imageBrowser;
    IBOutlet NSPopUpButton      *themePopUpButton;

    IBOutlet PlotView           *hostingView;
    CPLayerHostingView          *defaultLayerHostingView;

    PlotItem                    *plotItem;

    NSString                    *currentThemeName;

    void                        *nuHandle;
}

@property (nonatomic, retain) PlotItem *plotItem;
@property (nonatomic, copy) NSString *currentThemeName;

- (IBAction)themeSelectionDidChange:(id)sender;

@end
