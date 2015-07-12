#import "APFinancialData.h"
#import "APYahooDataPuller.h"
#import "MainViewController.h"

#define ROWS_FIRST_DATA_ORDER 1

@interface MainViewController()

@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong) APYahooDataPuller *datapuller;

@end

@implementation MainViewController

@synthesize graph;
@synthesize datapuller;
@synthesize graphHost;

-(void)setView:(UIView *)aView
{
    [super setView:aView];
    if ( nil == aView ) {
        self.graph     = nil;
        self.graphHost = nil;
    }
}

-(void)viewDidLoad
{
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTStocksTheme];

    [newGraph applyTheme:theme];
    self.graph = newGraph;

    newGraph.paddingRight                = 50.0;
    newGraph.paddingLeft                 = 50.0;
    newGraph.plotAreaFrame.masksToBorder = NO;
    newGraph.plotAreaFrame.cornerRadius  = 0.0;

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor              = [CPTColor whiteColor];
    borderLineStyle.lineWidth              = 2.0;
    newGraph.plotAreaFrame.borderLineStyle = borderLineStyle;
    self.graphHost.hostedGraph             = newGraph;

    // Axes
    CPTXYAxisSet *xyAxisSet        = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *xAxis               = xyAxisSet.xAxis;
    CPTMutableLineStyle *lineStyle = [xAxis.axisLineStyle mutableCopy];
    lineStyle.lineCap    = kCGLineCapButt;
    xAxis.axisLineStyle  = lineStyle;
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;

    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.axisLineStyle = nil;

    // Line plot with gradient fill
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
    dataSourceLinePlot.identifier     = @"Data Source Plot";
    dataSourceLinePlot.dataLineStyle  = nil;
    dataSourceLinePlot.dataSource     = self;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    [newGraph addPlot:dataSourceLinePlot];

    CPTColor *areaColor       = [CPTColor colorWithComponentRed:CPTFloat(1.0) green:CPTFloat(1.0) blue:CPTFloat(1.0) alpha:CPTFloat(0.6)];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(200.0);

    areaColor                         = [CPTColor colorWithComponentRed:CPTFloat(0.0) green:CPTFloat(1.0) blue:CPTFloat(0.0) alpha:CPTFloat(0.6)];
    areaGradient                      = [CPTGradient gradientWithBeginningColor:[CPTColor clearColor] endingColor:areaColor];
    areaGradient.angle                = -90.0;
    areaGradientFill                  = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill2      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue2 = CPTDecimalFromDouble(400.0);

    // OHLC plot
    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];
    whiteLineStyle.lineWidth = 1.0;
    CPTTradingRangePlot *ohlcPlot = [[CPTTradingRangePlot alloc] initWithFrame:newGraph.bounds];
    ohlcPlot.identifier = @"OHLC";
    ohlcPlot.lineStyle  = whiteLineStyle;
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = 8.0;
    ohlcPlot.labelTextStyle = whiteTextStyle;
    ohlcPlot.labelOffset    = 5.0;
    ohlcPlot.stickLength    = 2.0;
    ohlcPlot.dataSource     = self;
    ohlcPlot.plotStyle      = CPTTradingRangePlotStyleOHLC;
    ohlcPlot.cachePrecision = CPTPlotCachePrecisionDecimal;
    [newGraph addPlot:ohlcPlot];

    // Add plot space for bar chart
    CPTXYPlotSpace *volumePlotSpace = [[CPTXYPlotSpace alloc] init];
    volumePlotSpace.identifier = @"Volume Plot Space";
    [newGraph addPlotSpace:volumePlotSpace];

    // Volume plot
    CPTBarPlot *volumePlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blackColor] horizontalBars:NO];
    volumePlot.dataSource = self;

    lineStyle            = [volumePlot.lineStyle mutableCopy];
    lineStyle.lineColor  = [CPTColor whiteColor];
    volumePlot.lineStyle = lineStyle;

    volumePlot.fill           = nil;
    volumePlot.barWidth       = CPTDecimalFromFloat(1.0f);
    volumePlot.identifier     = @"Volume Plot";
    volumePlot.cachePrecision = CPTPlotCachePrecisionDouble;
    [newGraph addPlot:volumePlot toPlotSpace:volumePlotSpace];

    // Data puller
    NSDate *start         = [NSDate dateWithTimeIntervalSinceNow:-60.0 * 60.0 * 24.0 * 7.0 * 12.0]; // 12 weeks ago
    NSDate *end           = [NSDate date];
    APYahooDataPuller *dp = [[APYahooDataPuller alloc] initWithTargetSymbol:@"AAPL" targetStartDate:start targetEndDate:end];
    [self setDatapuller:dp];
    [dp setDelegate:self];

    [super viewDidLoad];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
    }
    return self;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.datapuller.financialData.count;
}

#if ROWS_FIRST_DATA_ORDER

-(CPTNumericData *)dataForPlot:(CPTPlot *)plot recordIndexRange:(NSRange)indexRange
{
    NSArray *financialData              = self.datapuller.financialData;
    const NSUInteger financialDataCount = financialData.count;

    const BOOL useDoubles = plot.doublePrecisionCache;

    NSUInteger numFields = plot.numberOfFields;

    if ( [plot.identifier isEqual:@"Volume Plot"] ) {
        numFields = 2;
    }

    NSMutableData *data = [[NSMutableData alloc] initWithLength:indexRange.length * numFields * ( useDoubles ? sizeof(double) : sizeof(NSDecimal) )];

    const NSUInteger maxIndex = NSMaxRange(indexRange);

    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        if ( useDoubles ) {
            double *nextValue = data.mutableBytes;

            for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                NSDictionary *fData = (NSDictionary *)financialData[financialDataCount - i - 1];
                NSNumber *value;

                for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                    switch ( fieldEnum ) {
                        case CPTScatterPlotFieldX:
                            *nextValue++ = (double)(i + 1);
                            break;

                        case CPTScatterPlotFieldY:
                            value = fData[@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
        else {
            NSDecimal *nextValue = data.mutableBytes;

            for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                NSDictionary *fData = (NSDictionary *)financialData[financialDataCount - i - 1];
                NSNumber *value;

                for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                    switch ( fieldEnum ) {
                        case CPTScatterPlotFieldX:
                            *nextValue++ = CPTDecimalFromUnsignedInteger(i + 1);
                            break;

                        case CPTScatterPlotFieldY:
                            value = fData[@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
    }
    else if ( [plot.identifier isEqual:@"Volume Plot"] ) {
        if ( useDoubles ) {
            double *nextValue = data.mutableBytes;

            for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                NSDictionary *fData = (NSDictionary *)financialData[financialDataCount - i - 1];
                NSNumber *value;

                for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                    switch ( fieldEnum ) {
                        case CPTBarPlotFieldBarLocation:
                            *nextValue++ = (double)(i + 1);
                            break;

                        case CPTBarPlotFieldBarTip:
                            value = fData[@"volume"];
                            NSAssert(value, @"Volume value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
        else {
            NSDecimal *nextValue = data.mutableBytes;

            for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                NSDictionary *fData = (NSDictionary *)financialData[financialDataCount - i - 1];
                NSNumber *value;

                for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                    switch ( fieldEnum ) {
                        case CPTBarPlotFieldBarLocation:
                            *nextValue++ = CPTDecimalFromUnsignedInteger(i + 1);
                            break;

                        case CPTBarPlotFieldBarTip:
                            value = fData[@"volume"];
                            NSAssert(value, @"Volume value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
    }
    else {
        if ( useDoubles ) {
            double *nextValue = data.mutableBytes;

            for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                NSDictionary *fData = (NSDictionary *)financialData[financialDataCount - i - 1];
                NSNumber *value;

                for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                    switch ( fieldEnum ) {
                        case CPTTradingRangePlotFieldX:
                            *nextValue++ = (double)(i + 1);
                            break;

                        case CPTTradingRangePlotFieldOpen:
                            value = fData[@"open"];
                            NSAssert(value, @"Open value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        case CPTTradingRangePlotFieldHigh:
                            value = fData[@"high"];
                            NSAssert(value, @"High value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        case CPTTradingRangePlotFieldLow:
                            value = fData[@"low"];
                            NSAssert(value, @"Low value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        case CPTTradingRangePlotFieldClose:
                            value = fData[@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
        else {
            NSDecimal *nextValue = data.mutableBytes;

            for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                NSDictionary *fData = (NSDictionary *)financialData[financialDataCount - i - 1];
                NSNumber *value;

                for ( NSUInteger fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                    switch ( fieldEnum ) {
                        case CPTTradingRangePlotFieldX:
                            *nextValue++ = CPTDecimalFromUnsignedInteger(i + 1);
                            break;

                        case CPTTradingRangePlotFieldOpen:
                            value = fData[@"open"];
                            NSAssert(value, @"Open value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        case CPTTradingRangePlotFieldHigh:
                            value = fData[@"high"];
                            NSAssert(value, @"High value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        case CPTTradingRangePlotFieldLow:
                            value = fData[@"low"];
                            NSAssert(value, @"Low value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        case CPTTradingRangePlotFieldClose:
                            value = fData[@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
    }

    CPTMutableNumericData *numericData = [CPTMutableNumericData numericDataWithData:data
                                                                           dataType:(useDoubles ? plot.doubleDataType : plot.decimalDataType)
                                                                              shape:@[@(indexRange.length),
                                                                                      @(numFields)]
                                                                          dataOrder:CPTDataOrderRowsFirst];

    return numericData;
}

#else

-(CPTNumericData *)dataForPlot:(CPTPlot *)plot recordIndexRange:(NSRange)indexRange
{
    NSArray *financialData              = self.datapuller.financialData;
    const NSUInteger financialDataCount = financialData.count;

    const BOOL useDoubles = plot.doublePrecisionCache;

    NSUInteger numFields = plot.numberOfFields;

    if ( [plot.identifier isEqual:@"Volume Plot"] ) {
        numFields = 2;
    }

    NSMutableData *data = [[NSMutableData alloc] initWithLength:indexRange.length * numFields * ( useDoubles ? sizeof(double) : sizeof(NSDecimal) )];

    const NSUInteger maxIndex = NSMaxRange(indexRange);

    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        if ( useDoubles ) {
            double *nextValue = data.mutableBytes;

            for ( int fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                    NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
                    NSNumber *value;

                    switch ( fieldEnum ) {
                        case CPTScatterPlotFieldX:
                            *nextValue++ = (double)(i + 1);
                            break;

                        case CPTScatterPlotFieldY:
                            value = [fData objectForKey:@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
        else {
            NSDecimal *nextValue = data.mutableBytes;

            for ( int fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                    NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
                    NSNumber *value;

                    switch ( fieldEnum ) {
                        case CPTScatterPlotFieldX:
                            *nextValue++ = CPTDecimalFromUnsignedInteger(i + 1);
                            break;

                        case CPTScatterPlotFieldY:
                            value = [fData objectForKey:@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
    }
    else if ( [plot.identifier isEqual:@"Volume Plot"] ) {
        if ( useDoubles ) {
            double *nextValue = data.mutableBytes;

            for ( int fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                    NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
                    NSNumber *value;

                    switch ( fieldEnum ) {
                        case CPTBarPlotFieldBarLocation:
                            *nextValue++ = (double)(i + 1);
                            break;

                        case CPTBarPlotFieldBarTip:
                            value = [fData objectForKey:@"volume"];
                            NSAssert(value, @"Volume value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
        else {
            NSDecimal *nextValue = data.mutableBytes;

            for ( int fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                    NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
                    NSNumber *value;

                    switch ( fieldEnum ) {
                        case CPTBarPlotFieldBarLocation:
                            *nextValue++ = CPTDecimalFromUnsignedInteger(i + 1);
                            break;

                        case CPTBarPlotFieldBarTip:
                            value = [fData objectForKey:@"volume"];
                            NSAssert(value, @"Volume value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
    }
    else {
        if ( useDoubles ) {
            double *nextValue = data.mutableBytes;

            for ( int fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                    NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
                    NSNumber *value;

                    switch ( fieldEnum ) {
                        case CPTTradingRangePlotFieldX:
                            *nextValue++ = (double)(i + 1);
                            break;

                        case CPTTradingRangePlotFieldOpen:
                            value = [fData objectForKey:@"open"];
                            NSAssert(value, @"Open value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        case CPTTradingRangePlotFieldHigh:
                            value = [fData objectForKey:@"high"];
                            NSAssert(value, @"High value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        case CPTTradingRangePlotFieldLow:
                            value = [fData objectForKey:@"low"];
                            NSAssert(value, @"Low value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        case CPTTradingRangePlotFieldClose:
                            value = [fData objectForKey:@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value doubleValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
        else {
            NSDecimal *nextValue = data.mutableBytes;

            for ( int fieldEnum = 0; fieldEnum < numFields; fieldEnum++ ) {
                for ( NSUInteger i = indexRange.location; i < maxIndex; i++ ) {
                    NSDictionary *fData = (NSDictionary *)[financialData objectAtIndex:financialDataCount - i - 1];
                    NSNumber *value;

                    switch ( fieldEnum ) {
                        case CPTTradingRangePlotFieldX:
                            *nextValue++ = CPTDecimalFromUnsignedInteger(i + 1);
                            break;

                        case CPTTradingRangePlotFieldOpen:
                            value = [fData objectForKey:@"open"];
                            NSAssert(value, @"Open value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        case CPTTradingRangePlotFieldHigh:
                            value = [fData objectForKey:@"high"];
                            NSAssert(value, @"High value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        case CPTTradingRangePlotFieldLow:
                            value = [fData objectForKey:@"low"];
                            NSAssert(value, @"Low value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        case CPTTradingRangePlotFieldClose:
                            value = [fData objectForKey:@"close"];
                            NSAssert(value, @"Close value was nil");
                            *nextValue++ = [value decimalValue];
                            break;

                        default:
                            break;
                    }
                }
            }
        }
    }

    CPTMutableNumericData *numericData = [CPTMutableNumericData numericDataWithData:data
                                                                           dataType:(useDoubles ? plot.doubleDataType : plot.decimalDataType)
                                                                              shape:@[@(indexRange.length), @(numFields)]
                                                                          dataOrder:CPTDataOrderColumnsFirst];
    [data release];

    return numericData;
}
#endif

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ( ![(NSString *)plot.identifier isEqualToString : @"OHLC"] ) {
        return (id)[NSNull null]; // Don't show any label
    }
    else if ( index % 5 ) {
        return (id)[NSNull null];
    }
    else {
        return nil; // Use default label style
    }
}

-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp
{
    static CPTAnimationOperation *animationOperation = nil;

    CPTXYPlotSpace *plotSpace       = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    CPTXYPlotSpace *volumePlotSpace = (CPTXYPlotSpace *)[self.graph plotSpaceWithIdentifier:@"Volume Plot Space"];

    APYahooDataPuller *thePuller = self.datapuller;

    NSDecimalNumber *high   = thePuller.overallHigh;
    NSDecimalNumber *low    = thePuller.overallLow;
    NSDecimalNumber *length = [high decimalNumberBySubtracting:low];

    NSLog(@"high = %@, low = %@, length = %@", high, low, length);
    NSDecimalNumber *pricePlotSpaceDisplacementPercent = [NSDecimalNumber decimalNumberWithMantissa:33
                                                                                           exponent:-2
                                                                                         isNegative:NO];

    NSDecimalNumber *lengthDisplacementValue = [length decimalNumberByMultiplyingBy:pricePlotSpaceDisplacementPercent];
    NSDecimalNumber *lowDisplayLocation      = [low decimalNumberBySubtracting:lengthDisplacementValue];
    NSDecimalNumber *lengthDisplayLocation   = [length decimalNumberByAdding:lengthDisplacementValue];

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromUnsignedInteger(thePuller.financialData.count + 1)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:lowDisplayLocation.decimalValue length:lengthDisplayLocation.decimalValue];

    CPTScatterPlot *linePlot = (CPTScatterPlot *)[self.graph plotWithIdentifier:@"Data Source Plot"];
    linePlot.areaBaseValue  = [high decimalValue];
    linePlot.areaBaseValue2 = [low decimalValue];

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;

    NSDecimalNumber *overallVolumeHigh = thePuller.overallVolumeHigh;
    NSDecimalNumber *overallVolumeLow  = thePuller.overallVolumeLow;
    NSDecimalNumber *volumeLength      = [overallVolumeHigh decimalNumberBySubtracting:overallVolumeLow];

    // make the length aka height for y 3 times more so that we get a 1/3 area covered by volume
    NSDecimalNumber *volumePlotSpaceDisplacementPercent = [NSDecimalNumber decimalNumberWithMantissa:3
                                                                                            exponent:0
                                                                                          isNegative:NO];

    NSDecimalNumber *volumeLengthDisplacementValue = [volumeLength decimalNumberByMultiplyingBy:volumePlotSpaceDisplacementPercent];
    NSDecimalNumber *volumeLowDisplayLocation      = overallVolumeLow;
    NSDecimalNumber *volumeLengthDisplayLocation   = [volumeLength decimalNumberByAdding:volumeLengthDisplacementValue];

    volumePlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.0) length:CPTDecimalFromUnsignedInteger(thePuller.financialData.count + 1)];
//    volumePlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:[volumeLowDisplayLocation decimalValue] length:[volumeLengthDisplayLocation decimalValue]];

    if ( animationOperation ) {
        [[CPTAnimation sharedInstance] removeAnimationOperation:animationOperation];
    }

    animationOperation = [CPTAnimation animate:volumePlotSpace
                                      property:@"yRange"
                                 fromPlotRange:[CPTPlotRange plotRangeWithLocation:[volumeLowDisplayLocation decimalValue]
                                                                            length:CPTDecimalMultiply( [volumeLengthDisplayLocation decimalValue], CPTDecimalFromInteger(10) )]
                                   toPlotRange:[CPTPlotRange plotRangeWithLocation:[volumeLowDisplayLocation decimalValue]
                                                                            length:[volumeLengthDisplayLocation decimalValue]]
                                      duration:2.5];

    axisSet.xAxis.orthogonalCoordinateDecimal = [low decimalValue];
    axisSet.yAxis.majorIntervalLength         = CPTDecimalFromDouble(50.0);
    axisSet.yAxis.minorTicksPerInterval       = 4;
    axisSet.yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(1.0);
    NSArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:[low decimalValue]]];

    axisSet.yAxis.labelExclusionRanges = exclusionRanges;

    [self.graph reloadData];
}

@end
