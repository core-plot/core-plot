
#import "CPPlainWhiteTheme.h"
#import "CPXYGraph.h"
#import "CPColor.h"
#import "CPGradient.h"
#import "CPFill.h"
#import "CPPlotArea.h"
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"
#import "CPLineStyle.h"
#import "CPTextStyle.h"
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
	
-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea 
{	
	plotArea.fill = [CPFill fillWithColor:[CPColor whiteColor]]; 

	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor blackColor];
	borderLineStyle.lineWidth = 1.0f;
	
	plotArea.borderLineStyle = borderLineStyle;
	plotArea.cornerRadius = 0.0f;
}
	
-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet 
{	
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapButt;
    majorLineStyle.lineColor = [CPColor colorWithGenericGray:0.5];
    majorLineStyle.lineWidth = 1.0f;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineCap = kCGLineCapButt;
    minorLineStyle.lineColor = [CPColor blackColor];
    minorLineStyle.lineWidth = 1.0f;
	
    CPXYAxis *x = axisSet.xAxis;
	CPTextStyle *blackTextStyle = [[[CPTextStyle alloc] init] autorelease];
	blackTextStyle.color = [CPColor blackColor];
	blackTextStyle.fontSize = 14.0;
    x.axisLabelingPolicy = CPAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength = CPDecimalFromString(@"0.5");
    x.constantCoordinateValue = CPDecimalFromString(@"0");
	x.tickDirection = CPSignNone;
    x.minorTicksPerInterval = 4;
    x.majorTickLineStyle = majorLineStyle;
    x.minorTickLineStyle = minorLineStyle;
    x.axisLineStyle = majorLineStyle;
    x.majorTickLength = 7.0f;
    x.minorTickLength = 5.0f;
	x.axisLabelTextStyle = blackTextStyle;
	x.axisTitleTextStyle = blackTextStyle;
	
    CPXYAxis *y = axisSet.yAxis;
    y.axisLabelingPolicy = CPAxisLabelingPolicyFixedInterval;
    y.majorIntervalLength = CPDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 4;
    y.constantCoordinateValue = CPDecimalFromString(@"0");
	y.tickDirection = CPSignNone;
    y.majorTickLineStyle = majorLineStyle;
    y.minorTickLineStyle = minorLineStyle;
    y.axisLineStyle = majorLineStyle;
    y.majorTickLength = 7.0f;
    y.minorTickLength = 5.0f;
	y.axisLabelTextStyle = blackTextStyle;
	y.axisTitleTextStyle = blackTextStyle;
}

@end
