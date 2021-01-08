#import "_CPTSlateTheme_Polar.h"

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

CPTThemeName const kCPTSlateTheme_Polar = @"Slate Polar";

/// @cond
@interface _CPTSlateTheme_Polar()

-(void)applyThemeToAxis:(CPTAxis *)_axis usingMajorLineStyle:(nonnull CPTLineStyle *)majorLineStyle minorLineStyle:(nonnull CPTLineStyle *)minorLineStyle textStyle:(nonnull CPTMutableTextStyle *)textStyle minorTickTextStyle:(nonnull CPTMutableTextStyle *)minorTickTextStyle;

@end

/// @endcond

#pragma mark -

/**
 *  @brief Creates a CPTPolarGraph instance with colors that match the default iPhone navigation bar, toolbar buttons, and table views.
 **/
@implementation _CPTSlateTheme_Polar

+(void)load
{
    [self registerTheme:self];
}

+(nonnull NSString *)name
{
    return kCPTSlateTheme_Polar;
}

#pragma mark -


-(void)applyThemeToAxis:(CPTAxis *)_axis usingMajorLineStyle:(nonnull CPTLineStyle *)majorLineStyle minorLineStyle:(nonnull CPTLineStyle *)minorLineStyle textStyle:(nonnull CPTMutableTextStyle *)textStyle minorTickTextStyle:(nonnull CPTMutableTextStyle *)minorTickTextStyle
{
    // added S.Wainwright
    CPTPolarAxis *axis = (CPTPolarAxis*)_axis;
    if(axis.coordinate == CPTCoordinateZ)
    {
        axis.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
        axis.majorIntervalLength     = @(M_PI/6.0);
        axis.tickDirection           = CPTSignNone;
        axis.minorTicksPerInterval   = 2;
        axis.majorTickLineStyle      = majorLineStyle;
        axis.minorTickLineStyle      = minorLineStyle;
    }
    else
    {
        axis.labelingPolicy          = CPTAxisLabelingPolicyFixedInterval;
        axis.majorIntervalLength     = @0.5;
        axis.tickDirection           = CPTSignNone;
        axis.minorTicksPerInterval   = 4;
        axis.majorTickLineStyle      = majorLineStyle;
        axis.minorTickLineStyle      = minorLineStyle;
        axis.axisLineStyle           = majorLineStyle;
        axis.majorTickLength         = CPTFloat(7.0);
        axis.minorTickLength         = CPTFloat(5.0);
        axis.labelTextStyle          = textStyle;
        axis.minorTickLabelTextStyle = minorTickTextStyle;
        axis.titleTextStyle          = textStyle;
    }
}

-(void)applyThemeToBackground:(nonnull CPTGraph *)graph
{
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:CPTFloat(0.43) green:CPTFloat(0.51) blue:CPTFloat(0.63) alpha:CPTFloat(1.0)]
                                                        endingColor:[CPTColor colorWithComponentRed:CPTFloat(0.70) green:CPTFloat(0.73) blue:CPTFloat(0.80) alpha:CPTFloat(1.0)]];

    gradient.angle = CPTFloat(90.0);

    graph.fill = [CPTFill fillWithGradient:gradient];
}

-(void)applyThemeToPlotArea:(nonnull CPTPlotAreaFrame *)plotAreaFrame
{
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:CPTFloat(0.43) green:CPTFloat(0.51) blue:CPTFloat(0.63) alpha:CPTFloat(1.0)]
                                                        endingColor:[CPTColor colorWithComponentRed:CPTFloat(0.70) green:CPTFloat(0.73) blue:CPTFloat(0.80) alpha:CPTFloat(1.0)]];

    gradient.angle     = CPTFloat(90.0);
    plotAreaFrame.fill = [CPTFill fillWithGradient:gradient];

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor = [CPTColor colorWithGenericGray:CPTFloat(0.2)];
    borderLineStyle.lineWidth = CPTFloat(1.0);

    plotAreaFrame.borderLineStyle = borderLineStyle;
    plotAreaFrame.cornerRadius    = CPTFloat(5.0);
}

-(void)applyThemeToAxisSet:(nonnull CPTAxisSet *)axisSet
{
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];

    majorLineStyle.lineCap   = kCGLineCapSquare;
    majorLineStyle.lineColor = [CPTColor colorWithComponentRed:CPTFloat(0.0) green:CPTFloat(0.25) blue:CPTFloat(0.50) alpha:CPTFloat(1.0)];
    majorLineStyle.lineWidth = CPTFloat(2.0);

    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineCap   = kCGLineCapSquare;
    minorLineStyle.lineColor = [CPTColor blackColor];
    minorLineStyle.lineWidth = CPTFloat(1.0);

    CPTMutableTextStyle *blackTextStyle = [[CPTMutableTextStyle alloc] init];
    blackTextStyle.color    = [CPTColor blackColor];
    blackTextStyle.fontSize = CPTFloat(14.0);

    CPTMutableTextStyle *minorTickBlackTextStyle = [[CPTMutableTextStyle alloc] init];
    minorTickBlackTextStyle.color    = [CPTColor blackColor];
    minorTickBlackTextStyle.fontSize = CPTFloat(12.0);

    // added S.Wainwright
    for(CPTPolarAxis *axis in axisSet.axes ){
        [self applyThemeToAxis:axis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle textStyle:blackTextStyle minorTickTextStyle:minorTickBlackTextStyle];
    }
}

#pragma mark -
#pragma mark NSCoding Methods

-(nonnull Class)classForCoder
{
    return [CPTTheme class];
}

@end
