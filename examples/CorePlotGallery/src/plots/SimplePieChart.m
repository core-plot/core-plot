//
//  SimplePieChart.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "SimplePieChart.h"

@implementation SimplePieChart

+ (void)load
{
    [super registerPlotItem:self];
}

- (id)init
{
	if ((self = [super init])) {
        title = @"Simple Pie Chart";
    }

    return self;
}

- (void)killGraph
{
    [super killGraph];
}

- (void)dealloc
{
    [plotData release];
    [super dealloc];
}

- (void)generateData
{
    if (plotData == nil) {
        plotData = [[NSMutableArray alloc] initWithObjects:
                    [NSNumber numberWithDouble:20.0],
                    [NSNumber numberWithDouble:30.0],
                    [NSNumber numberWithDouble:60.0],
                    nil];
    }
}

- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:NSRectToCGRect([layerHostingView bounds])] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.title = title;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = bounds.size.height / 20.0f;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, bounds.size.height / 18.0f);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;

    graph.plotAreaFrame.masksToBorder = NO;

    // Graph padding
    CGFloat boundsPadding = bounds.size.width / 20.0f;
    graph.paddingLeft = boundsPadding;
    graph.paddingTop = graph.titleDisplacement.y * 2;
    graph.paddingRight = boundsPadding;
    graph.paddingBottom = boundsPadding;

    graph.axisSet = nil;
    
    // Overlay gradient for pie chart
    CPTGradient *overlayGradient = [[[CPTGradient alloc] init] autorelease];
    overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.0];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.3] atPosition:0.9];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.7] atPosition:1.0];

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                            0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
    piePlot.identifier = title;
    piePlot.startAngle = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    piePlot.overlayFill = [CPTFill fillWithGradient:overlayGradient];

    piePlot.delegate = self;
    [graph addPlot:piePlot];
    [piePlot release];

	// Add legend
	CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
	theLegend.numberOfColumns = 1;
	theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
	theLegend.borderLineStyle = [CPTLineStyle lineStyle];
	theLegend.cornerRadius = 5.0;
	
	graph.legend = theLegend;

	graph.legendAnchor = CPTRectAnchorRight;
	graph.legendDisplacement = CGPointMake(-boundsPadding - 10.0, 0.0);
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;

    if ( !whiteText ) {
        whiteText = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
    }

    CPTTextLayer *newLayer = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%3.0f", [[plotData objectAtIndex:index] floatValue]]
                                                         style:whiteText] autorelease];
    return newLayer;
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Slice was selected at index %d. Value = %f", (int)index, [[plotData objectAtIndex:index] floatValue]);
	
	NSMutableArray *newData = [[NSMutableArray alloc] init];
	NSUInteger dataCount = ceil(10.0 * rand() / (double)RAND_MAX) + 1;
	for ( NSUInteger i = 1; i < dataCount; i++ ) {
		[newData addObject:[NSNumber numberWithDouble:100.0 * rand() / (double)RAND_MAX]];
	}
	NSLog(@"newData: %@", newData);
	
	[plotData release];
	plotData = newData;
		 
	[plot reloadData];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;
    if (fieldEnum == CPTPieChartFieldSliceWidth) {
        num = [plotData objectAtIndex:index];
    }
    else {
        return [NSNumber numberWithInt:index];
    }

    return num;
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
	return [NSString stringWithFormat:@"Pie Slice %u", index];
}

@end
