//
//  SimpleBarGraph.m
//  CorePlotGallery
//

#import "VerticalBarChart.h"

static const BOOL kUseHorizontalBars = NO;

@interface VerticalBarChart()

@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;
@end

@implementation VerticalBarChart

@synthesize symbolTextAnnotation;

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Vertical Bar Chart";
        self.section = kBarPlots;
    }

    return self;
}

-(void)killGraph
{
    if ( [self.graphs count] ) {
        CPTGraph *graph = (self.graphs)[0];

        CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
        if ( annotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
            self.symbolTextAnnotation = nil;
        }
    }

    [super killGraph];
}

-(void)generateData
{
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

    CGFloat textSize = self.titleSize;

    graph.plotAreaFrame.masksToBorder = NO;
    if ( kUseHorizontalBars ) {
        graph.plotAreaFrame.paddingBottom += self.titleSize;
    }
    else {
        graph.plotAreaFrame.paddingLeft += self.titleSize;
    }

    // Add plot space for bar charts
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
    [barPlotSpace setScaleType:CPTScaleTypeCategory forCoordinate:CPTCoordinateX];
    if ( kUseHorizontalBars ) {
        barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-10.0f) length:CPTDecimalFromFloat(120.0f)];
        barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(11.0f)];
    }
    else {
        barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(11.0f)];
        barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-10.0f) length:CPTDecimalFromFloat(120.0f)];
    }
    [graph addPlotSpace:barPlotSpace];

    // Create grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.0;
    majorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.75];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 1.0;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.25];

    // Create axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    {
        x.majorIntervalLength         = ( kUseHorizontalBars ? CPTDecimalFromInteger(10) : CPTDecimalFromInteger(1) );
        x.minorTicksPerInterval       = (kUseHorizontalBars ? 9 : 0);
        x.orthogonalCoordinateDecimal = ( kUseHorizontalBars ? CPTDecimalFromDouble(-0.5) : CPTDecimalFromInteger(0) );

        x.majorGridLineStyle = majorGridLineStyle;
        x.minorGridLineStyle = minorGridLineStyle;
        x.axisLineStyle      = nil;
        x.majorTickLineStyle = nil;
        x.minorTickLineStyle = nil;
        x.labelOffset        = self.titleSize * CPTFloat(0.5);
        if ( kUseHorizontalBars ) {
            x.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
            x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.5f) length:CPTDecimalFromFloat(10.0f)];
        }
        else {
            x.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.5f) length:CPTDecimalFromFloat(10.0f)];
            x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
        }

        x.title       = @"X Axis";
        x.titleOffset = self.titleSize * CPTFloat(1.5);

        x.titleLocation = ( kUseHorizontalBars ? CPTDecimalFromInteger(55) : CPTDecimalFromInteger(5) );

        x.plotSpace = barPlotSpace;
    }

    CPTXYAxis *y = axisSet.yAxis;
    {
        y.majorIntervalLength         = ( kUseHorizontalBars ? CPTDecimalFromInteger(1) : CPTDecimalFromInteger(10) );
        y.minorTicksPerInterval       = (kUseHorizontalBars ? 0 : 9);
        y.orthogonalCoordinateDecimal = ( kUseHorizontalBars ? CPTDecimalFromInteger(0) : CPTDecimalFromDouble(-0.5) );

        y.preferredNumberOfMajorTicks = 8;
        y.majorGridLineStyle          = majorGridLineStyle;
        y.minorGridLineStyle          = minorGridLineStyle;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = nil;
        y.minorTickLineStyle          = nil;
        y.labelOffset                 = self.titleSize * CPTFloat(0.5);
        y.labelRotation               = CPTFloat(M_PI_2);
        if ( kUseHorizontalBars ) {
            y.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.5f) length:CPTDecimalFromFloat(10.0f)];
            y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
        }
        else {
            y.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(100.0f)];
            y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-0.5f) length:CPTDecimalFromFloat(10.0f)];
        }

        y.title       = @"Y Axis";
        y.titleOffset = self.titleSize * CPTFloat(1.5);

        y.titleLocation = ( kUseHorizontalBars ? CPTDecimalFromInteger(5) : CPTDecimalFromInteger(55) );

        y.plotSpace = barPlotSpace;
    }

    // Set axes
    graph.axisSet.axes = @[x, y];

    // Create a bar line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor whiteColor];

    // Create first bar plot
    CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    barPlot.lineStyle       = barLineStyle;
    barPlot.fill            = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0 green:0.0 blue:0.5 alpha:0.5]];
    barPlot.barBasesVary    = YES;
    barPlot.barWidth        = CPTDecimalFromFloat(0.5f); // bar is 50% of the available space
    barPlot.barCornerRadius = 10.0;

    barPlot.barsAreHorizontal = kUseHorizontalBars;

    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color = [CPTColor whiteColor];

    barPlot.labelTextStyle = whiteTextStyle;
    barPlot.labelOffset    = 0.0;

    barPlot.delegate   = self;
    barPlot.dataSource = self;
    barPlot.identifier = @"Bar Plot 1";

    [graph addPlot:barPlot toPlotSpace:barPlotSpace];

    // Create second bar plot
    CPTBarPlot *barPlot2 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];

    barPlot2.lineStyle    = barLineStyle;
    barPlot2.fill         = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0 green:1.0 blue:0.5 alpha:0.5]];
    barPlot2.barBasesVary = YES;

    barPlot2.barWidth        = CPTDecimalFromFloat(1.0f); // bar is full (100%) width
    barPlot2.barCornerRadius = 2.0;

    barPlot2.barsAreHorizontal = kUseHorizontalBars;

    barPlot2.delegate   = self;
    barPlot2.dataSource = self;
    barPlot2.identifier = @"Bar Plot 2";

    [graph addPlot:barPlot2 toPlotSpace:barPlotSpace];

    // Add legend using an annotation
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfRows    = 2;
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:CPTFloat(0.15)]];
    theLegend.borderLineStyle = barLineStyle;
    theLegend.cornerRadius    = textSize * CPTFloat(0.25);
    theLegend.swatchSize      = CGSizeMake( textSize * CPTFloat(0.75), textSize * CPTFloat(0.75) );
    whiteTextStyle.fontSize   = textSize * CPTFloat(0.5);
    theLegend.textStyle       = whiteTextStyle;
    theLegend.rowMargin       = textSize * CPTFloat(0.25);

    theLegend.paddingLeft   = textSize * CPTFloat(0.375);
    theLegend.paddingTop    = textSize * CPTFloat(0.375);
    theLegend.paddingRight  = textSize * CPTFloat(0.375);
    theLegend.paddingBottom = textSize * CPTFloat(0.375);

    NSArray *plotPoint = (kUseHorizontalBars ? @[@95, @0] : @[@0, @95]);

    CPTPlotSpaceAnnotation *legendAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:barPlotSpace anchorPlotPoint:plotPoint];
    legendAnnotation.contentLayer = theLegend;

    legendAnnotation.contentAnchorPoint = ( kUseHorizontalBars ? CGPointMake(1.0, 0.0) : CGPointMake(0.0, 1.0) );

    [graph.plotAreaFrame.plotArea addAnnotation:legendAnnotation];
}

#pragma mark -
#pragma mark CPTBarPlot delegate methods

-(void)plot:(CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Data label for '%@' was selected at index %d.", plot.identifier, (int)index);
}

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSNumber *value = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];

    NSLog(@"Bar for '%@' was selected at index %d. Value = %f", plot.identifier, (int)index, [value floatValue]);

    CPTGraph *graph = (self.graphs)[0];

    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
    if ( annotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor orangeColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates
    NSNumber *x = @(index);
    NSNumber *y = @2;

    NSArray *anchorPoint = (kUseHorizontalBars ? @[y, x] : @[x, y]);

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:value];

    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    annotation                = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    annotation.contentLayer   = textLayer;
    annotation.displacement   = CGPointMake(0.0, 0.0);
    self.symbolTextAnnotation = annotation;

    [graph.plotAreaFrame.plotArea addAnnotation:annotation];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 10;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id num = nil;

    if ( fieldEnum == CPTBarPlotFieldBarLocation ) {
        // location
        num = [NSString stringWithFormat:@"Cat %lu", (unsigned long)index];
    }
    else if ( fieldEnum == CPTBarPlotFieldBarTip ) {
        // length
        if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
            num = @(index);
        }
        else {
            num = @( (index + 1) * (index + 1) );
        }
    }
    else {
        // base
        if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
            num = @0;
        }
        else {
            num = @(index);
        }
    }

    return num;
}

@end
