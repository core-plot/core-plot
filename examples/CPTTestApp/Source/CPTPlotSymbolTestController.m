#import "CPTPlotSymbolTestController.h"

@interface CPTPlotSymbolTestController()

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *hostView;

@end

#pragma mark -

@implementation CPTPlotSymbolTestController

@synthesize hostView;

-(void)awakeFromNib
{
    [super awakeFromNib];

    // Create graph
    graph                = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(hostView.bounds)];
    hostView.hostedGraph = graph;

    // Remove axes
    graph.axisSet = nil;

    // Background
    CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
    graph.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:grayColor]];
    CGColorRelease(grayColor);

    // Plot area
    grayColor                = CGColorCreateGenericGray(0.2, 0.3);
    graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:grayColor]];
    CGColorRelease(grayColor);

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0) length:CPTDecimalFromFloat(11.0)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0) length:CPTDecimalFromFloat(14.0)];

    CPTMutableShadow *lineShadow = [CPTMutableShadow shadow];
    lineShadow.shadowOffset     = CGSizeMake(3.0, -3.0);
    lineShadow.shadowBlurRadius = 4.0;
    lineShadow.shadowColor      = [CPTColor redColor];

    // Create a series of plots that uses the data source method
    for ( NSUInteger i = CPTPlotSymbolTypeNone; i <= CPTPlotSymbolTypeCustom; i++ ) {
        CPTScatterPlot *dataSourceLinePlot = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame:graph.bounds];
        dataSourceLinePlot.identifier = [NSString stringWithFormat:@"%lu", (unsigned long)i];
        dataSourceLinePlot.shadow     = lineShadow;

        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 1.f;
        lineStyle.lineColor              = [CPTColor redColor];
        dataSourceLinePlot.dataLineStyle = lineStyle;

        dataSourceLinePlot.dataSource = self;

        [graph addPlot:dataSourceLinePlot];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 10;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%lud", (unsigned long)index]];
            break;

        case CPTScatterPlotFieldY:
            num = [NSDecimalNumber decimalNumberWithString:(NSString *)plot.identifier];
            break;

        default:
            num = [NSDecimalNumber zero];
    }
    return num;
}

-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index
{
    CPTGradient *gradientFill = [CPTGradient rainbowGradient];

    gradientFill.gradientType = CPTGradientTypeRadial;

    CPTMutableShadow *symbolShadow = [CPTMutableShadow shadow];
    symbolShadow.shadowOffset     = CGSizeMake(3.0, -3.0);
    symbolShadow.shadowBlurRadius = 3.0;
    symbolShadow.shadowColor      = [CPTColor blackColor];

    CPTPlotSymbol *symbol = [[CPTPlotSymbol alloc] init];
    symbol.symbolType = (CPTPlotSymbolType)[(NSString *)plot.identifier intValue];
    symbol.fill       = [CPTFill fillWithGradient:gradientFill];
    symbol.shadow     = symbolShadow;

    if ( index > 0 ) {
        symbol.size = CGSizeMake(index * 4, index * 4);
    }

    if ( symbol.symbolType == CPTPlotSymbolTypeCustom ) {
        // Creating the custom path.
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 0., 0.);

        CGPathAddEllipseInRect( path, NULL, CGRectMake(0., 0., 10., 10.) );
        CGPathAddEllipseInRect( path, NULL, CGRectMake(1.5, 4., 3., 3.) );
        CGPathAddEllipseInRect( path, NULL, CGRectMake(5.5, 4., 3., 3.) );
        CGPathMoveToPoint(path, NULL, 5., 2.);
        CGPathAddArc(path, NULL, 5., 3.3, 2.8, 0., pi, TRUE);
        CGPathCloseSubpath(path);

        symbol.customSymbolPath    = path;
        symbol.usesEvenOddClipRule = YES;
        CGPathRelease(path);
    }

    return symbol;
}

@end
