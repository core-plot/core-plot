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
                                            NSCollectionViewDelegate,
                                            NSCollectionViewDataSource,
                                            PlotViewDelegate>

@property (nonatomic, strong, nullable) PlotItem *plotItem;
@property (nonatomic, copy, nullable) NSString *currentThemeName;

-(IBAction)themeSelectionDidChange:(nonnull id)sender;

@end
