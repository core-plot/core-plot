#import <CorePlot/CorePlot.h>
#import <Quartz/Quartz.h>

@interface CorePlotQCPlugIn : QCPlugIn<CPTPlotDataSource>
{
    NSUInteger numberOfPlots;
    BOOL configurationCheck;

    void *imageData;
    CGContextRef bitmapContext;
    id<QCPlugInOutputImageProvider> imageProvider;
    CPTGraph *graph;
}

/*
 * Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
 * @property double inputFoo;
 * @property(assign) NSString* outputBar;
 * You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
 */

@property (nonatomic, readwrite, assign) id<QCPlugInOutputImageProvider> outputImage;

@property (nonatomic, readwrite, assign) NSUInteger numberOfPlots;

@property (nonatomic, readwrite, assign) NSUInteger inputPixelsWide;
@property (nonatomic, readwrite, assign) NSUInteger inputPixelsHigh;

@property (nonatomic, readwrite, strong) NSColor *inputPlotAreaColor;

@property (nonatomic, readwrite, strong) NSColor *inputAxisColor;
@property (nonatomic, readwrite, assign) double inputAxisLineWidth;
@property (nonatomic, readwrite, assign) double inputAxisMajorTickWidth;
@property (nonatomic, readwrite, assign) double inputAxisMinorTickWidth;
@property (nonatomic, readwrite, assign) double inputAxisMajorTickLength;
@property (nonatomic, readwrite, assign) double inputAxisMinorTickLength;
@property (nonatomic, readwrite, assign) double inputMajorGridLineWidth;
@property (nonatomic, readwrite, assign) double inputMinorGridLineWidth;

@property (nonatomic, readwrite, assign) NSUInteger inputXMajorIntervals;
@property (nonatomic, readwrite, assign) NSUInteger inputYMajorIntervals;
@property (nonatomic, readwrite, assign) NSUInteger inputXMinorIntervals;
@property (nonatomic, readwrite, assign) NSUInteger inputYMinorIntervals;

@property (nonatomic, readwrite, assign) double inputXMin;
@property (nonatomic, readwrite, assign) double inputXMax;
@property (nonatomic, readwrite, assign) double inputYMin;
@property (nonatomic, readwrite, assign) double inputYMax;

-(void)createGraph;
-(void)addPlots:(NSUInteger)count;
-(void)addPlotWithIndex:(NSUInteger)index;
-(void)removePlots:(NSUInteger)count;
-(BOOL)configureGraph;
-(BOOL)configurePlots;
-(BOOL)configureAxis;

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;
-(NSColor *)newDefaultColorForPlot:(NSUInteger)index alpha:(CGFloat)alpha;

-(void)freeResources;

-(NSColor *)dataLineColor:(NSUInteger)index;
-(CGFloat)dataLineWidth:(NSUInteger)index;
-(NSColor *)areaFillColor:(NSUInteger)index;
-(NSImage *)areaFillImage:(NSUInteger)index;

@end
