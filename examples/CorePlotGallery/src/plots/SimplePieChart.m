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
	if (self = [super init]) {
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

- (void)renderInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme
{
#if TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    CPGraph *graph = [[[CPXYGraph alloc] initWithFrame:[layerHostingView bounds]] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTheme themeNamed:kCPDarkGradientTheme]];

    graph.title = title;
    CPTextStyle *textStyle = [CPTextStyle textStyle];
    textStyle.color = [CPColor grayColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = bounds.size.height / 20.0f;
    graph.titleTextStyle = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, bounds.size.height / 18.0f);
    graph.titlePlotAreaFrameAnchor = CPRectAnchorTop;

    graph.plotAreaFrame.masksToBorder = NO;

    // Graph padding
    float boundsPadding = bounds.size.width / 20.0f;
    graph.paddingLeft = boundsPadding;
    graph.paddingTop = graph.titleDisplacement.y * 2;
    graph.paddingRight = boundsPadding;
    graph.paddingBottom = boundsPadding;

    graph.axisSet = nil;

    // Add pie chart
    CPPieChart *piePlot = [[CPPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                            0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
    piePlot.identifier = title;
    piePlot.startAngle = M_PI_4;
    piePlot.sliceDirection = CPPieDirectionCounterClockwise;
    piePlot.delegate = self;
    [graph addPlot:piePlot];
    [piePlot release];

    [self generateData];
}

-(CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTextStyle *whiteText = nil;

    if (!whiteText) {
        whiteText = [[CPTextStyle alloc] init];
        whiteText.color = [CPColor whiteColor];
    }

    CPTextLayer *newLayer = [[[CPTextLayer alloc] initWithText:[NSString stringWithFormat:@"%3.0f", [[plotData objectAtIndex:index] floatValue]]
                                                         style:whiteText] autorelease];
    return newLayer;
}

-(void)pieChart:(CPPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Slice was selected at index %d. Value = %f", (int)index, [[plotData objectAtIndex:index] floatValue]);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return [plotData count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;
    if (fieldEnum == CPPieChartFieldSliceWidth) {
        num = [plotData objectAtIndex:index];
    }
    else {
        return [NSNumber numberWithInt:index];
    }

    return num;
}

@end
