//
//  VectorFieldContinuousPlot.m
//  CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//

#import "VectorFieldContinuousPlot.h"

#import "PiNumberFormatter.h"

@interface VectorFieldContinuousPlot()

@property (nonatomic, readwrite, strong) NSMutableSet<CPTFieldFunctionDataSource *> *dataSources;

@end

@implementation VectorFieldContinuousPlot

@synthesize dataSources;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        dataSources = [[NSMutableSet alloc] init];
        
        self.title   = @"Vector Field Continuous Plot";
        self.section = kFieldsPlots;
    }

    return self;
}

-(void)killGraph
{
    [self.dataSources removeAllObjects];

    [super killGraph];
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
    
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.masksToBorder = NO;
    graph.defaultPlotSpace.delegate = self;

    // Instructions
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color    = [CPTColor whiteColor];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = self.titleSize * CPTFloat(0.5);

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-2.0 * M_PI) length:@(4.0 * M_PI)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-2.0 * M_PI) length:@(4.0 * M_PI)];
    plotSpace.allowsUserInteraction = YES;
    

    PiNumberFormatter *formatter = [[PiNumberFormatter alloc] init];
    formatter.multiplier = @4;
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @(M_PI / 2.0);
    x.minorTicksPerInterval = 3;
    x.labelFormatter = formatter;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.5];

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength   = @(M_PI / 2.0);
    y.minorTicksPerInterval = 3;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelFormatter = formatter;

    // Create a plot that uses the data source method
    CPTVectorFieldPlot *vectorFieldPlot = [[CPTVectorFieldPlot alloc] init];
    vectorFieldPlot.identifier   = @"Vector Field [sin(x)\n        sin(y)]";
    vectorFieldPlot.delegate     = self;

    // Vector properties
    vectorFieldPlot.normalisedVectorLength = 0.25;
    vectorFieldPlot.arrowSize = CGSizeMake(5.0, 5.0);
    vectorFieldPlot.arrowType  = CPTVectorFieldArrowTypeSolid;
    vectorFieldPlot.vectorLineStylesDataSource = self;
    vectorFieldPlot.plotSpace = plotSpace;
    
    CPTFieldDataSourceBlock blockX       = ^(double xVal, double yVal) {
                NSLog(@"%f %f", xVal, yVal);
                return sin(xVal);
            };
    CPTFieldDataSourceBlock blockY       = ^(double xVal, double yVal) {
                NSLog(@"%f %f", xVal, yVal);
                return sin(yVal);
            };
    
    CPTFieldFunctionDataSource *fieldPlotDataSource = [CPTFieldFunctionDataSource dataSourceForPlot:vectorFieldPlot withBlockX:blockX withBlockY:blockY];

    fieldPlotDataSource.resolutionX = ceil(CPTDecimalDoubleValue(graph.plotAreaFrame.plotArea.widthDecimal) / 32.0);
    fieldPlotDataSource.resolutionY = fieldPlotDataSource.resolutionX;

    vectorFieldPlot.dataSource = fieldPlotDataSource;
    vectorFieldPlot.alignsPointsToPixels = NO;

    [self.dataSources addObject:fieldPlotDataSource];

    // Add plot
    [graph addPlot:vectorFieldPlot];

    // Add legend
    graph.legend                    = [CPTLegend legendWithGraph:graph];
    graph.legend.textStyle          = x.titleTextStyle;
    graph.legend.fill               = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph.legend.borderLineStyle    = x.axisLineStyle;
    graph.legend.cornerRadius       = 5.0;
    graph.legend.swatchCornerRadius = 3.0;
    graph.legendAnchor              = CPTRectAnchorTop;
    graph.legendDisplacement        = CGPointMake(0.0, self.titleSize * CPTFloat(-2.0) - CPTFloat(12.0) );
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point
{
    return NO;
}

#pragma mark -
#pragma mark Plot Source Methods


-(nullable CPTLineStyle *)lineStyleForVectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot recordIndex:(NSUInteger)idx {
    CPTMutableLineStyle *linestyle = [[CPTMutableLineStyle alloc] init];
    double vectorLength = [plot cachedDoubleForField:CPTVectorFieldPlotFieldVectorLength recordIndex:idx];
    double maxVectorLength = plot.maxVectorLength;
    
    if( vectorLength > 0.85 * maxVectorLength ) {
        linestyle.lineWidth = 2.0;
        linestyle.lineColor = [CPTColor redColor];
    }
    else if( vectorLength > 0.50 * maxVectorLength ) {
        linestyle.lineWidth = 1.0;
        linestyle.lineColor = [CPTColor orangeColor];
    }
    else {
        linestyle.lineWidth = 0.5;
        linestyle.lineColor = [CPTColor blueColor];
    }
    return linestyle;
}

#pragma mark -
#pragma mark Plot Delegate Methods

-(void)vectorFieldPlot:(nonnull CPTVectorFieldPlot *)plot vectorFieldWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Range for '%@' was selected at index %d.", plot.identifier, (int)index);
}

- (NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot {
    return 0;
}

@end
