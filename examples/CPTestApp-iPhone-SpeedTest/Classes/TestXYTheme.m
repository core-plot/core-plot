//
//  TestXYTheme.m
//  CPTestApp-iPhone
//
//  Created by Joan on 03/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TestXYTheme.h"


@implementation TestXYTheme



+(NSString *)defaultName 
{
	return kCPDarkGradientTheme;
}

-(void)applyThemeToAxis:(CPXYAxis *)axis usingMajorLineStyle:(CPLineStyle *)majorLineStyle 
	minorLineStyle:(CPLineStyle *)minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:(CPTextStyle *)textStyle
{
	axis.labelingPolicy = CPAxisLabelingPolicyFixedInterval;
    axis.majorIntervalLength = CPDecimalFromDouble(20.0);
    axis.orthogonalCoordinateDecimal = CPDecimalFromDouble(0.0);
	axis.tickDirection = CPSignNone;
    axis.minorTicksPerInterval = 3;
    axis.majorTickLineStyle = majorLineStyle;
    axis.minorTickLineStyle = minorLineStyle;
    axis.axisLineStyle = majorLineStyle;
    axis.majorTickLength = 5.0f;
    axis.minorTickLength = 3.0f;
	axis.labelTextStyle = textStyle; 
	axis.titleTextStyle = textStyle;
    //axis.labelFormatter = numberFormatter ;
    axis.majorGridLineStyle = majorGridLineStyle ;
    axis.labelingPolicy = CPAxisLabelingPolicyAutomatic ;
}

-(void)applyThemeToBackground:(CPXYGraph *)graph 
{
	CPColor *endColor = [CPColor colorWithGenericGray:0.1f];
	CPGradient *graphGradient = [CPGradient gradientWithBeginningColor:endColor endingColor:endColor];
	graphGradient = [graphGradient addColorStop:[CPColor colorWithGenericGray:0.2f] atPosition:0.3f];
	graphGradient = [graphGradient addColorStop:[CPColor colorWithGenericGray:0.3f] atPosition:0.5f];
	graphGradient = [graphGradient addColorStop:[CPColor colorWithGenericGray:0.2f] atPosition:0.6f];
	graphGradient.angle = 90.0f;
	graph.fill = [CPFill fillWithGradient:graphGradient];
}

-(void)applyThemeToPlotArea:(CPPlotAreaFrame *)plotAreaFrame 
{
    CPGradient *gradient = [CPGradient gradientWithBeginningColor:[CPColor colorWithGenericGray:0.1f] endingColor:[CPColor colorWithGenericGray:0.3f]];
    gradient.angle = 90.0f;
	plotAreaFrame.fill = [CPFill fillWithGradient:gradient]; 

    plotAreaFrame.paddingLeft = 50 ;
	plotAreaFrame.paddingTop = 10 ;
    plotAreaFrame.paddingRight = 20 ;
    plotAreaFrame.paddingBottom = 30 ;
}

-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet {
    CPMutableLineStyle *majorLineStyle = [CPMutableLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapSquare;
    majorLineStyle.lineColor = [CPColor grayColor];
    majorLineStyle.lineWidth = 2.0f;
    
    CPMutableLineStyle *minorLineStyle = [CPMutableLineStyle lineStyle];
    minorLineStyle.lineCap = kCGLineCapSquare;
    minorLineStyle.lineColor = [CPColor grayColor];
    minorLineStyle.lineWidth = 1.0f;
    
    CPMutableLineStyle *majorGridLineStyle = [CPMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.1f;
    majorGridLineStyle.lineColor = [CPColor lightGrayColor];
    
    CPMutableLineStyle *minorGridLineStyle = [CPMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25f;
    minorGridLineStyle.lineColor = [CPColor blueColor];
	
	CPMutableTextStyle *whiteTextStyle = [[[CPMutableTextStyle alloc] init] autorelease];
	whiteTextStyle.color = [CPColor whiteColor];
	whiteTextStyle.fontSize = 14.0f;

    [self applyThemeToAxis:axisSet.xAxis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:whiteTextStyle];
    [self applyThemeToAxis:axisSet.yAxis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:whiteTextStyle];
}













@end
