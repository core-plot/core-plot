//
// PlotGalleryController.h
// CorePlotGallery
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>
#import <Quartz/Quartz.h>

#import "PlotGallery.h"
#import "PlotView.h"

@interface PlotGalleryController : NSObject<NSSplitViewDelegate,
                                            PlotViewDelegate>

@property (nonatomic, strong) PlotItem *plotItem;
@property (nonatomic, copy) NSString *currentThemeName;

-(IBAction)themeSelectionDidChange:(id)sender;

@end
