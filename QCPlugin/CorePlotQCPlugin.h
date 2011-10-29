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

@property (assign) id<QCPlugInOutputImageProvider> outputImage;

@property (assign) NSUInteger numberOfPlots;

@property (assign) NSUInteger inputPixelsWide;
@property (assign) NSUInteger inputPixelsHigh;

@property (assign) CGColorRef inputPlotAreaColor;

@property (assign) CGColorRef inputAxisColor;
@property (assign) double inputAxisLineWidth;
@property (assign) double inputAxisMajorTickWidth;
@property (assign) double inputAxisMinorTickWidth;
@property (assign) double inputAxisMajorTickLength;
@property (assign) double inputAxisMinorTickLength;
@property (assign) double inputMajorGridLineWidth;
@property (assign) double inputMinorGridLineWidth;

@property (assign) NSUInteger inputXMajorIntervals;
@property (assign) NSUInteger inputYMajorIntervals;
@property (assign) NSUInteger inputXMinorIntervals;
@property (assign) NSUInteger inputYMinorIntervals;

@property (assign) double inputXMin;
@property (assign) double inputXMax;
@property (assign) double inputYMin;
@property (assign) double inputYMax;

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

-(id)dataLineColor:(NSUInteger)index;
-(CGFloat)dataLineWidth:(NSUInteger)index;
-(id)areaFillColor:(NSUInteger)index;
-(CGImageRef)newAreaFillImage:(NSUInteger)index;

@end
