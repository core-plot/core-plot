
#import "CPStocksTheme.h"
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
	
-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea 
{	
    CPGradient *stocksBackgroundGradient = [[[CPGradient alloc] init] autorelease];
    stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.21569f green:0.28627f blue:0.44706f alpha:1.0f] atPosition:0.0f];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.09412f green:0.17255f blue:0.36078f alpha:1.0f] atPosition:0.5f];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.05882f green:0.13333f blue:0.33333f alpha:1.0f] atPosition:0.5f];
	stocksBackgroundGradient = [stocksBackgroundGradient addColorStop:[CPColor colorWithComponentRed:0.05882f green:0.13333f blue:0.33333f alpha:1.0f] atPosition:1.0f];
    stocksBackgroundGradient.angle = 270.0;
	plotArea.fill = [CPFill fillWithGradient:stocksBackgroundGradient];

	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor colorWithGenericGray:0.2];
	borderLineStyle.lineWidth = 0.0f;
	
	plotArea.borderLineStyle = borderLineStyle;
	plotArea.cornerRadius = 14.0f;
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
