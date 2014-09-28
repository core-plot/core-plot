//
//  PlotGalleryController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/5/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>
#import <Quartz/Quartz.h>

#import "PlotGallery.h"
#import "PlotView.h"

@interface PlotGalleryController : NSObject<NSSplitViewDelegate,
                                            PlotViewDelegate>
{
    @private
    IBOutlet NSSplitView *splitView;
    IBOutlet NSScrollView *scrollView;
    IBOutlet IKImageBrowserView *imageBrowser;
    IBOutlet NSPopUpButton *themePopUpButton;

    IBOutlet PlotView *hostingView;

    PlotItem *plotItem;

    NSString *currentThemeName;
}

@property (nonatomic, strong) PlotItem *plotItem;
@property (nonatomic, copy) NSString *currentThemeName;

-(IBAction)themeSelectionDidChange:(id)sender;

@end
