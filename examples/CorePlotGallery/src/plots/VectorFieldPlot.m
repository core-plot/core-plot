//
//  VectorFieldPlot.m
//  CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//

#import "VectorFieldPlot.h"

#import "PiNumberFormatter.h"

@interface VectorFieldPlot()

@property (nonatomic, readwrite, strong, nullable) CPTGraph *graph;
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSDictionary *> *plotData;

@end

@implementation VectorFieldPlot

@synthesize graph;
@synthesize plotData;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        graph    = nil;
        plotData = @[];

        self.title   = @"Vector Field Plot";
        self.section = kFieldsPlots;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData.count == 0 ) {
        NSMutableArray<NSDictionary *> *newData = [NSMutableArray array];
        
        double x = -2.0 * M_PI;
        while (x <= 2.0 * M_PI) {
            double y = -2.0 * M_PI;
            while (y <= 2.0 * M_PI) {
                double fx = sin(x);
                double fy = sin(y);
                double length = sqrt(fx * fx + fy * fy) / sqrt(2.0);
                double direction = atan2(fy, fx);
                
                [newData addObject:
                    @{ @(CPTVectorFieldPlotFieldX): @(x),
                       @(CPTVectorFieldPlotFieldY): @(y),
                       @(CPTVectorFieldPlotFieldVectorLength): @(length),
                       @(CPTVectorFieldPlotFieldVectorDirection): @(direction)
                    }
                 ];
                y += M_PI / 8.0;
            }
            x += M_PI / 8.0;
        }

        self.plotData = newData;
    }
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
    
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:bounds];
    self.graph = newGraph;

    [self addGraph:newGraph toHostingView:hostingView];
    [self applyTheme:theme toGraph:newGraph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    newGraph.plotAreaFrame.masksToBorder = NO;

    // Instructions
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color    = [CPTColor whiteColor];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = self.titleSize * CPTFloat(0.5);


    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-2.0 * M_PI) length:@(4.0 * M_PI)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-2.0 * M_PI) length:@(4.0 * M_PI)];

    PiNumberFormatter *formatter = [[PiNumberFormatter alloc] init];
    formatter.multiplier = @4;
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @(M_PI / 2.0);
    x.orthogonalPosition    = @(0.0);
    x.minorTicksPerInterval = 3;
    x.labelFormatter = formatter;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength   = @(M_PI / 2.0);
    y.minorTicksPerInterval = 3;
    y.orthogonalPosition    = @(0.0);
    y.labelFormatter = formatter;

    // Create a plot that uses the data source method
    CPTVectorFieldPlot *vectorFieldPlot = [[CPTVectorFieldPlot alloc] init];
    vectorFieldPlot.identifier   = @"Vector Field [sin(x)\nsin(y)]";
    vectorFieldPlot.dataSource   = self;
    vectorFieldPlot.delegate     = self;

    // Vector properties
    vectorFieldPlot.normalisedVectorLength = 0.25;
    vectorFieldPlot.arrowSize = CGSizeMake(5.0, 5.0);
    vectorFieldPlot.arrowType  = CPTVectorFieldArrowTypeSolid;
    

    // Add plot
    [newGraph addPlot:vectorFieldPlot];
    newGraph.defaultPlotSpace.delegate = self;

    // Add legend
    newGraph.legend                    = [CPTLegend legendWithGraph:newGraph];
    newGraph.legend.textStyle          = x.titleTextStyle;
    newGraph.legend.fill               = [CPTFill fillWithColor:[CPTColor clearColor]];
    newGraph.legend.borderLineStyle    = x.axisLineStyle;
    newGraph.legend.cornerRadius       = 5.0;
    newGraph.legend.swatchCornerRadius = 3.0;
    newGraph.legendAnchor              = CPTRectAnchorTop;
    newGraph.legendDisplacement        = CGPointMake(0.0, self.titleSize * CPTFloat(-2.0) - CPTFloat(12.0) );
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    return self.plotData[index][@(fieldEnum)];
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
    if( [self.plotData[idx][@(CPTVectorFieldPlotFieldVectorLength)] doubleValue] > 0.9 ) {
        linestyle.lineWidth = 2.0;
        linestyle.lineColor = [CPTColor redColor];
    }
    else if( [self.plotData[idx][@(CPTVectorFieldPlotFieldVectorLength)] doubleValue] > 0.7 ) {
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

@end
