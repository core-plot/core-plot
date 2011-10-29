#import "_CPTPlainWhiteTheme.h"

#import "CPTBorderedLayer.h"
#import "CPTColor.h"
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

NSString *const kCPTPlainWhiteTheme = @"Plain White"; ///< Plain white theme.

/**
 *	@brief Creates a CPTXYGraph instance formatted with white backgrounds and black lines.
 **/
@implementation _CPTPlainWhiteTheme

+(void)load
{
	[self registerTheme:self];
}

+(NSString *)name
{
	return kCPTPlainWhiteTheme;
}

#pragma mark -

-(void)applyThemeToBackground:(CPTXYGraph *)graph
{
	graph.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
}

-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame
{
	plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];

	CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
	borderLineStyle.lineColor = [CPTColor blackColor];
	borderLineStyle.lineWidth = 1.0;

	plotAreaFrame.borderLineStyle = borderLineStyle;
	plotAreaFrame.cornerRadius	  = 0.0;
}

-(void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet
{
	CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];

	majorLineStyle.lineCap	 = kCGLineCapButt;
	majorLineStyle.lineColor = [CPTColor colorWithGenericGray:0.5];
	majorLineStyle.lineWidth = 1.0;

	CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
	minorLineStyle.lineCap	 = kCGLineCapButt;
	minorLineStyle.lineColor = [CPTColor blackColor];
	minorLineStyle.lineWidth = 1.0;

	CPTXYAxis *x						= axisSet.xAxis;
	CPTMutableTextStyle *blackTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	blackTextStyle.color	= [CPTColor blackColor];
	blackTextStyle.fontSize = 14.0;
	CPTMutableTextStyle *minorTickBlackTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	minorTickBlackTextStyle.color	 = [CPTColor blackColor];
	minorTickBlackTextStyle.fontSize = 12.0;
	x.labelingPolicy				 = CPTAxisLabelingPolicyFixedInterval;
	x.majorIntervalLength			 = CPTDecimalFromDouble(0.5);
	x.orthogonalCoordinateDecimal	 = CPTDecimalFromDouble(0.0);
	x.tickDirection					 = CPTSignNone;
	x.minorTicksPerInterval			 = 4;
	x.majorTickLineStyle			 = majorLineStyle;
	x.minorTickLineStyle			 = minorLineStyle;
	x.axisLineStyle					 = majorLineStyle;
	x.majorTickLength				 = 7.0;
	x.minorTickLength				 = 5.0;
	x.labelTextStyle				 = blackTextStyle;
	x.minorTickLabelTextStyle		 = blackTextStyle;
	x.titleTextStyle				 = blackTextStyle;

	CPTXYAxis *y = axisSet.yAxis;
	y.labelingPolicy			  = CPTAxisLabelingPolicyFixedInterval;
	y.majorIntervalLength		  = CPTDecimalFromDouble(0.5);
	y.minorTicksPerInterval		  = 4;
	y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
	y.tickDirection				  = CPTSignNone;
	y.majorTickLineStyle		  = majorLineStyle;
	y.minorTickLineStyle		  = minorLineStyle;
	y.axisLineStyle				  = majorLineStyle;
	y.majorTickLength			  = 7.0;
	y.minorTickLength			  = 5.0;
	y.labelTextStyle			  = blackTextStyle;
	y.minorTickLabelTextStyle	  = minorTickBlackTextStyle;
	y.titleTextStyle			  = blackTextStyle;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPTTheme class];
}

@end
