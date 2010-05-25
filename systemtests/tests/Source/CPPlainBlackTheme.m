
#import "CPPlainBlackTheme.h"
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
#import "CPExceptions.h"

/** @brief Creates a CPXYGraph instance formatted with black backgrounds and white lines.
 **/
@implementation CPPlainBlackTheme

+(NSString *)defaultName 
{
	return kCPPlainBlackTheme;
}

-(void)applyThemeToBackground:(CPXYGraph *)graph 
{
    graph.fill = [CPFill fillWithColor:[CPColor blackColor]];
}

-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea 
{
    plotArea.fill = [CPFill fillWithColor:[CPColor blackColor]]; 

	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor whiteColor];
	borderLineStyle.lineWidth = 1.0f;
	
	plotArea.borderLineStyle = borderLineStyle;
	plotArea.cornerRadius = 0.0f;
}

-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet 
{
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [CPColor whiteColor];
    majorLineStyle.lineWidth = 3.0f;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineColor = [CPColor whiteColor];
    minorLineStyle.lineWidth = 3.0f;
	
    CPXYAxis *x = axisSet.xAxis;
	CPTextStyle *whiteTextStyle = [[[CPTextStyle alloc] init] autorelease];
	whiteTextStyle.color = [CPColor whiteColor];
	whiteTextStyle.fontSize = 14.0;
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
	x.axisLabelTextStyle = whiteTextStyle; 
	x.axisTitleTextStyle = whiteTextStyle;
	
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
	y.axisLabelTextStyle = whiteTextStyle;
	y.axisTitleTextStyle = whiteTextStyle;
}

@end
