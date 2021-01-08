#import "_CPTDarkGradientTheme_Polar.h"

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

CPTThemeName const kCPTDarkGradientTheme_Polar = @"Dark Gradients Polar";

/// @cond
@interface _CPTDarkGradientTheme_Polar()

-(void)applyThemeToAxis:(CPTAxis *)_axis usingMajorLineStyle:(nonnull CPTLineStyle *)majorLineStyle minorLineStyle:(nonnull CPTLineStyle *)minorLineStyle textStyle:(nonnull CPTMutableTextStyle *)textStyle minorTickTextStyle:(nonnull CPTMutableTextStyle *)minorTickTextStyle;

@end

/// @endcond

#pragma mark -

/**
 *  @brief Creates a CPTXYGraph instance formatted with dark gray gradient backgrounds and light gray lines.
 **/
@implementation _CPTDarkGradientTheme_Polar

+(void)load
{
    [self registerTheme:self];
}

+(nonnull NSString *)name
{
    return kCPTDarkGradientTheme_Polar;
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
    CPTColor *endColor         = [CPTColor colorWithGenericGray:CPTFloat(0.1)];
    CPTGradient *graphGradient = [CPTGradient gradientWithBeginningColor:endColor endingColor:endColor];

    graphGradient       = [graphGradient addColorStop:[CPTColor colorWithGenericGray:CPTFloat(0.2)] atPosition:CPTFloat(0.3)];
    graphGradient       = [graphGradient addColorStop:[CPTColor colorWithGenericGray:CPTFloat(0.3)] atPosition:CPTFloat(0.5)];
    graphGradient       = [graphGradient addColorStop:[CPTColor colorWithGenericGray:CPTFloat(0.2)] atPosition:CPTFloat(0.6)];
    graphGradient.angle = CPTFloat(90.0);
    graph.fill          = [CPTFill fillWithGradient:graphGradient];
}

-(void)applyThemeToPlotArea:(nonnull CPTPlotAreaFrame *)plotAreaFrame
{
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithGenericGray:CPTFloat(0.1)] endingColor:[CPTColor colorWithGenericGray:CPTFloat(0.3)]];

    gradient.angle     = CPTFloat(90.0);
    plotAreaFrame.fill = [CPTFill fillWithGradient:gradient];

    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor = [CPTColor colorWithGenericGray:CPTFloat(0.2)];
    borderLineStyle.lineWidth = CPTFloat(4.0);

    plotAreaFrame.borderLineStyle = borderLineStyle;
    plotAreaFrame.cornerRadius    = CPTFloat(10.0);
}

-(void)applyThemeToAxisSet:(nonnull CPTAxisSet *)axisSet
{
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];

    majorLineStyle.lineCap   = kCGLineCapSquare;
    majorLineStyle.lineColor = [CPTColor colorWithGenericGray:CPTFloat(0.5)];
    majorLineStyle.lineWidth = CPTFloat(2.0);

    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineCap   = kCGLineCapSquare;
    minorLineStyle.lineColor = [CPTColor darkGrayColor];
    minorLineStyle.lineWidth = CPTFloat(1.0);

    CPTMutableTextStyle *whiteTextStyle = [[CPTMutableTextStyle alloc] init];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = CPTFloat(14.0);

    CPTMutableTextStyle *whiteMinorTickTextStyle = [[CPTMutableTextStyle alloc] init];
    whiteMinorTickTextStyle.color    = [CPTColor whiteColor];
    whiteMinorTickTextStyle.fontSize = CPTFloat(12.0);
    
    for ( CPTPolarAxis *axis in axisSet.axes ) {
        [self applyThemeToAxis:axis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle textStyle:whiteTextStyle minorTickTextStyle:whiteMinorTickTextStyle];
        }
}

#pragma mark -
#pragma mark NSCoding Methods

-(nonnull Class)classForCoder
{
    return [CPTTheme class];
}

@end
