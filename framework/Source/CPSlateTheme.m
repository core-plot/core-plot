#import "CPSlateTheme.h"
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

///	@cond
@interface CPSlateTheme ()

-(void)applyThemeToAxis:(CPXYAxis *)axis usingMajorLineStyle:(CPLineStyle *)majorLineStyle minorLineStyle:(CPLineStyle *)minorLineStyle textStyle:(CPTextStyle *)textStyle;

@end
///	@endcond

#pragma mark -

/** @brief Creates a CPXYGraph instance with colors that match the default iPhone navigation bar, toolbar buttons, and table views.
 **/
@implementation CPSlateTheme

+(NSString *)defaultName 
{
	return kCPSlateTheme;
}

-(void)applyThemeToAxis:(CPXYAxis *)axis usingMajorLineStyle:(CPLineStyle *)majorLineStyle minorLineStyle:(CPLineStyle *)minorLineStyle textStyle:(CPTextStyle *)textStyle
{
	axis.labelingPolicy = CPAxisLabelingPolicyFixedInterval;
    axis.majorIntervalLength = CPDecimalFromDouble(0.5);
    axis.orthogonalCoordinateDecimal = CPDecimalFromDouble(0.0);
	axis.tickDirection = CPSignNone;
    axis.minorTicksPerInterval = 4;
    axis.majorTickLineStyle = majorLineStyle;
    axis.minorTickLineStyle = minorLineStyle;
    axis.axisLineStyle = majorLineStyle;
    axis.majorTickLength = 7.0;
    axis.minorTickLength = 5.0;
	axis.labelTextStyle = textStyle; 
	axis.titleTextStyle = textStyle;
}

-(void)applyThemeToBackground:(CPXYGraph *)graph 
{
	// No background fill has been implemented
}

-(void)applyThemeToPlotArea:(CPPlotAreaFrame *)plotAreaFrame 
{
	CPGradient *gradient = [CPGradient gradientWithBeginningColor:[CPColor colorWithComponentRed:0.43f green:0.51f blue:0.63f alpha:1.0f] endingColor:[CPColor colorWithComponentRed:0.70f green:0.73f blue:0.80f alpha:1.0f]];
    gradient.angle = 90.0;
	plotAreaFrame.fill = [CPFill fillWithGradient:gradient]; 
	
	CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
	borderLineStyle.lineColor = [CPColor colorWithGenericGray:0.2];
	borderLineStyle.lineWidth = 1.0;
	
	plotAreaFrame.borderLineStyle = borderLineStyle;
	plotAreaFrame.cornerRadius = 5.0;
}

-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet {
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapSquare;
    majorLineStyle.lineColor = [CPColor colorWithComponentRed:0.0f green:0.25f blue:0.50f alpha:1.0f];
    majorLineStyle.lineWidth = 2.0;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineCap = kCGLineCapSquare;
    minorLineStyle.lineColor = [CPColor blackColor];
    minorLineStyle.lineWidth = 1.0;
	
	CPTextStyle *blackTextStyle = [[[CPTextStyle alloc] init] autorelease];
	blackTextStyle.color = [CPColor blackColor];
	blackTextStyle.fontSize = 14.0;
	
    for (CPXYAxis *axis in axisSet.axes) {
        [self applyThemeToAxis:axis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle textStyle:blackTextStyle];
    }
}

@end
