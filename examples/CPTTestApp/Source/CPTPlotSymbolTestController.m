#import "CPTPlotSymbolTestController.h"

@interface CPTPlotSymbolTestController()

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, readwrite, strong) CPTXYGraph *graph;

@end

#pragma mark -

@implementation CPTPlotSymbolTestController

@synthesize hostView;
@synthesize graph;

-(void)awakeFromNib
{
    [super awakeFromNib];

    // Create graph
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(self.hostView.bounds)];
    self.hostView.hostedGraph = newGraph;
    self.graph                = newGraph;

    // Remove axes
    newGraph.axisSet = nil;

    // Background
    CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
    newGraph.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:grayColor]];
    CGColorRelease(grayColor);

    // Plot area
    grayColor                   = CGColorCreateGenericGray(0.2, 0.3);
    newGraph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:grayColor]];
    CGColorRelease(grayColor);
    newGraph.plotAreaFrame.masksToBorder = NO;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@11.0];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@14.0];

    CPTMutableShadow *lineShadow = [CPTMutableShadow shadow];
    lineShadow.shadowOffset     = CGSizeMake(3.0, -3.0);
    lineShadow.shadowBlurRadius = 4.0;
    lineShadow.shadowColor      = [CPTColor redColor];

    // Create a series of plots that uses the data source method
    for ( NSUInteger i = CPTPlotSymbolTypeNone; i <= CPTPlotSymbolTypeCustom; i++ ) {
        CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
        dataSourceLinePlot.identifier = [NSString stringWithFormat:@"%lu", (unsigned long)i];
        dataSourceLinePlot.shadow     = lineShadow;

        CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth              = 1.0;
        lineStyle.lineColor              = [CPTColor redColor];
        dataSourceLinePlot.dataLineStyle = lineStyle;

        dataSourceLinePlot.dataSource = self;

        [newGraph addPlot:dataSourceLinePlot];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 10;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            num = @(index);
            break;

        case CPTScatterPlotFieldY:
            num = @( ( (NSString *)plot.identifier ).integerValue );
            break;

        default:
            num = @0;
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
    symbol.symbolType = (CPTPlotSymbolType)( (NSString *)plot.identifier ).intValue;
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
        CGPathAddArc(path, NULL, 5., 3.3, 2.8, 0., M_PI, TRUE);
        CGPathCloseSubpath(path);

        symbol.customSymbolPath    = path;
        symbol.usesEvenOddClipRule = YES;
        CGPathRelease(path);
    }

    return symbol;
}

@end
