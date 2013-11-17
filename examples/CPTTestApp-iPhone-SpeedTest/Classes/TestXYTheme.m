//
//  TestXYTheme.m
//  CPTTestApp-iPhone
//
//  Created by Joan on 03/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestXYTheme.h"

@implementation TestXYTheme

+(NSString *)name
{
    return @"TestXYTheme";
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.graphClass = [CPTXYGraph class];
    }
    return self;
}

#pragma mark -

-(void)applyThemeToAxis:(CPTXYAxis *)axis usingMajorLineStyle:(CPTLineStyle *)majorLineStyle
         minorLineStyle:(CPTLineStyle *)minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:(CPTTextStyle *)textStyle
{
    axis.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    axis.majorIntervalLength         = CPTDecimalFromDouble(20.0);
    axis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    axis.tickDirection               = CPTSignNone;
    axis.minorTicksPerInterval       = 3;
    axis.majorTickLineStyle          = majorLineStyle;
    axis.minorTickLineStyle          = minorLineStyle;
    axis.axisLineStyle               = majorLineStyle;
    axis.majorTickLength             = 5.0;
    axis.minorTickLength             = 3.0;
    axis.labelTextStyle              = textStyle;
    axis.titleTextStyle              = textStyle;
    //axis.labelFormatter = numberFormatter ;
    axis.majorGridLineStyle = majorGridLineStyle;
    axis.labelingPolicy     = CPTAxisLabelingPolicyAutomatic;
}

-(void)applyThemeToBackground:(CPTXYGraph *)graph
{
    CPTColor *endColor         = [CPTColor colorWithGenericGray:0.1];
    CPTGradient *graphGradient = [CPTGradient gradientWithBeginningColor:endColor endingColor:endColor];

    graphGradient       = [graphGradient addColorStop:[CPTColor colorWithGenericGray:0.2] atPosition:0.3];
    graphGradient       = [graphGradient addColorStop:[CPTColor colorWithGenericGray:0.3] atPosition:0.5];
    graphGradient       = [graphGradient addColorStop:[CPTColor colorWithGenericGray:0.2] atPosition:0.6];
    graphGradient.angle = 90.0;
    graph.fill          = [CPTFill fillWithGradient:graphGradient];
}

-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame
{
    CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithGenericGray:0.1] endingColor:[CPTColor colorWithGenericGray:0.3]];

    gradient.angle     = 90.0;
    plotAreaFrame.fill = [CPTFill fillWithGradient:gradient];

    plotAreaFrame.paddingLeft   = 50;
    plotAreaFrame.paddingTop    = 10;
    plotAreaFrame.paddingRight  = 20;
    plotAreaFrame.paddingBottom = 30;
}

-(void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet
{
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];

    majorLineStyle.lineCap   = kCGLineCapSquare;
    majorLineStyle.lineColor = [CPTColor grayColor];
    majorLineStyle.lineWidth = 2.0;

    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineCap   = kCGLineCapSquare;
    minorLineStyle.lineColor = [CPTColor grayColor];
    minorLineStyle.lineWidth = 1.0;

    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.1;
    majorGridLineStyle.lineColor = [CPTColor lightGrayColor];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [CPTColor blueColor];

    CPTMutableTextStyle *whiteTextStyle = [[CPTMutableTextStyle alloc] init];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = 14.0;

    [self applyThemeToAxis:axisSet.xAxis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:whiteTextStyle];
    [self applyThemeToAxis:axisSet.yAxis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:whiteTextStyle];
}

@end
