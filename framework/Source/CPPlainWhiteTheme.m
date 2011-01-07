
#import "CPPlainWhiteTheme.h"
#import "CPXYGraph.h"
#import "CPColor.h"
#import "CPGradient.h"
#import "CPFill.h"
#import "CPPlotAreaFrame.h"
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPMutableLineStyle.h"
#import "CPMutableTextStyle.h"
#import "CPBorderedLayer.h"

/** @brief Creates a CPXYGraph instance formatted with white backgrounds and black lines.
 **/
@implementation CPPlainWhiteTheme

+(NSString *)defaultName 
{
	return kCPPlainWhiteTheme;
}

-(void)applyThemeToBackground:(CPXYGraph *)graph 
{
    graph.fill = [CPFill fillWithColor:[CPColor whiteColor]];
}
	
-(void)applyThemeToPlotArea:(CPPlotAreaFrame *)plotAreaFrame
{	
	plotAreaFrame.fill = [CPFill fillWithColor:[CPColor whiteColor]]; 

	CPMutableLineStyle *borderLineStyle = [CPMutableLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor blackColor];
	borderLineStyle.lineWidth = 1.0;
	
	plotAreaFrame.borderLineStyle = borderLineStyle;
	plotAreaFrame.cornerRadius = 0.0;
}
	
-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet 
{	
    CPMutableLineStyle *majorLineStyle = [CPMutableLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapButt;
    majorLineStyle.lineColor = [CPColor colorWithGenericGray:0.5];
    majorLineStyle.lineWidth = 1.0;
    
    CPMutableLineStyle *minorLineStyle = [CPMutableLineStyle lineStyle];
    minorLineStyle.lineCap = kCGLineCapButt;
    minorLineStyle.lineColor = [CPColor blackColor];
    minorLineStyle.lineWidth = 1.0;
	
    CPXYAxis *x = axisSet.xAxis;
	CPMutableTextStyle *blackTextStyle = [[[CPMutableTextStyle alloc] init] autorelease];
	blackTextStyle.color = [CPColor blackColor];
	blackTextStyle.fontSize = 14.0;
	CPMutableTextStyle *minorTickBlackTextStyle = [[[CPMutableTextStyle alloc] init] autorelease];
	minorTickBlackTextStyle.color = [CPColor blackColor];
	minorTickBlackTextStyle.fontSize = 12.0;    x.labelingPolicy = CPAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength = CPDecimalFromDouble(0.5);
    x.orthogonalCoordinateDecimal = CPDecimalFromDouble(0.0);
	x.tickDirection = CPSignNone;
    x.minorTicksPerInterval = 4;
    x.majorTickLineStyle = majorLineStyle;
    x.minorTickLineStyle = minorLineStyle;
    x.axisLineStyle = majorLineStyle;
    x.majorTickLength = 7.0;
    x.minorTickLength = 5.0;
	x.labelTextStyle = blackTextStyle;
	x.minorTickLabelTextStyle = blackTextStyle;
	x.titleTextStyle = blackTextStyle;
	
    CPXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPAxisLabelingPolicyFixedInterval;
    y.majorIntervalLength = CPDecimalFromDouble(0.5);
    y.minorTicksPerInterval = 4;
    y.orthogonalCoordinateDecimal = CPDecimalFromDouble(0.0);
	y.tickDirection = CPSignNone;
    y.majorTickLineStyle = majorLineStyle;
    y.minorTickLineStyle = minorLineStyle;
    y.axisLineStyle = majorLineStyle;
    y.majorTickLength = 7.0;
    y.minorTickLength = 5.0;
	y.labelTextStyle = blackTextStyle;
	y.minorTickLabelTextStyle = minorTickBlackTextStyle;
	y.titleTextStyle = blackTextStyle;
}

@end
