//
// PlotItem.h
// CorePlotGallery
//

#import <Foundation/Foundation.h>

#import <CorePlot/CorePlot.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

typedef CGRect CGNSRect;
typedef UIView PlotGalleryNativeView;

#else

typedef NSRect CGNSRect;
typedef NSView PlotGalleryNativeView;
#endif

extern NSString *__nonnull const kDemoPlots;
extern NSString *__nonnull const kPieCharts;
extern NSString *__nonnull const kLinePlots;
extern NSString *__nonnull const kBarPlots;
extern NSString *__nonnull const kFinancialPlots;

@class CPTGraph;
@class CPTTheme;

@interface PlotItem : NSObject

@property (nonatomic, readwrite, strong, nullable) CPTGraphHostingView *defaultLayerHostingView;

@property (nonatomic, readwrite, strong, nonnull) NSMutableArray<__kindof CPTGraph *> *graphs;
@property (nonatomic, readwrite, strong, nonnull) NSString *section;
@property (nonatomic, readwrite, strong, nonnull) NSString *title;

@property (nonatomic, readonly) CGFloat titleSize;

+(void)registerPlotItem:(nonnull id)item;

-(void)renderInView:(nonnull PlotGalleryNativeView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated;
-(nonnull CPTNativeImage *)image;
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
-(void)setFrameSize:(NSSize)size;
#endif

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated;

-(void)formatAllGraphs;

-(void)reloadData;
-(void)applyTheme:(nullable CPTTheme *)theme toGraph:(nonnull CPTGraph *)graph withDefault:(nullable CPTTheme *)defaultTheme;

-(void)addGraph:(nonnull CPTGraph *)graph;
-(void)addGraph:(nonnull CPTGraph *)graph toHostingView:(nullable CPTGraphHostingView *)hostingView;
-(void)killGraph;

-(void)generateData;

-(NSComparisonResult)titleCompare:(nonnull PlotItem *)other;

@end
