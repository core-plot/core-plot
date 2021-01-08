#import "_CPTPlainWhiteTheme_Polar.h"

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

CPTThemeName const kCPTPlainWhiteTheme_Polar = @"Plain White Polar";

/**
 *  @brief Creates a CPTPolarGraph instance formatted with white backgrounds and black lines.
 **/
@implementation _CPTPlainWhiteTheme_Polar

+(void)load
{
    [self registerTheme:self];
}

+(nonnull NSString *)name
{
    return kCPTPlainWhiteTheme_Polar;
}

#pragma mark -

-(void)applyThemeToBackground:(nonnull CPTGraph *)graph
{
    graph.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
}

-(void)applyThemeToPlotArea:(nonnull CPTPlotAreaFrame *)plotAreaFrame
{
    plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor = [CPTColor blackColor];
    borderLineStyle.lineWidth = CPTFloat(1.0);

    plotAreaFrame.borderLineStyle = borderLineStyle;
    plotAreaFrame.cornerRadius    = CPTFloat(0.0);
}

-(void)applyThemeToAxisSet:(nonnull CPTAxisSet *)axisSet
{
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
    
    majorLineStyle.lineCap   = kCGLineCapButt;
    majorLineStyle.lineColor = [CPTColor colorWithGenericGray:CPTFloat(0.5)];
    majorLineStyle.lineWidth = CPTFloat(1.0);
    
    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineCap   = kCGLineCapButt;
    minorLineStyle.lineColor = [CPTColor blackColor];
    minorLineStyle.lineWidth = CPTFloat(1.0);
    
    CPTMutableTextStyle *blackTextStyle = [[CPTMutableTextStyle alloc] init];
    blackTextStyle.color    = [CPTColor blackColor];
    blackTextStyle.fontSize = CPTFloat(14.0);
    
    CPTMutableTextStyle *minorTickBlackTextStyle = [[CPTMutableTextStyle alloc] init];
    minorTickBlackTextStyle.color    = [CPTColor blackColor];
    minorTickBlackTextStyle.fontSize = CPTFloat(12.0);
    
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
    major.labelTextStyle          = blackTextStyle;
    major.minorTickLabelTextStyle = minorTickBlackTextStyle;
    major.titleTextStyle          = blackTextStyle;
    
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
    minor.labelTextStyle          = blackTextStyle;
    minor.minorTickLabelTextStyle = blackTextStyle;
    minor.titleTextStyle          = blackTextStyle;
    
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
