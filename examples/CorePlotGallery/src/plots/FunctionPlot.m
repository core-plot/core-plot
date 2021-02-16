#import "FunctionPlot.h"

#import "PiNumberFormatter.h"

@interface FunctionPlot()

@property (nonatomic, readwrite, strong) NSMutableSet<CPTFunctionDataSource *> *dataSources;
@property (nonatomic, readwrite, strong) CPTMutableTextStyle *textStyle;
@property (nonatomic, readwrite, strong) PiNumberFormatter *formatter;

-(nullable CPTNativeFont *)italicFontForFont:(nonnull CPTNativeFont *)oldFont;

@end

#pragma mark -

@implementation FunctionPlot

@synthesize dataSources;
@synthesize textStyle;
@synthesize formatter;

#pragma mark -

+(void)load
{
    [super registerPlotItem:self];
}

#pragma mark -

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        dataSources = [[NSMutableSet alloc] init];

        self.title   = @"Math Function Plot";
        self.section = kLinePlots;
    }

    return self;
}

-(void)killGraph
{
    [self.dataSources removeAllObjects];

    [super killGraph];
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL __unused)animated
{
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingLeft += self.titleSize * CPTFloat(2.25);

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.xRange                = [CPTPlotRange plotRangeWithLocation:@0.0 length:@(2.0 * M_PI)];
    plotSpace.yRange                = [CPTPlotRange plotRangeWithLocation:@(-1.1) length:@2.2];

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];

    // Axes
    self.formatter = [[PiNumberFormatter alloc] init];
    self.formatter.multiplier = @4;

    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @(M_PI_4);
    x.minorTicksPerInterval = 3;
    x.labelFormatter        = self.formatter;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.5];

    x.title       = @"X Axis";
    x.titleOffset = self.titleSize * CPTFloat(1.25);

    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval       = 4;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.labelOffset                 = 2.0;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];

    y.title       = @"Y Axis";
    y.titleOffset = self.titleSize * CPTFloat(1.25);
    
    // Labels TextSyles
    UIFont *textFont = [UIFont fontWithName:@"Helvetica" size: 10.0];
    self.textStyle = [[CPTMutableTextStyle alloc] init];
    self.textStyle.font = textFont;
    self.textStyle.textAlignment = CPTTextAlignmentLeft;

    // Create some function plots
    for ( NSUInteger plotNum = 0; plotNum < 3; plotNum++ ) {
        NSString *titleString          = nil;
        CPTDataSourceFunction function = NULL;
        CPTDataSourceBlock block       = nil;
        CPTColor *lineColor            = nil;

        switch ( plotNum ) {
            case 0:
                titleString = NSLocalizedString(@"y = sin(x)", @"y = sin(x)");
                function    = &sin;
                lineColor   = [CPTColor redColor];
                break;

            case 1:
                titleString = NSLocalizedString(@"y = cos(x)", @"y = cos(x)");
                block       = ^(double xVal) {
                    return cos(xVal);
                };
                lineColor = [CPTColor greenColor];
                break;

            case 2:
                titleString = NSLocalizedString(@"y = tan(x)", @"y = tan(x)");
                block       = ^(double xVal) {
                    double f = tan(xVal);
                    if (f > 3.0 || f < -3.0) {
                        double nan = (double)NAN;
                        return nan;
                    }
                    else {
                        return tan(xVal);
                    }
                };
                lineColor   = [CPTColor blueColor];
                break;
        }

        CPTScatterPlot *linePlot = [[CPTScatterPlot alloc] init];
        linePlot.identifier = [NSString stringWithFormat:@"Function Plot %lu", (unsigned long)(plotNum + 1)];

        CPTDictionary *textAttributes = x.titleTextStyle.attributes;

        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:titleString
                                                                                  attributes:textAttributes];

        CPTNativeFont *fontAttribute = textAttributes[NSFontAttributeName];
        if ( fontAttribute ) {
            CPTNativeFont *italicFont = [self italicFontForFont:fontAttribute];

            [title addAttribute:NSFontAttributeName
                          value:italicFont
                          range:NSMakeRange(0, 1)];
            [title addAttribute:NSFontAttributeName
                          value:italicFont
                          range:NSMakeRange(8, 1)];
        }

        CPTNativeFont *labelFont = [CPTNativeFont fontWithName:@"Helvetica" size:self.titleSize * CPTFloat(0.5)];
        [title addAttribute:NSFontAttributeName
                      value:labelFont
                      range:NSMakeRange(0, title.length)];

        linePlot.attributedTitle = title;

        CPTMutableLineStyle *lineStyle = [linePlot.dataLineStyle mutableCopy];
        lineStyle.lineWidth    = 3.0;
        lineStyle.lineColor    = lineColor;
        linePlot.dataLineStyle = lineStyle;

        linePlot.alignsPointsToPixels = NO;

        CPTFunctionDataSource *plotDataSource = nil;

        if ( function ) {
            plotDataSource = [CPTFunctionDataSource dataSourceForPlot:linePlot withFunction:function];
        }
        else {
            plotDataSource = [CPTFunctionDataSource dataSourceForPlot:linePlot withBlock:block];
        }

        plotDataSource.resolution = 2.0;

        [self.dataSources addObject:plotDataSource];
        
        linePlot.appearanceDataSource = self;

        [graph addPlot:linePlot];
    }

    // Restrict y range to a global range
    CPTPlotRange *globalYRange = [CPTPlotRange plotRangeWithLocation:@(-2.5)
                                                              length:@5.0];
    plotSpace.globalYRange = globalYRange;

    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legend.numberOfRows    = 1;
    graph.legend.delegate        = self;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake(0.0, self.titleSize * CPTFloat(1.25));
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(nullable UIFont *)italicFontForFont:(nonnull UIFont *)oldFont
{
    NSString *italicName = nil;

    CPTStringArray *fontNames = [UIFont fontNamesForFamilyName:oldFont.familyName];

    for ( NSString *fontName in fontNames ) {
        NSString *upperCaseFontName = fontName.uppercaseString;
        if ( [upperCaseFontName rangeOfString:@"ITALIC"].location != NSNotFound ) {
            italicName = fontName;
            break;
        }
    }
    if ( !italicName ) {
        for ( NSString *fontName in fontNames ) {
            NSString *upperCaseFontName = fontName.uppercaseString;
            if ( [upperCaseFontName rangeOfString:@"OBLIQUE"].location != NSNotFound ) {
                italicName = fontName;
                break;
            }
        }
    }

    UIFont *italicFont = nil;

    if ( italicName ) {
        italicFont = [UIFont fontWithName:italicName
                                     size:oldFont.pointSize];
    }
    return italicFont;
}

#else
-(nullable NSFont *)italicFontForFont:(nonnull NSFont *)oldFont
{
    return [[NSFontManager sharedFontManager] convertFont:oldFont
                                              toHaveTrait:NSFontItalicTrait];
}

#endif

#pragma  mark - Data Label Source

-(nullable CPTLayer *)dataLabelForPlot:(nonnull CPTPlot *)plot recordIndex:(NSUInteger)idx {
    CPTTextLayer *labelLayer = nil;
    if( idx % 20  == 0.0 ) {
        double x = [plot cachedDoubleForField:CPTScatterPlotFieldX recordIndex:idx];
        double y = [plot cachedDoubleForField:CPTScatterPlotFieldY recordIndex:idx];
        
        self.formatter.multiplier = @32;
        NSString *theta = [self.formatter stringFromNumber:[NSNumber numberWithDouble:x]];
        NSString *annotationString = [NSString stringWithFormat:@"%@\n%0.3f", theta, y];
        self.formatter.multiplier = @4;
        
        CPTMutableTextStyle *plotTextStyle = [self.textStyle mutableCopy];
        plotTextStyle.color = ((CPTScatterPlot*)plot).dataLineStyle.lineColor;
        labelLayer = [[CPTTextLayer alloc] initWithText:annotationString style:plotTextStyle];
        
        CPTMutableLineStyle *lineStyleBorder = [[CPTMutableLineStyle alloc] init];
        lineStyleBorder.lineColor = [CPTColor blackColor];
        lineStyleBorder.lineWidth = 0.5;
        labelLayer.borderLineStyle = lineStyleBorder;
        labelLayer.cornerRadius = 5.0;

    }
    return labelLayer;
}

- (NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot {
    return 0;
}


#pragma mark - Legend delegate

-(void)legend:(nonnull CPTLegend *__unused)legend legendEntryForPlot:(nonnull CPTPlot *)plot wasSelectedAtIndex:(NSUInteger __unused)idx
{
    plot.hidden = !plot.hidden;
}

@end
