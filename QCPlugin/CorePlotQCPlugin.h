#import <CorePlot/CorePlot.h>
#import <Quartz/Quartz.h>

@interface CorePlotQCPlugIn : QCPlugIn<CPTPlotDataSource>

@property (readwrite, strong) CPTGraph *graph;

@property (readwrite, assign) id<QCPlugInOutputImageProvider> outputImage;

@property (readwrite, assign) NSUInteger numberOfPlots;

@property (readwrite, assign) NSUInteger inputPixelsWide;
@property (readwrite, assign) NSUInteger inputPixelsHigh;

@property (readwrite, assign) CGColorRef inputPlotAreaColor;

@property (readwrite, assign) CGColorRef inputAxisColor;
@property (readwrite, assign) double inputAxisLineWidth;
@property (readwrite, assign) double inputAxisMajorTickWidth;
@property (readwrite, assign) double inputAxisMinorTickWidth;
@property (readwrite, assign) double inputAxisMajorTickLength;
@property (readwrite, assign) double inputAxisMinorTickLength;
@property (readwrite, assign) double inputMajorGridLineWidth;
@property (readwrite, assign) double inputMinorGridLineWidth;

@property (readwrite, assign) NSUInteger inputXMajorIntervals;
@property (readwrite, assign) NSUInteger inputYMajorIntervals;
@property (readwrite, assign) NSUInteger inputXMinorIntervals;
@property (readwrite, assign) NSUInteger inputYMinorIntervals;

@property (readwrite, assign) double inputXMin;
@property (readwrite, assign) double inputXMax;
@property (readwrite, assign) double inputYMin;
@property (readwrite, assign) double inputYMax;

-(void)createGraph;
-(void)addPlots:(NSUInteger)count;
-(void)addPlotWithIndex:(NSUInteger)index;
-(void)removePlots:(NSUInteger)count;
-(BOOL)configureGraph;
-(BOOL)configurePlots;
-(BOOL)configureAxis;

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;
-(CGColorRef)newDefaultColorForPlot:(NSUInteger)index alpha:(CGFloat)alpha;

-(void)freeResources;

-(CGColorRef)dataLineColor:(NSUInteger)index;
-(CGFloat)dataLineWidth:(NSUInteger)index;
-(CGColorRef)areaFillColor:(NSUInteger)index;
-(CGImageRef)newAreaFillImage:(NSUInteger)index;

@end
