
#import "CPPlainBlackTheme.h"
#import "CPXYGraph.h"
#import "CPColor.h"
#import "CPGradient.h"
#import "CPFill.h"
#import "CPPlotAreaFrame.h"
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

-(void)applyThemeToPlotArea:(CPPlotAreaFrame *)plotAreaFrame
{
    plotAreaFrame.fill = [CPFill fillWithColor:[CPColor blackColor]]; 

	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor whiteColor];
	borderLineStyle.lineWidth = 1.0;
	
	plotAreaFrame.borderLineStyle = borderLineStyle;
	plotAreaFrame.cornerRadius = 0.0;
}

-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet 
{
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [CPColor whiteColor];
    majorLineStyle.lineWidth = 3.0;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineColor = [CPColor whiteColor];
    minorLineStyle.lineWidth = 3.0;
	
    CPXYAxis *x = axisSet.xAxis;
	CPTextStyle *whiteTextStyle = [[[CPTextStyle alloc] init] autorelease];
	whiteTextStyle.color = [CPColor whiteColor];
	whiteTextStyle.fontSize = 14.0;
    x.labelingPolicy = CPAxisLabelingPolicyFixedInterval;
    x.majorIntervalLength = CPDecimalFromDouble(0.5);
    x.orthogonalCoordinateDecimal = CPDecimalFromDouble(0.0);
	x.tickDirection = CPSignNone;
    x.minorTicksPerInterval = 4;
    x.majorTickLineStyle = majorLineStyle;
    x.minorTickLineStyle = minorLineStyle;
    x.axisLineStyle = majorLineStyle;
    x.majorTickLength = 7.0;
    x.minorTickLength = 5.0;
	x.labelTextStyle = whiteTextStyle; 
	x.titleTextStyle = whiteTextStyle;
	
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
	y.labelTextStyle = whiteTextStyle;
	y.titleTextStyle = whiteTextStyle;
}

@end
