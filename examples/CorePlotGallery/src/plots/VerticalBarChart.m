//
//  SimpleBarGraph.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "VerticalBarChart.h"

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

#define HORIZONTAL 0

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    graph.plotAreaFrame.masksToBorder = NO;
#if HORIZONTAL
    graph.plotAreaFrame.paddingBottom += CPTFloat(30.0);
#else
    graph.plotAreaFrame.paddingLeft += CPTFloat(30.0);
#endif

    // Add plot space for bar charts
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];
    [barPlotSpace setScaleType:CPTScaleTypeCategory forCoordinate:CPTCoordinateX];
#if HORIZONTAL
    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-10.0) length:@120.0];
    barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@11.0];
#else
    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@11.0];
    barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-10.0) length:@120.0];
#endif
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
#if HORIZONTAL
        x.majorIntervalLength   = @10.0;
        x.minorTicksPerInterval = 9;
        x.orthogonalPosition    = @(-0.5);
#else
        x.majorIntervalLength   = @1.0;
        x.minorTicksPerInterval = 0;
        x.orthogonalPosition    = @0.0;
#endif
        x.majorGridLineStyle = majorGridLineStyle;
        x.minorGridLineStyle = minorGridLineStyle;
        x.axisLineStyle      = nil;
        x.majorTickLineStyle = nil;
        x.minorTickLineStyle = nil;
        x.labelOffset        = 10.0;
#if HORIZONTAL
        x.visibleRange   = [CPTPlotRange plotRangeWithLocation:@0.0 length:@100.0];
        x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:@(-0.5) length:@10.0];
#else
        x.visibleRange   = [CPTPlotRange plotRangeWithLocation:@(-0.5) length:@10.0];
        x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@100.0];
#endif

        x.title       = @"X Axis";
        x.titleOffset = 30.0;
#if HORIZONTAL
        x.titleLocation = @55.0;
#else
        x.titleLocation = @5.0;
#endif

        x.plotSpace = barPlotSpace;
    }

    CPTXYAxis *y = axisSet.yAxis;
    {
#if HORIZONTAL
        y.majorIntervalLength   = @1.0;
        y.minorTicksPerInterval = 0;
        y.orthogonalPosition    = @0.0;
#else
        y.majorIntervalLength   = @10.0;
        y.minorTicksPerInterval = 9;
        y.orthogonalPosition    = @(-0.5);
#endif
        y.preferredNumberOfMajorTicks = 8;
        y.majorGridLineStyle          = majorGridLineStyle;
        y.minorGridLineStyle          = minorGridLineStyle;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = nil;
        y.minorTickLineStyle          = nil;
        y.labelOffset                 = 10.0;
        y.labelRotation               = CPTFloat(M_PI_2);
#if HORIZONTAL
        y.visibleRange   = [CPTPlotRange plotRangeWithLocation:@(-0.5) length:@10.0];
        y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@100.0];
#else
        y.visibleRange   = [CPTPlotRange plotRangeWithLocation:@0.0 length:@100.0];
        y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:@(-0.5) length:@10.0];
#endif

        y.title       = @"Y Axis";
        y.titleOffset = 30.0;
#if HORIZONTAL
        y.titleLocation = @5.0;
#else
        y.titleLocation = @55.0;
#endif

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
    barPlot.barWidth        = @0.5; // bar is 50% of the available space
    barPlot.barCornerRadius = 10.0;
#if HORIZONTAL
    barPlot.barsAreHorizontal = YES;
#else
    barPlot.barsAreHorizontal = NO;
#endif

    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color   = [CPTColor whiteColor];
    barPlot.labelTextStyle = whiteTextStyle;

    barPlot.delegate   = self;
    barPlot.dataSource = self;
    barPlot.identifier = @"Bar Plot 1";

    [graph addPlot:barPlot toPlotSpace:barPlotSpace];

// Create second bar plot
    CPTBarPlot *barPlot2 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];

    barPlot2.lineStyle    = barLineStyle;
    barPlot2.fill         = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0 green:1.0 blue:0.5 alpha:0.5]];
    barPlot2.barBasesVary = YES;

    barPlot2.barWidth = @1.0; // bar is full (100%) width
//	barPlot2.barOffset = -0.125; // shifted left by 12.5%
    barPlot2.barCornerRadius = 2.0;
#if HORIZONTAL
    barPlot2.barsAreHorizontal = YES;
#else
    barPlot2.barsAreHorizontal = NO;
#endif
    barPlot2.delegate   = self;
    barPlot2.dataSource = self;
    barPlot2.identifier = @"Bar Plot 2";

    [graph addPlot:barPlot2 toPlotSpace:barPlotSpace];

// Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfRows    = 2;
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor colorWithGenericGray:CPTFloat(0.15)]];
    theLegend.borderLineStyle = barLineStyle;
    theLegend.cornerRadius    = 10.0;
    theLegend.swatchSize      = CGSizeMake(20.0, 20.0);
    whiteTextStyle.fontSize   = 16.0;
    theLegend.textStyle       = whiteTextStyle;
    theLegend.rowMargin       = 10.0;
    theLegend.paddingLeft     = 12.0;
    theLegend.paddingTop      = 12.0;
    theLegend.paddingRight    = 12.0;
    theLegend.paddingBottom   = 12.0;

#if HORIZONTAL
    NSArray *plotPoint = @[@95, @0];
#else
    NSArray *plotPoint = @[@0, @95];
#endif
    CPTPlotSpaceAnnotation *legendAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:barPlotSpace anchorPlotPoint:plotPoint];
    legendAnnotation.contentLayer = theLegend;

#if HORIZONTAL
    legendAnnotation.contentAnchorPoint = CGPointMake(1.0, 0.0);
#else
    legendAnnotation.contentAnchorPoint = CGPointMake(0.0, 1.0);
#endif
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
    NSNumber *y = @2; //[self numberForPlot:plot field:0 recordIndex:index];
#if HORIZONTAL
    NSArray *anchorPoint = @[y, x];
#else
    NSArray *anchorPoint = @[x, y];
#endif
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
