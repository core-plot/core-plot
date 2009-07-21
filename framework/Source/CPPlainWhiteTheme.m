
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

/**	@brief The name of the theme.
 *	@return The name.
 **/
+(NSString *)name 
{
	return kCPPlainWhiteTheme;
}

/** @brief Creates and returns a new CPXYGraph instance formatted with the theme.
 *  @return A new CPXYGraph instance formatted with the theme.
 **/
-(id)newGraph 
{
	// Create graph
	CPXYGraph *graph;
	if (self.graphClass) {
		graph = [[self.graphClass alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	}
	else {
		graph = [[CPXYGraph alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
	}
	graph.paddingLeft = 60.0;
	graph.paddingTop = 60.0;
	graph.paddingRight = 60.0;
	graph.paddingBottom = 60.0;
	
	// Background
	graph.fill = [CPFill fillWithColor:[CPColor whiteColor]];
	
	// Plot area
	graph.plotArea.fill = [CPFill fillWithColor:[CPColor whiteColor]]; 
	
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(1.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(1.0)];
	
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
	
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
    borderLineStyle.lineColor = [CPColor blackColor];
    borderLineStyle.lineWidth = 1.0f;
	
	CPBorderedLayer *borderedLayer = (CPBorderedLayer *)axisSet.overlayLayer;
	borderedLayer.borderLineStyle = borderLineStyle;
	borderedLayer.cornerRadius = 0.0f;
	axisSet.overlayLayerInsetX = -4.f;
	axisSet.overlayLayerInsetY = -4.f;
    
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
    x.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
    x.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"0"];
	x.tickDirection = CPSignNone;
    x.minorTicksPerInterval = 4;
    x.majorTickLineStyle = majorLineStyle;
    x.minorTickLineStyle = minorLineStyle;
    x.axisLineStyle = majorLineStyle;
    x.majorTickLength = 7.0f;
    x.minorTickLength = 5.0f;
	x.axisLabelTextStyle = blackTextStyle; 
	
    CPXYAxis *y = axisSet.yAxis;
    y.axisLabelingPolicy = CPAxisLabelingPolicyFixedInterval;
    y.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
    y.minorTicksPerInterval = 4;
    y.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"0"];
	y.tickDirection = CPSignNone;
    y.majorTickLineStyle = majorLineStyle;
    y.minorTickLineStyle = minorLineStyle;
    y.axisLineStyle = majorLineStyle;
    y.majorTickLength = 7.0f;
    y.minorTickLength = 5.0f;
	y.axisLabelTextStyle = blackTextStyle;
        
	return graph;
}

/**	@brief A subclass of CPGraph that the graphClass must descend from.
 *	@return The required subclass.
 **/
+(Class)requiredGraphSubclass
{
    return [CPXYGraph class];
}

@end
