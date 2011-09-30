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
	axis.labelingPolicy				 = CPTAxisLabelingPolicyFixedInterval;
	axis.majorIntervalLength		 = CPTDecimalFromDouble( 20.0 );
	axis.orthogonalCoordinateDecimal = CPTDecimalFromDouble( 0.0 );
	axis.tickDirection				 = CPTSignNone;
	axis.minorTicksPerInterval		 = 3;
	axis.majorTickLineStyle			 = majorLineStyle;
	axis.minorTickLineStyle			 = minorLineStyle;
	axis.axisLineStyle				 = majorLineStyle;
	axis.majorTickLength			 = 5.0f;
	axis.minorTickLength			 = 3.0f;
	axis.labelTextStyle				 = textStyle;
	axis.titleTextStyle				 = textStyle;
	//axis.labelFormatter = numberFormatter ;
	axis.majorGridLineStyle = majorGridLineStyle;
	axis.labelingPolicy		= CPTAxisLabelingPolicyAutomatic;
}

-(void)applyThemeToBackground:(CPTXYGraph *)graph
{
	CPTColor *endColor		   = [CPTColor colorWithGenericGray:0.1f];
	CPTGradient *graphGradient = [CPTGradient gradientWithBeginningColor:endColor endingColor:endColor];

	graphGradient		= [graphGradient addColorStop:[CPTColor colorWithGenericGray:0.2f] atPosition:0.3f];
	graphGradient		= [graphGradient addColorStop:[CPTColor colorWithGenericGray:0.3f] atPosition:0.5f];
	graphGradient		= [graphGradient addColorStop:[CPTColor colorWithGenericGray:0.2f] atPosition:0.6f];
	graphGradient.angle = 90.0f;
	graph.fill			= [CPTFill fillWithGradient:graphGradient];
}

-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame
{
	CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithGenericGray:0.1f] endingColor:[CPTColor colorWithGenericGray:0.3f]];

	gradient.angle	   = 90.0f;
	plotAreaFrame.fill = [CPTFill fillWithGradient:gradient];

	plotAreaFrame.paddingLeft	= 50;
	plotAreaFrame.paddingTop	= 10;
	plotAreaFrame.paddingRight	= 20;
	plotAreaFrame.paddingBottom = 30;
}

-(void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet
{
	CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];

	majorLineStyle.lineCap	 = kCGLineCapSquare;
	majorLineStyle.lineColor = [CPTColor grayColor];
	majorLineStyle.lineWidth = 2.0f;

	CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
	minorLineStyle.lineCap	 = kCGLineCapSquare;
	minorLineStyle.lineColor = [CPTColor grayColor];
	minorLineStyle.lineWidth = 1.0f;

	CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 0.1f;
	majorGridLineStyle.lineColor = [CPTColor lightGrayColor];

	CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
	minorGridLineStyle.lineWidth = 0.25f;
	minorGridLineStyle.lineColor = [CPTColor blueColor];

	CPTMutableTextStyle *whiteTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	whiteTextStyle.color	= [CPTColor whiteColor];
	whiteTextStyle.fontSize = 14.0f;

	[self applyThemeToAxis:axisSet.xAxis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:whiteTextStyle];
	[self applyThemeToAxis:axisSet.yAxis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle majorGridLineStyle:majorGridLineStyle textStyle:whiteTextStyle];
}

@end
