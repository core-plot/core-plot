//
//  CompositePlot.m
//  CorePlotGallery
//

#import "CompositePlot.h"

@interface CompositePlot()

@property (nonatomic, readwrite, assign) NSInteger selectedIndex;

@property (nonatomic, readwrite, strong) CPTGraphHostingView *scatterPlotView;
@property (nonatomic, readwrite, strong) CPTGraphHostingView *barChartView;
@property (nonatomic, readwrite, strong) CPTGraphHostingView *pieChartView;

@property (nonatomic, readwrite, strong) CPTXYGraph *scatterPlot;
@property (nonatomic, readwrite, strong) CPTXYGraph *barChart;
@property (nonatomic, readwrite, strong) CPTXYGraph *pieChart;

@end

@implementation CompositePlot

@synthesize selectedIndex;
@synthesize dataForChart;
@synthesize dataForPlot;

@synthesize scatterPlotView;
@synthesize barChartView;
@synthesize pieChartView;

@synthesize scatterPlot;
@synthesize barChart;
@synthesize pieChart;

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        selectedIndex = NSNotFound;

        self.title   = @"Composite Plot";
        self.section = kDemoPlots;
    }

    return self;
}

#pragma mark -
#pragma mark Plot construction methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

-(void)setFrameSize:(NSSize)newSize
{
    self.scatterPlotView.frame = NSMakeRect( 0.0,
                                             0.0,
                                             newSize.width,
                                             newSize.height * CPTFloat(0.5) );

    self.barChartView.frame = NSMakeRect( 0.0,
                                          newSize.height * CPTFloat(0.5),
                                          newSize.width * CPTFloat(0.5),
                                          newSize.height * CPTFloat(0.5) );

    self.pieChartView.frame = NSMakeRect( newSize.width * CPTFloat(0.5),
                                          newSize.height * CPTFloat(0.5),
                                          newSize.width * CPTFloat(0.5),
                                          newSize.height * CPTFloat(0.5) );

    [self.scatterPlotView setNeedsDisplay:YES];
    [self.barChartView setNeedsDisplay:YES];
    [self.pieChartView setNeedsDisplay:YES];
}
#endif

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#else
-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#endif
{
    [self killGraph];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect viewRect = [hostingView bounds];

    self.scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake( 0.0,
                                                                                  0.0,
                                                                                  viewRect.size.width,
                                                                                  viewRect.size.height * CPTFloat(0.5) )];

    self.barChartView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake( 0.0,
                                                                               viewRect.size.height * CPTFloat(0.5),
                                                                               viewRect.size.width * CPTFloat(0.5),
                                                                               viewRect.size.height * CPTFloat(0.5) )];

    self.pieChartView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake( viewRect.size.width * CPTFloat(0.5),
                                                                               viewRect.size.height * CPTFloat(0.5),
                                                                               viewRect.size.width * CPTFloat(0.5),
                                                                               viewRect.size.height * CPTFloat(0.5) )];
#else
    NSRect viewRect = [hostingView bounds];

    self.scatterPlotView = [[CPTGraphHostingView alloc] initWithFrame:NSMakeRect( 0.0,
                                                                                  0.0,
                                                                                  viewRect.size.width,
                                                                                  viewRect.size.height * CPTFloat(0.5) )];

    self.barChartView = [[CPTGraphHostingView alloc] initWithFrame:NSMakeRect( 0.0,
                                                                               viewRect.size.height * CPTFloat(0.5),
                                                                               viewRect.size.width * CPTFloat(0.5),
                                                                               viewRect.size.height * CPTFloat(0.5) )];

    self.pieChartView = [[CPTGraphHostingView alloc] initWithFrame:NSMakeRect( viewRect.size.width * CPTFloat(0.5),
                                                                               viewRect.size.height * CPTFloat(0.5),
                                                                               viewRect.size.width * CPTFloat(0.5),
                                                                               viewRect.size.height * CPTFloat(0.5) )];

    [self.scatterPlotView setAutoresizesSubviews:YES];
    [self.scatterPlotView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    [self.barChartView setAutoresizesSubviews:YES];
    [self.barChartView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

    [self.pieChartView setAutoresizesSubviews:YES];
    [self.pieChartView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#endif

    [hostingView addSubview:self.scatterPlotView];
    [hostingView addSubview:self.barChartView];
    [hostingView addSubview:self.pieChartView];

    [self renderScatterPlotInHostingView:self.scatterPlotView withTheme:theme];
    [self renderBarPlotInHostingView:self.barChartView withTheme:theme];
    [self renderPieChartInHostingView:self.pieChartView withTheme:theme];
}

-(void)killGraph
{
    self.scatterPlotView.hostedGraph = nil;
    self.barChartView.hostedGraph    = nil;
    self.pieChartView.hostedGraph    = nil;

    [self.scatterPlotView removeFromSuperview];
    [self.barChartView removeFromSuperview];
    [self.pieChartView removeFromSuperview];

    self.scatterPlotView = nil;
    self.barChartView    = nil;
    self.pieChartView    = nil;

    [super killGraph];
}

-(void)renderScatterPlotInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme
{
    // Create graph from theme
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    CGRect bounds = self.scatterPlotView.bounds;
#else
    CGRect bounds = NSRectToCGRect(self.scatterPlotView.bounds);
#endif

    self.scatterPlot = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:self.scatterPlot toHostingView:hostingView];

    [self applyTheme:theme toGraph:self.scatterPlot withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    self.scatterPlot.paddingLeft   = 10.0;
    self.scatterPlot.paddingTop    = 10.0;
    self.scatterPlot.paddingRight  = 10.0;
    self.scatterPlot.paddingBottom = 10.0;

    self.scatterPlot.plotAreaFrame.plotArea.delegate = self;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.scatterPlot.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(2.0)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.0) length:CPTDecimalFromDouble(3.0)];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.scatterPlot.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
    x.minorTicksPerInterval       = 2;
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.99) length:CPTDecimalFromDouble(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.99) length:CPTDecimalFromDouble(0.02)],
                                 [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.99) length:CPTDecimalFromDouble(0.02)]];
    x.labelExclusionRanges = exclusionRanges;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(2.0);
    exclusionRanges               = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(1.99) length:CPTDecimalFromDouble(0.02)],
                                      [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.99) length:CPTDecimalFromDouble(0.02)],
                                      [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(3.99) length:CPTDecimalFromDouble(0.02)]];
    y.labelExclusionRanges = exclusionRanges;

    // Create a blue plot area
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.identifier = @"Blue Plot";

    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 3.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.dataSource    = self;
    [self.scatterPlot addPlot:boundLinePlot];

    // Do a blue gradient
    CPTColor *areaColor1       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(0.3) blue:CPTFloat(1.0) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient1 = [CPTGradient gradientWithBeginningColor:areaColor1 endingColor:[CPTColor clearColor]];
    areaGradient1.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient1];
    boundLinePlot.areaFill      = areaGradientFill;
    boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
    boundLinePlot.delegate      = self;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;

    // Create a green plot area
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Green Plot";

    lineStyle             = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth   = 3.0;
    lineStyle.lineColor   = [CPTColor greenColor];
    lineStyle.dashPattern = @[@5, @5];

    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource    = self;

    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(0.3) green:CPTFloat(1.0) blue:CPTFloat(0.3) alpha:CPTFloat(0.8)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle               = -90.0;
    areaGradientFill                 = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(1.75);

    // Animate in the new plot, as an example
    dataSourceLinePlot.opacity = 1.0;
    [self.scatterPlot addPlot:dataSourceLinePlot];

    // Add some initial data
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:100];
    for ( NSUInteger i = 0; i < 60; i++ ) {
        NSNumber *xVal = @(1 + i * 0.05);
        NSNumber *yVal = @(1.2 * arc4random() / (double)UINT32_MAX + 1.2);
        [contentArray addObject:@{ @"x": xVal, @"y": yVal }
        ];
    }
    self.dataForPlot = contentArray;
}

-(void)renderBarPlotInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    BOOL drawAxis = YES;
    if ( bounds.size.width < 200.0 ) {
        drawAxis = NO;
    }

    self.barChart = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:self.barChart toHostingView:hostingView];
    [self applyTheme:theme toGraph:self.barChart withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    self.barChart.plotAreaFrame.masksToBorder = NO;

    if ( drawAxis ) {
        self.barChart.paddingLeft   = 70.0;
        self.barChart.paddingTop    = 20.0;
        self.barChart.paddingRight  = 20.0;
        self.barChart.paddingBottom = 80.0;
    }
    else {
        [self setPaddingDefaultsForGraph:self.barChart withBounds:bounds];
    }

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(17.0f)];

    if ( drawAxis ) {
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.barChart.axisSet;
        CPTXYAxis *x          = axisSet.xAxis;
        x.axisLineStyle               = nil;
        x.majorTickLineStyle          = nil;
        x.minorTickLineStyle          = nil;
        x.majorIntervalLength         = CPTDecimalFromDouble(5.0);
        x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
        x.title                       = @"X Axis";
        x.titleLocation               = CPTDecimalFromFloat(7.5f);
        x.titleOffset                 = 55.0;

        // Define some custom labels for the data elements
        x.labelRotation  = CPTFloat(M_PI_4);
        x.labelingPolicy = CPTAxisLabelingPolicyNone;
        NSArray *customTickLocations = @[@1, @5, @10, @15];
        NSArray *xAxisLabels         = @[@"Label A", @"Label B", @"Label C", @"Label D"];
        NSUInteger labelLocation     = 0;
        NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
        for ( NSNumber *tickLocation in customTickLocations ) {
            CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:xAxisLabels[labelLocation++] textStyle:x.labelTextStyle];
            newLabel.tickLocation = [tickLocation decimalValue];
            newLabel.offset       = x.labelOffset + x.majorTickLength;
            newLabel.rotation     = CPTFloat(M_PI_4);
            [customLabels addObject:newLabel];
        }

        x.axisLabels = customLabels;

        CPTXYAxis *y = axisSet.yAxis;
        y.axisLineStyle               = nil;
        y.majorTickLineStyle          = nil;
        y.minorTickLineStyle          = nil;
        y.majorIntervalLength         = CPTDecimalFromDouble(50.0);
        y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
        y.title                       = @"Y Axis";
        y.titleOffset                 = 45.0;
        y.titleLocation               = CPTDecimalFromFloat(150.0f);
    }

    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    barPlot.dataSource = self;
    barPlot.identifier = @"Bar Plot 1";
    [self.barChart addPlot:barPlot toPlotSpace:plotSpace];

    // Second bar plot
    barPlot                 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.barOffset       = CPTDecimalFromFloat(0.25f); // 25% offset, 75% overlap
    barPlot.barCornerRadius = 2.0;
    barPlot.identifier      = @"Bar Plot 2";
    barPlot.delegate        = self;
    [self.barChart addPlot:barPlot toPlotSpace:plotSpace];
}

-(void)renderPieChartInHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    self.pieChart = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:self.pieChart toHostingView:hostingView];
    [self applyTheme:theme toGraph:self.pieChart withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    self.pieChart.plotAreaFrame.masksToBorder = NO;

    [self setPaddingDefaultsForGraph:self.pieChart withBounds:bounds];

    self.pieChart.axisSet = nil;

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN( CPTFloat(0.7) * (hostingView.frame.size.height - CPTFloat(2.0) * self.pieChart.paddingLeft) / CPTFloat(2.0),
                              CPTFloat(0.7) * (hostingView.frame.size.width - CPTFloat(2.0) * self.pieChart.paddingTop) / CPTFloat(2.0) );
    piePlot.identifier      = @"Pie Chart 1";
    piePlot.startAngle      = CPTFloat(M_PI_4);
    piePlot.sliceDirection  = CPTPieDirectionCounterClockwise;
    piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    //piePlot.sliceLabelOffset = 5.0;
    [self.pieChart addPlot:piePlot];

    // Add some initial data
    self.dataForChart = [@[@20.0, @30.0, @60.0] mutableCopy];
}

#pragma mark -
#pragma mark CPTBarPlot delegate

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"barWasSelectedAtRecordIndex %d", (int)index);
}

#pragma mark -
#pragma mark CPTScatterPlot delegate

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    if ( [(NSString *)plot.identifier isEqualToString : @"Blue Plot"] ) {
        self.selectedIndex = (NSInteger)index;
    }
}

#pragma mark -
#pragma mark Plot area delegate

-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea
{
    CPTGraph *theGraph = plotArea.graph;

    if ( [theGraph isEqual:self.scatterPlot] ) {
        self.selectedIndex = NSNotFound;
    }
}

#pragma mark -
#pragma mark Plot Data Source

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot isKindOfClass:[CPTPieChart class]] ) {
        return [self.dataForChart count];
    }
    else if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        return 16;
    }
    else {
        return self.dataForPlot.count;
    }
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;

    if ( [plot isKindOfClass:[CPTPieChart class]] ) {
        if ( index >= [self.dataForChart count] ) {
            return nil;
        }

        if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
            return (self.dataForChart)[index];
        }
        else {
            return @(index);
        }
    }
    else if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = @(index);
                break;

            case CPTBarPlotFieldBarTip:
                num = @( (index + 1) * (index + 1) );
                if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
                    num = @(num.integerValue - 10);
                }
                break;
        }
    }
    else {
        NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
        num = self.dataForPlot[index][key];

        // Green plot gets shifted above the blue
        if ( [(NSString *)plot.identifier isEqualToString : @"Green Plot"] ) {
            if ( fieldEnum == CPTScatterPlotFieldY ) {
                num = @([num doubleValue] + 1.0);
            }
        }
    }

    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        whiteText = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
    });

    CPTTextLayer *newLayer = nil;

    switch ( index ) {
        case 0:
            newLayer = (id)[NSNull null];
            break;

        case 1:
            newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                    style:[CPTTextStyle textStyle]];
            break;

        default:
            newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)index]
                                                    style:whiteText];
            break;
    }

    return newLayer;
}

-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTPlotSymbol *redDot = nil;
    static dispatch_once_t onceToken;

    CPTPlotSymbol *symbol = nil; // Use the default symbol

    if ( [(NSString *)plot.identifier isEqualToString : @"Blue Plot"] && ( (NSInteger)index == self.selectedIndex ) ) {
        dispatch_once(&onceToken, ^{
            redDot = [[CPTPlotSymbol alloc] init];
            redDot.symbolType = CPTPlotSymbolTypeEllipse;
            redDot.size = CGSizeMake(10.0, 10.0);
            redDot.fill = [CPTFill fillWithColor:[CPTColor redColor]];
            redDot.lineStyle = [CPTLineStyle lineStyle];
        });

        symbol = redDot;
    }

    return symbol;
}

#pragma mark -
#pragma mark UIViewController Methods

#if TARGET_OS_IPHONE
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UIInterfaceOrientationIsLandscape(fromInterfaceOrientation) ) {
        // Move the plots into place for portrait
        self.scatterPlotView.frame = CGRectMake(20.0, 55.0, 728.0, 556.0);
        self.barChartView.frame    = CGRectMake(20.0, 644.0, 340.0, 340.0);
        self.pieChartView.frame    = CGRectMake(408.0, 644.0, 340.0, 340.0);
    }
    else {
        // Move the plots into place for landscape
        self.scatterPlotView.frame = CGRectMake(20.0, 51.0, 628.0, 677.0);
        self.barChartView.frame    = CGRectMake(684.0, 51.0, 320.0, 320.0);
        self.pieChartView.frame    = CGRectMake(684.0, 408.0, 320.0, 320.0);
    }
}
#endif

#pragma mark -
#pragma mark Accessors

-(void)setSelectedIndex:(NSInteger)newIndex
{
    if ( newIndex != selectedIndex ) {
        NSInteger oldIndex = selectedIndex;

        selectedIndex = newIndex;

        CPTScatterPlot *thePlot = (CPTScatterPlot *)[self.scatterPlot plotWithIdentifier:@"Blue Plot"];
        if ( oldIndex != NSNotFound ) {
            [thePlot reloadPlotSymbolsInIndexRange:NSMakeRange( (NSUInteger)oldIndex, 1 )];
        }
        if ( newIndex != NSNotFound ) {
            [thePlot reloadPlotSymbolsInIndexRange:NSMakeRange( (NSUInteger)newIndex, 1 )];
        }
    }
}

@end
