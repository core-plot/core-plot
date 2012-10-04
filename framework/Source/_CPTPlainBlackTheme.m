#import "_CPTPlainBlackTheme.h"

#import "CPTBorderedLayer.h"
#import "CPTColor.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTGradient.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableTextStyle.h"
#import "CPTPlotAreaFrame.h"
#import "CPTUtilities.h"
#import "CPTXYAxis.h"
#import "CPTXYAxisSet.h"
#import "CPTXYGraph.h"
#import "CPTXYPlotSpace.h"

NSString *const kCPTPlainBlackTheme = @"Plain Black";

/**
 *  @brief Creates a CPTXYGraph instance formatted with black backgrounds and white lines.
 **/
@implementation _CPTPlainBlackTheme

+(void)load
{
    [self registerTheme:self];
}

+(NSString *)name
{
    return kCPTPlainBlackTheme;
}

#pragma mark -

-(void)applyThemeToBackground:(CPTXYGraph *)graph
{
    graph.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
}

-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame
{
    plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor blackColor]];

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor = [CPTColor whiteColor];
    borderLineStyle.lineWidth = CPTFloat(1.0);

    plotAreaFrame.borderLineStyle = borderLineStyle;
    plotAreaFrame.cornerRadius    = CPTFloat(0.0);
}

-(void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet
{
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];

    majorLineStyle.lineCap   = kCGLineCapRound;
    majorLineStyle.lineColor = [CPTColor whiteColor];
    majorLineStyle.lineWidth = CPTFloat(3.0);

    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineColor = [CPTColor whiteColor];
    minorLineStyle.lineWidth = CPTFloat(3.0);

    CPTXYAxis *x                        = axisSet.xAxis;
    CPTMutableTextStyle *whiteTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = CPTFloat(14.0);
    CPTMutableTextStyle *minorTickWhiteTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
    minorTickWhiteTextStyle.color    = [CPTColor whiteColor];
    minorTickWhiteTextStyle.fontSize = CPTFloat(12.0);

    x.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.tickDirection               = CPTSignNone;
    x.minorTicksPerInterval       = 4;
    x.majorTickLineStyle          = majorLineStyle;
    x.minorTickLineStyle          = minorLineStyle;
    x.axisLineStyle               = majorLineStyle;
    x.majorTickLength             = CPTFloat(7.0);
    x.minorTickLength             = CPTFloat(5.0);
    x.labelTextStyle              = whiteTextStyle;
    x.minorTickLabelTextStyle     = whiteTextStyle;
    x.titleTextStyle              = whiteTextStyle;

    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    y.majorIntervalLength         = CPTDecimalFromDouble(0.5);
    y.minorTicksPerInterval       = 4;
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.tickDirection               = CPTSignNone;
    y.majorTickLineStyle          = majorLineStyle;
    y.minorTickLineStyle          = minorLineStyle;
    y.axisLineStyle               = majorLineStyle;
    y.majorTickLength             = CPTFloat(7.0);
    y.minorTickLength             = CPTFloat(5.0);
    y.labelTextStyle              = whiteTextStyle;
    y.minorTickLabelTextStyle     = minorTickWhiteTextStyle;
    y.titleTextStyle              = whiteTextStyle;
}

#pragma mark -
#pragma mark NSCoding Methods

-(Class)classForCoder
{
    return [CPTTheme class];
}

@end
