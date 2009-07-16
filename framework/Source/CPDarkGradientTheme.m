
#import "CPDarkGradientTheme.h"
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

@interface CPDarkGradientTheme ()
-(CPXYGraph *)createNewGraph;
-(void)applyThemeToBackground:(CPXYGraph *)graph;
-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea;
-(void)applyThemeToPlotSpace:(CPXYPlotSpace *)plotSpace;
-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet;
-(void)applyThemeToAxis:(CPXYAxis *)axis 
	usingMajorLineStyle:(CPLineStyle *)majorLineStyle 
	  andMinorLineStyle:(CPLineStyle *)minorLineStyle 
		   andTextStyle:(CPTextStyle *)textStyle;
@end

/** @brief Creates a CPXYGraph instance formatted with dark gray gradient backgrounds and light gray lines.
 **/
@implementation CPDarkGradientTheme

/**	@brief The name of the theme.
 *	@return The name.
 **/
+(NSString *)name 
{
	return kCPDarkGradientTheme;
}

/** @brief Creates and returns a new CPXYGraph instance formatted with the theme.
 *  @return A new CPXYGraph instance formatted with the theme.
 **/
-(id)newGraph 
{
    CPXYGraph *graph = [self createNewGraph];	
	[self applyThemeToBackground:graph];
	[self applyThemeToPlotArea:graph.plotArea];
	[self applyThemeToPlotSpace:(CPXYPlotSpace *)graph.defaultPlotSpace];
    [self applyThemeToAxisSet:(CPXYAxisSet *)graph.axisSet];
           
	return graph;
}

#pragma mark -
#pragma mark Implementation private methods

-(CPXYGraph *)createNewGraph {
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
	return graph;
}

-(void)applyThemeToBackground:(CPXYGraph *)graph 
{
	CPColor *endColor = [CPColor colorWithGenericGray:0.1];
	CPGradient *graphGradient = [CPGradient gradientWithBeginningColor:endColor endingColor:endColor];
	graphGradient = [graphGradient addColorStop:[CPColor colorWithGenericGray:0.2] atPosition:0.3];
	graphGradient = [graphGradient addColorStop:[CPColor colorWithGenericGray:0.3] atPosition:0.5];
	graphGradient = [graphGradient addColorStop:[CPColor colorWithGenericGray:0.2] atPosition:0.6];
	graphGradient.angle = 90.0f;
	graph.fill = [CPFill fillWithGradient:graphGradient];
}

-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea 
{
	CPGradient *gradient = [CPGradient gradientWithBeginningColor:[CPColor colorWithGenericGray:0.1] endingColor:[CPColor colorWithGenericGray:0.3]];
    gradient.angle = 90.0;
	plotArea.fill = [CPFill fillWithGradient:gradient]; 
}

-(void)applyThemeToPlotSpace:(CPXYPlotSpace *)plotSpace
{
	plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(1.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.0) length:CPDecimalFromFloat(1.0)];
}

-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet {
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
    borderLineStyle.lineColor = [CPColor colorWithGenericGray:0.2];
    borderLineStyle.lineWidth = 4.0f;
	
	CPBorderedLayer *borderedLayer = (CPBorderedLayer *)axisSet.overlayLayer;
	borderedLayer.borderLineStyle = borderLineStyle;
	borderedLayer.cornerRadius = 10.0f;
	axisSet.overlayLayerInsetX = -4.f;
	axisSet.overlayLayerInsetY = -4.f;
    
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [CPColor colorWithGenericGray:0.5];
    majorLineStyle.lineWidth = 2.0f;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineColor = [CPColor darkGrayColor];
    minorLineStyle.lineWidth = 2.0f;
	
	CPTextStyle *whiteTextStyle = [[[CPTextStyle alloc] init] autorelease];
	whiteTextStyle.color = [CPColor whiteColor];
	whiteTextStyle.fontSize = 14.0;
	
	[self applyThemeToAxis:axisSet.xAxis usingMajorLineStyle:majorLineStyle andMinorLineStyle:minorLineStyle andTextStyle:whiteTextStyle];
	[self applyThemeToAxis:axisSet.yAxis usingMajorLineStyle:majorLineStyle andMinorLineStyle:minorLineStyle andTextStyle:whiteTextStyle];
}

-(void)applyThemeToAxis:(CPXYAxis *)axis usingMajorLineStyle:(CPLineStyle *)majorLineStyle andMinorLineStyle:(CPLineStyle *)minorLineStyle andTextStyle:(CPTextStyle *)textStyle
{
	axis.axisLabelingPolicy = CPAxisLabelingPolicyFixedInterval;
    axis.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
    axis.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"0"];
	axis.tickDirection = CPSignNone;
    axis.minorTicksPerInterval = 4;
    axis.majorTickLineStyle = majorLineStyle;
    axis.minorTickLineStyle = minorLineStyle;
    axis.axisLineStyle = majorLineStyle;
    axis.majorTickLength = 7.0f;
    axis.minorTickLength = 5.0f;
	axis.axisLabelTextStyle = textStyle; 
}

@end
