//
// CurvedInterpolationDemo.m
// Plot_Gallery
//
// Created by malte on 16/03/16.
//
//

#import "CurvedInterpolationDemo.h"

static const double bezierYShift                = -1.0;
static const double catmullRomUniformPlotYShift = 0.0;
static const double catmullRomCentripetalYShift = 1.0;
static const double catmullRomChordalYShift     = 2.0;
static const double hermiteCubicYShift          = -2.0;

static NSString *const bezierCurveIdentifier           = @"Bezier";
static NSString *const catmullRomUniformIdentifier     = @"Catmull-Rom Uniform";
static NSString *const catmullRomCentripetalIdentifier = @"Catmull-Rom Centripetal";
static NSString *const catmullRomChordalIdentifier     = @"Catmull-Rom Chordal";
static NSString *const hermiteCubicIdentifier          = @"Hermite Cubic";

@interface CurvedInterpolationDemo()

@property (nonatomic, readwrite, strong) NSArray<NSDictionary<NSString *, NSNumber *> *> *plotData;

@end

@implementation CurvedInterpolationDemo

@synthesize plotData = _plotData;

+(void)load
{
    [super registerPlotItem:self];
}

-(instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Curved Interpolation Options Demo";
        self.section = kLinePlots;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData.count == 0 ) {
        NSArray<NSNumber *> *const xValues = @[@0, @0.1, @0.2, @0.5, @0.6, @0.7, @1];
        NSArray<NSNumber *> *const yValues = @[@(0.5), @0.5, @(-1), @1, @1, @0, @0.1];

        if ( xValues.count != yValues.count ) {
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:@"invalid const data" userInfo:nil] raise];
        }
        NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *generatedData = [NSMutableArray new];
        for ( NSUInteger i = 0; i < xValues.count; i++ ) {
            NSNumber *x = xValues[i];
            NSNumber *y = yValues[i];
            if ( x && y ) {
                [generatedData addObject:@{
                     @"x": x,
                     @"y": y
                 }];
            }
        }
        self.plotData = generatedData;
    }
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingLeft   += self.titleSize * CPTFloat(2.25);
    graph.plotAreaFrame.paddingTop    += self.titleSize;
    graph.plotAreaFrame.paddingRight  += self.titleSize;
    graph.plotAreaFrame.paddingBottom += self.titleSize;
    graph.plotAreaFrame.masksToBorder  = NO;

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];

    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

    CPTLineCap *lineCap = [CPTLineCap sweptArrowPlotLineCap];
    lineCap.size = CGSizeMake( self.titleSize * CPTFloat(0.625), self.titleSize * CPTFloat(0.625) );

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @0.1;
    x.minorTicksPerInterval = 4;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.5];

    lineCap.lineStyle = x.axisLineStyle;
    CPTColor *lineColor = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    x.axisLineCapMax = lineCap;

    x.title       = @"X Axis";
    x.titleOffset = self.titleSize * CPTFloat(1.25);

    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval       = 4;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelOffset                 = self.titleSize * CPTFloat(0.25);

    lineCap.lineStyle = y.axisLineStyle;
    lineColor         = lineCap.lineStyle.lineColor;
    if ( lineColor ) {
        lineCap.fill = [CPTFill fillWithColor:lineColor];
    }
    y.axisLineCapMax = lineCap;
    y.axisLineCapMin = lineCap;

    y.title       = @"Y Axis";
    y.titleOffset = self.titleSize * CPTFloat(1.25);

    // Set axes
    graph.axisSet.axes = @[x, y];

    // Create the plots
    // Bezier
    CPTScatterPlot *bezierPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    bezierPlot.identifier = bezierCurveIdentifier;
    // Catmull-Rom
    CPTScatterPlot *cmUniformPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    cmUniformPlot.identifier = catmullRomUniformIdentifier;
    CPTScatterPlot *cmCentripetalPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    cmCentripetalPlot.identifier = catmullRomCentripetalIdentifier;
    CPTScatterPlot *cmChordalPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    cmChordalPlot.identifier = catmullRomChordalIdentifier;
    // Hermite Cubic
    CPTScatterPlot *hermitePlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    hermitePlot.identifier = hermiteCubicIdentifier;

    // set interpolation types
    bezierPlot.interpolation = cmUniformPlot.interpolation = cmCentripetalPlot.interpolation = cmChordalPlot.interpolation = hermitePlot.interpolation = CPTScatterPlotInterpolationCurved;

    bezierPlot.curvedInterpolationOption        = CPTScatterPlotCurvedInterpolationNormal;
    cmUniformPlot.curvedInterpolationOption     = CPTScatterPlotCurvedInterpolationCatmullRomUniform;
    cmChordalPlot.curvedInterpolationOption     = CPTScatterPlotCurvedInterpolationCatmullRomChordal;
    cmCentripetalPlot.curvedInterpolationOption = CPTScatterPlotCurvedInterpolationCatmullRomCentripetal;
    hermitePlot.curvedInterpolationOption       = CPTScatterPlotCurvedInterpolationHermiteCubic;

    // style plots
    CPTMutableLineStyle *lineStyle = [bezierPlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor greenColor];

    bezierPlot.dataLineStyle = lineStyle;

    lineStyle.lineColor         = [CPTColor redColor];
    cmUniformPlot.dataLineStyle = lineStyle;

    lineStyle.lineColor             = [CPTColor orangeColor];
    cmCentripetalPlot.dataLineStyle = lineStyle;

    lineStyle.lineColor         = [CPTColor yellowColor];
    cmChordalPlot.dataLineStyle = lineStyle;

    lineStyle.lineColor       = [CPTColor cyanColor];
    hermitePlot.dataLineStyle = lineStyle;

    // set data source and add plots
    bezierPlot.dataSource = cmUniformPlot.dataSource = cmCentripetalPlot.dataSource = cmChordalPlot.dataSource = hermitePlot.dataSource = self;

    [graph addPlot:bezierPlot];
    [graph addPlot:cmUniformPlot];
    [graph addPlot:cmCentripetalPlot];
    [graph addPlot:cmChordalPlot];
    [graph addPlot:hermitePlot];

    // Auto scale the plot space to fit the plot data
    [plotSpace scaleToFitPlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];

    // Expand the ranges to put some space around the plot
    [xRange expandRangeByFactor:@1.2];
    [yRange expandRangeByFactor:@1.2];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;

    [xRange expandRangeByFactor:@1.025];
    xRange.location = plotSpace.xRange.location;
    [yRange expandRangeByFactor:@1.05];
    x.visibleAxisRange = xRange;
    y.visibleAxisRange = yRange;

    [xRange expandRangeByFactor:@3.0];
    [yRange expandRangeByFactor:@3.0];
    plotSpace.globalXRange = xRange;
    plotSpace.globalYRange = yRange;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill       = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:0.5]];
    plotSymbol.lineStyle  = symbolLineStyle;
    plotSymbol.size       = CGSizeMake(5.0, 5.0);
    bezierPlot.plotSymbol = cmUniformPlot.plotSymbol = cmCentripetalPlot.plotSymbol = cmChordalPlot.plotSymbol = hermitePlot.plotSymbol = plotSymbol;

    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfRows    = 2;
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake( 0.0, self.titleSize * CPTFloat(2.0) );
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *identifier = (NSString *)plot.identifier;

    if ( fieldEnum == CPTScatterPlotFieldX ) {
        return self.plotData[index][@"x"];
    }
    else {
        NSNumber *baseY = self.plotData[index][@"y"];
        double shift    = 0.0;
        if ( [identifier isEqualToString:catmullRomUniformIdentifier] ) {
            shift = catmullRomUniformPlotYShift;
        }
        else if ( [identifier isEqualToString:catmullRomCentripetalIdentifier] ) {
            shift = catmullRomCentripetalYShift;
        }
        else if ( [identifier isEqualToString:catmullRomChordalIdentifier] ) {
            shift = catmullRomChordalYShift;
        }
        else if ( [identifier isEqualToString:hermiteCubicIdentifier] ) {
            shift = hermiteCubicYShift;
        }
        else if ( [identifier isEqualToString:bezierCurveIdentifier] ) {
            shift = bezierYShift;
        }
        return @(baseY.doubleValue + shift);
    }
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTGraph *theGraph    = space.graph;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)theGraph.axisSet;

    CPTMutablePlotRange *changedRange = [newRange mutableCopy];

    switch ( coordinate ) {
        case CPTCoordinateX:
            [changedRange expandRangeByFactor:@1.025];
            changedRange.location          = newRange.location;
            axisSet.xAxis.visibleAxisRange = changedRange;
            break;

        case CPTCoordinateY:
            [changedRange expandRangeByFactor:@1.05];
            axisSet.yAxis.visibleAxisRange = changedRange;
            break;

        default:
            break;
    }

    return newRange;
}

@end
