//
//  PlotItem.h
//  CorePlotGallery
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <CorePlot_iOS/CorePlot_iOS.h>
#import <UIKit/UIKit.h>

typedef CGRect CGNSRect;
typedef UIView PlotGalleryNativeView;

#else

#import <CorePlot/CorePlot.h>
typedef NSRect CGNSRect;
typedef NSView PlotGalleryNativeView;
#endif

extern NSString *const kDemoPlots;
extern NSString *const kPieCharts;
extern NSString *const kLinePlots;
extern NSString *const kBarPlots;
extern NSString *const kFinancialPlots;

@class CPTGraph;
@class CPTTheme;

@interface PlotItem : NSObject

@property (nonatomic, readwrite, strong) CPTGraphHostingView *defaultLayerHostingView;

@property (nonatomic, readwrite, strong) NSMutableArray *graphs;
@property (nonatomic, readwrite, strong) NSString *section;
@property (nonatomic, readwrite, strong) NSString *title;

@property (nonatomic, readonly) CGFloat titleSize;

+(void)registerPlotItem:(id)item;

-(void)renderInView:(PlotGalleryNativeView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated;
-(CPTNativeImage *)image;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
-(void)setFrameSize:(NSSize)size;
#endif

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated;

-(void)formatAllGraphs;

-(void)reloadData;
-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme;

-(void)addGraph:(CPTGraph *)graph;
-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)hostingView;
-(void)killGraph;

-(void)generateData;

-(NSComparisonResult)titleCompare:(PlotItem *)other;

@end
