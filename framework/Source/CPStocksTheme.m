
#import "CPStocksTheme.h"
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

/** @brief Creates a CPXYGraph instance formatted with a gradient background and white lines.
 **/
@implementation CPStocksTheme

+(NSString *)defaultName 
{
	return kCPStocksTheme;
}

-(void)applyThemeToBackground:(CPXYGraph *)graph 
{	
    graph.fill = [CPFill fillWithColor:[CPColor blackColor]];
}
	
-(void)applyThemeToPlotArea:(CPPlotAreaFrame *)plotAreaFrame
{	
    CPGradient *stocksBackgroundGradient = [[[CPGradient alloc] init] autorelease];
    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.21569 green:0.28627 blue:0.44706 alpha:1.0] atPosition:0.0];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.09412 green:0.17255 blue:0.36078 alpha:1.0] atPosition:0.5];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.05882 green:0.13333 blue:0.33333 alpha:1.0] atPosition:0.5];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.05882 green:0.13333 blue:0.33333 alpha:1.0] atPosition:1.0];
    stocksBackgroundGradient.angle = 270.0;
	plotAreaFrame.fill = [CPFill fillWithGradient:stocksBackgroundGradient];

	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor colorWithGenericGray:0.2];
	borderLineStyle.lineWidth = 0.0;
	
	plotAreaFrame.borderLineStyle = borderLineStyle;
	plotAreaFrame.cornerRadius = 14.0;
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
