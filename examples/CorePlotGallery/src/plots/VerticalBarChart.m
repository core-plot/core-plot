//
//  SimpleBarGraph.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//


#import "VerticalBarChart.h"

@implementation VerticalBarChart

+ (void)load
{
    [super registerPlotItem:self];
}

- (id)init
{
    if (self = [super init]) {
        title = @"Vertical Bar Chart";
    }

	return self;
}

- (void)killGraph
{
    if ([graphs count]) {		
        CPGraph *graph = [graphs objectAtIndex:0];

        if (symbolTextAnnotation) {
            [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
            [symbolTextAnnotation release];
            symbolTextAnnotation = nil;
        }
    }

	[super killGraph];
}

- (void)generateData
{
}

#define HORIZONTAL 0

- (void)renderInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    CPGraph *graph = [[CPXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTheme themeNamed:kCPDarkGradientTheme]];

	[self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];

    // Add plot space for bar charts
    CPXYPlotSpace *barPlotSpace = [[[CPXYPlotSpace alloc] init] autorelease];
#if HORIZONTAL
    barPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-10.0f) length:CPDecimalFromFloat(120.0f)];
    barPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0f) length:CPDecimalFromFloat(11.0f)];
#else
    barPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0f) length:CPDecimalFromFloat(11.0f)];
    barPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-10.0f) length:CPDecimalFromFloat(120.0f)];
#endif
    [graph addPlotSpace:barPlotSpace];


    // Create grid line styles
    CPMutableLineStyle *majorGridLineStyle = [CPMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.0f;
    majorGridLineStyle.lineColor = [[CPColor whiteColor] colorWithAlphaComponent:0.75];

    CPMutableLineStyle *minorGridLineStyle = [CPMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 1.0f;
    minorGridLineStyle.lineColor = [[CPColor whiteColor] colorWithAlphaComponent:0.25];    

	// Create axes
    CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    CPXYAxis *x = axisSet.xAxis;
	{
#if HORIZONTAL
		x.majorIntervalLength = CPDecimalFromInteger(10);
		x.minorTicksPerInterval = 9;
#else
		x.majorIntervalLength = CPDecimalFromInteger(1);
		x.minorTicksPerInterval = 0;
#endif
		x.orthogonalCoordinateDecimal = CPDecimalFromInteger(0);
		x.majorGridLineStyle = majorGridLineStyle;
		x.minorGridLineStyle = minorGridLineStyle;
		x.axisLineStyle = nil;
		x.majorTickLineStyle = nil;
		x.minorTickLineStyle = nil;
		x.labelOffset = 10.0;
#if HORIZONTAL
		x.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(100.0f)];
		x.gridLinesRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-0.5f) length:CPDecimalFromFloat(10.0f)];
#else
		x.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-0.5f) length:CPDecimalFromFloat(10.0f)];
		x.gridLinesRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(100.0f)];
#endif

		x.title = @"X Axis";
		x.titleOffset = 30.0f;
#if HORIZONTAL
		x.titleLocation = CPDecimalFromInteger(55);
#else
		x.titleLocation = CPDecimalFromInteger(5);
#endif

		x.plotSpace = barPlotSpace;
	}
	
    CPXYAxis *y = axisSet.yAxis;
	{
#if HORIZONTAL
		y.majorIntervalLength = CPDecimalFromInteger(1);
		y.minorTicksPerInterval = 0;
#else
		y.majorIntervalLength = CPDecimalFromInteger(10);
		y.minorTicksPerInterval = 9;
#endif
		y.orthogonalCoordinateDecimal = CPDecimalFromInteger(0);
		y.preferredNumberOfMajorTicks = 8;
		y.majorGridLineStyle = majorGridLineStyle;
		y.minorGridLineStyle = minorGridLineStyle;
		y.axisLineStyle = nil;
		y.majorTickLineStyle = nil;
		y.minorTickLineStyle = nil;
		y.labelOffset = 10.0;
		y.labelRotation = M_PI/2;
#if HORIZONTAL
		y.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-0.5f) length:CPDecimalFromFloat(10.0f)];
		y.gridLinesRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(100.0f)];
#else
		y.visibleRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.0f) length:CPDecimalFromFloat(100.0f)];
		y.gridLinesRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-0.5f) length:CPDecimalFromFloat(10.0f)];
#endif

		y.title = @"Y Axis";
		y.titleOffset = 30.0f;
#if HORIZONTAL
		y.titleLocation = CPDecimalFromInteger(5);
#else
		y.titleLocation = CPDecimalFromInteger(55);
#endif

		y.plotSpace = barPlotSpace;
	}

    // Set axes
    graph.axisSet.axes = [NSArray arrayWithObjects:x, y, nil];

	// Create a bar line style
	CPMutableLineStyle *barLineStyle = [[[CPMutableLineStyle alloc] init] autorelease];
	barLineStyle.lineWidth = 1.0;
	barLineStyle.lineColor = [CPColor whiteColor];

    // Create first bar plot
	CPBarPlot *barPlot = [[[CPBarPlot alloc] init] autorelease];
	barPlot.lineStyle = barLineStyle;
	barPlot.fill = [CPFill fillWithColor:[CPColor colorWithComponentRed:1.0f green:0.0f blue:0.5f alpha:0.5f]];
	barPlot.barBasesVary = YES;
    barPlot.barWidth = 0.5; // bar is 50% of the available space
	barPlot.barCornerRadius = 10.0f;
#if HORIZONTAL
	barPlot.barsAreHorizontal = YES;
#else
	barPlot.barsAreHorizontal = NO;
#endif

    CPMutableTextStyle *whiteTextStyle = [CPMutableTextStyle textStyle];
    whiteTextStyle.color = [CPColor whiteColor];
    barPlot.barLabelTextStyle = whiteTextStyle;
 
	barPlot.delegate = self;
    barPlot.dataSource = self;
    barPlot.identifier = @"Bar Plot 1";

    [graph addPlot:barPlot toPlotSpace:barPlotSpace];


    // Create second bar plot
    CPBarPlot *barPlot2 = [CPBarPlot tubularBarPlotWithColor:[CPColor blueColor] horizontalBars:NO];

	barPlot2.lineStyle = barLineStyle;
	barPlot2.fill = [CPFill fillWithColor:[CPColor colorWithComponentRed:0.0f green:1.0f blue:0.5f alpha:0.5f]];
	barPlot2.barBasesVary = YES;

	barPlot2.barWidth = 1.0f; // bar is full (100%) width
//	barPlot2.barOffset = -0.125f; // shifted left by 12.5%
    barPlot2.barCornerRadius = 2.0f;
#if HORIZONTAL
	barPlot2.barsAreHorizontal = YES;
#else
	barPlot2.barsAreHorizontal = NO;
#endif
    barPlot2.delegate = self;
	barPlot2.dataSource = self;
    barPlot2.identifier = @"Bar Plot 2";

    [graph addPlot:barPlot2 toPlotSpace:barPlotSpace];
}

- (void)dealloc
{
    [plotData release];
    [super dealloc];
}

-(CPFill *)barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    return nil;
}

-(CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index 
{
    return nil;
}

#pragma mark -
#pragma mark CPBarPlot delegate method

-(void)barPlot:(CPBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSNumber *value = [self numberForPlot:plot field:CPBarPlotFieldBarLength recordIndex:index];

    NSLog(@"bar was selected at index %d. Value = %f", (int)index, [value floatValue]);

    CPGraph *graph = [graphs objectAtIndex:0];

    if ( symbolTextAnnotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:symbolTextAnnotation];
        symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPMutableTextStyle *hitAnnotationTextStyle = [CPMutableTextStyle textStyle];
    hitAnnotationTextStyle.color = [CPColor orangeColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x = [NSNumber numberWithInt:index];
    NSNumber *y = [NSNumber numberWithInt:2]; //[self numberForPlot:plot field:0 recordIndex:index];
#if HORIZONTAL
    NSArray *anchorPoint = [NSArray arrayWithObjects:y, x, nil];
#else
    NSArray *anchorPoint = [NSArray arrayWithObjects:x, y, nil];
#endif

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:value];
    
    // Now add the annotation to the plot area
    CPTextLayer *textLayer = [[[CPTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle] autorelease];
    symbolTextAnnotation = [[CPPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    symbolTextAnnotation.contentLayer = textLayer;
    symbolTextAnnotation.displacement = CGPointMake(0.0f, 0.0f);

    [graph.plotAreaFrame.plotArea addAnnotation:symbolTextAnnotation];    
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return 10;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{

    NSNumber *num = nil;
	if (fieldEnum == CPBarPlotFieldBarLocation) {
		// location
		if ([plot.identifier isEqual:@"Bar Plot 2"]) {
			num = [NSDecimalNumber numberWithInt:index];
		}
		else {
			num = [NSDecimalNumber numberWithInt:index];
		}
	}
	else if (fieldEnum == CPBarPlotFieldBarLength) {
		// length
		if ([plot.identifier isEqual:@"Bar Plot 2"]) {
			num = [NSDecimalNumber numberWithInt:index];
		}
		else {
			num = [NSDecimalNumber numberWithInt:(index+1)*(index+1)];
		}

	}
	else {
		// base
		if ([plot.identifier isEqual:@"Bar Plot 2"]) {
			num = [NSDecimalNumber numberWithInt:0];
		}
		else {
			num = [NSDecimalNumber numberWithInt:index];
		}
	}

	NSLog(@"identifier = %@, field = %ld, index = %ld -> %@", plot.identifier, fieldEnum, index, num);

    return num;
}

@end
