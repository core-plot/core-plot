#import "_CPTPlainBlackTheme_Polar.h"

#import "CPTBorderedLayer.h"
#import "CPTColor.h"
#import "CPTFill.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableTextStyle.h"
#import "CPTPlotAreaFrame.h"
#import "CPTUtilities.h"
#import "CPTPolarAxis.h"
#import "CPTPolarAxisSet.h"
#import "CPTPolarGraph.h"

CPTThemeName const kCPTPlainBlackTheme_Polar = @"Plain Black Polar";

/**
 *  @brief Creates a CPTPolarGraph instance formatted with black backgrounds and white lines.
 **/
@implementation _CPTPlainBlackTheme_Polar

+(void)load
{
    [self registerTheme:self];
}

+(nonnull NSString *)name
{
    return kCPTPlainBlackTheme_Polar;
}

#pragma mark -

-(void)applyThemeToBackground:(nonnull CPTGraph *)graph
{
    graph.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
}

-(void)applyThemeToPlotArea:(nonnull CPTPlotAreaFrame *)plotAreaFrame
{
    plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor blackColor]];

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor = [CPTColor whiteColor];
    borderLineStyle.lineWidth = CPTFloat(1.0);

    plotAreaFrame.borderLineStyle = borderLineStyle;
    plotAreaFrame.cornerRadius    = CPTFloat(0.0);
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
    CPTPolarAxisSet *polarAxisSet             = (CPTPolarAxisSet *)axisSet;
    
    CPTPolarAxis *major                       = polarAxisSet.majorAxis;
    major.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
    major.majorIntervalLength     = @0.5;
    major.minorTicksPerInterval   = 4;
    major.tickDirection           = CPTSignNone;
    major.majorTickLineStyle      = majorLineStyle;
    major.minorTickLineStyle      = minorLineStyle;
    major.axisLineStyle           = majorLineStyle;
    major.majorTickLength         = CPTFloat(7.0);
    major.minorTickLength         = CPTFloat(5.0);
    major.labelTextStyle          = whiteTextStyle;
    major.minorTickLabelTextStyle = whiteTextStyle;
    major.titleTextStyle          = whiteTextStyle;
    
    CPTPolarAxis *minor           = polarAxisSet.minorAxis;
    minor.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
    minor.majorIntervalLength     = @0.5;
    minor.tickDirection           = CPTSignNone;
    minor.minorTicksPerInterval   = 4;
    minor.majorTickLineStyle      = majorLineStyle;
    minor.minorTickLineStyle      = minorLineStyle;
    minor.axisLineStyle           = majorLineStyle;
    minor.majorTickLength         = CPTFloat(7.0);
    minor.minorTickLength         = CPTFloat(5.0);
    minor.labelTextStyle          = whiteTextStyle;
    minor.minorTickLabelTextStyle = minorTickWhiteTextStyle;
    minor.titleTextStyle          = whiteTextStyle;
    
    CPTPolarAxis *theta           = polarAxisSet.radialAxis;
    theta.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
    theta.majorIntervalLength     = @(M_PI/6.0);
    theta.tickDirection           = CPTSignNone;
    theta.minorTicksPerInterval   = 2;
    theta.majorTickLineStyle      = majorLineStyle;
    theta.minorTickLineStyle      = minorLineStyle;
}

#pragma mark -
#pragma mark NSCoding Methods

-(nonnull Class)classForCoder
{
    return [CPTTheme class];
}

@end
