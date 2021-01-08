#import "_CPTStocksTheme_Polar.h"

#import "CPTBorderedLayer.h"
#import "CPTColor.h"
#import "CPTFill.h"
#import "CPTGradient.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableTextStyle.h"
#import "CPTPlotAreaFrame.h"
#import "CPTUtilities.h"
#import "CPTPolarAxis.h"
#import "CPTPolarAxisSet.h"
#import "CPTPolarGraph.h"

CPTThemeName const kCPTStocksTheme_Polar = @"Stocks Polar";

/**
 *  @brief Creates a CPTPolarGraph instance formatted with a gradient background and white lines.
 **/
@implementation _CPTStocksTheme_Polar

+(void)load
{
    [self registerTheme:self];
}

+(nonnull NSString *)name
{
    return kCPTStocksTheme_Polar;
}

#pragma mark -

-(void)applyThemeToBackground:(nonnull CPTGraph *)graph
{
    graph.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
}

-(void)applyThemeToPlotArea:(nonnull CPTPlotAreaFrame *)plotAreaFrame
{
    CPTGradient *stocksBackgroundGradient = [[CPTGradient alloc] init];

    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:CPTFloat(0.21569) green:CPTFloat(0.28627) blue:CPTFloat(0.44706) alpha:CPTFloat(1.0)]
                                                           atPosition:CPTFloat(0.0)];
    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:CPTFloat(0.09412) green:CPTFloat(0.17255) blue:CPTFloat(0.36078) alpha:CPTFloat(1.0)]
                                                           atPosition:CPTFloat(0.5)];
    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:CPTFloat(0.05882) green:CPTFloat(0.13333) blue:CPTFloat(0.33333) alpha:CPTFloat(1.0)]
                                                           atPosition:CPTFloat(0.5)];
    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPTColor colorWithComponentRed:CPTFloat(0.05882) green:CPTFloat(0.13333) blue:CPTFloat(0.33333) alpha:CPTFloat(1.0)]
                                                           atPosition:CPTFloat(1.0)];

    stocksBackgroundGradient.angle = CPTFloat(270.0);
    plotAreaFrame.fill             = [CPTFill fillWithGradient:stocksBackgroundGradient];

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor = [CPTColor colorWithGenericGray:CPTFloat(0.2)];
    borderLineStyle.lineWidth = CPTFloat(0.0);

    plotAreaFrame.borderLineStyle = borderLineStyle;
    plotAreaFrame.cornerRadius    = CPTFloat(14.0);
}

-(void)applyThemeToAxisSet:(nonnull CPTAxisSet *)axisSet
{
    
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];

    majorLineStyle.lineCap   = kCGLineCapRound;
    majorLineStyle.lineColor = [CPTColor whiteColor];
    majorLineStyle.lineWidth = CPTFloat(3.0);

    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineColor = [CPTColor whiteColor];
    minorLineStyle.lineWidth = CPTFloat(3.0);

    CPTMutableTextStyle *whiteTextStyle = [[CPTMutableTextStyle alloc] init];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = CPTFloat(14.0);

    CPTMutableTextStyle *minorTickWhiteTextStyle = [[CPTMutableTextStyle alloc] init];
    minorTickWhiteTextStyle.color    = [CPTColor whiteColor];
    minorTickWhiteTextStyle.fontSize = CPTFloat(12.0);

    // added S.Wainwright
    
    CPTPolarAxisSet *polarAxisSet  = (CPTPolarAxisSet *)axisSet;
    
    CPTPolarAxis *major           = polarAxisSet.majorAxis;
    major.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
    major.majorIntervalLength     = @0.5;
    major.tickDirection           = CPTSignNone;
    major.minorTicksPerInterval   = 4;
    major.majorTickLineStyle      = majorLineStyle;
    major.minorTickLineStyle      = minorLineStyle;
    major.axisLineStyle           = majorLineStyle;
    major.majorTickLength         = CPTFloat(7.0);
    major.minorTickLength         = CPTFloat(5.0);
    major.labelTextStyle          = whiteTextStyle;
    major.minorTickLabelTextStyle = minorTickWhiteTextStyle;
    major.titleTextStyle          = whiteTextStyle;
    
    CPTPolarAxis *minor           = polarAxisSet.majorAxis;
    minor.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
    minor.majorIntervalLength     = @0.5;
    minor.minorTicksPerInterval   = 4;
    minor.tickDirection           = CPTSignNone;
    minor.majorTickLineStyle      = majorLineStyle;
    minor.minorTickLineStyle      = minorLineStyle;
    minor.axisLineStyle           = majorLineStyle;
    minor.majorTickLength         = CPTFloat(7.0);
    minor.minorTickLength         = CPTFloat(5.0);
    minor.labelTextStyle          = whiteTextStyle;
    minor.minorTickLabelTextStyle = minorTickWhiteTextStyle;
    minor.titleTextStyle          = whiteTextStyle;
    
    CPTPolarAxis *radial          = polarAxisSet.radialAxis;
    radial.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
    radial.majorIntervalLength     = @(M_PI/6.0);
    radial.tickDirection           = CPTSignNone;
    radial.minorTicksPerInterval   = 2;
    radial.majorTickLineStyle      = majorLineStyle;
    radial.minorTickLineStyle      = minorLineStyle;
}

#pragma mark -
#pragma mark NSCoding Methods

-(nonnull Class)classForCoder
{
    return [CPTTheme class];
}

@end
