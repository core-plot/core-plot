#import "CPTSlateTheme.h"
#import "CPTXYGraph.h"
#import "CPTColor.h"
#import "CPTGradient.h"
#import "CPTFill.h"
#import "CPTPlotAreaFrame.h"
#import "CPTXYPlotSpace.h"
#import "CPTUtilities.h"
#import "CPTXYAxisSet.h"
#import "CPTXYAxis.h"
#import "CPTMutableLineStyle.h"
#import "CPTMutableTextStyle.h"
#import "CPTBorderedLayer.h"
#import "CPTExceptions.h"

NSString * const kCPTSlateTheme = @"Slate";	///< Slate theme.

/**	@cond */
@interface CPTSlateTheme ()

-(void)applyThemeToAxis:(CPTXYAxis *)axis usingMajorLineStyle:(CPTLineStyle *)majorLineStyle minorLineStyle:(CPTLineStyle *)minorLineStyle textStyle:(CPTMutableTextStyle *)textStyle minorTickTextStyle:(CPTMutableTextStyle *)minorTickTextStyle;

@end
/**	@endcond */

#pragma mark -

/** @brief Creates a CPTXYGraph instance with colors that match the default iPhone navigation bar, toolbar buttons, and table views.
 **/
@implementation CPTSlateTheme

+(void)load
{
	[self registerTheme:self];
}

+(NSString *)name 
{
	return kCPTSlateTheme;
}

#pragma mark -

-(void)applyThemeToAxis:(CPTXYAxis *)axis usingMajorLineStyle:(CPTLineStyle *)majorLineStyle minorLineStyle:(CPTLineStyle *)minorLineStyle textStyle:(CPTMutableTextStyle *)textStyle minorTickTextStyle:(CPTMutableTextStyle *)minorTickTextStyle
{
	axis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    axis.majorIntervalLength = CPTDecimalFromDouble(0.5);
    axis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
	axis.tickDirection = CPTSignNone;
    axis.minorTicksPerInterval = 4;
    axis.majorTickLineStyle = majorLineStyle;
    axis.minorTickLineStyle = minorLineStyle;
    axis.axisLineStyle = majorLineStyle;
    axis.majorTickLength = 7.0;
    axis.minorTickLength = 5.0;
	axis.labelTextStyle = textStyle; 
	axis.minorTickLabelTextStyle = minorTickTextStyle; 
	axis.titleTextStyle = textStyle;
}

-(void)applyThemeToBackground:(CPTXYGraph *)graph 
{
	// No background fill has been implemented
}

-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame 
{
	CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:0.43f green:0.51f blue:0.63f alpha:1.0f] endingColor:[CPTColor colorWithComponentRed:0.70f green:0.73f blue:0.80f alpha:1.0f]];
    gradient.angle = 90.0;
	plotAreaFrame.fill = [CPTFill fillWithGradient:gradient]; 
	
	CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
	borderLineStyle.lineColor = [CPTColor colorWithGenericGray:0.2];
	borderLineStyle.lineWidth = 1.0;
	
	plotAreaFrame.borderLineStyle = borderLineStyle;
	plotAreaFrame.cornerRadius = 5.0;
}

-(void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet {
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapSquare;
    majorLineStyle.lineColor = [CPTColor colorWithComponentRed:0.0f green:0.25f blue:0.50f alpha:1.0f];
    majorLineStyle.lineWidth = 2.0;
    
    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineCap = kCGLineCapSquare;
    minorLineStyle.lineColor = [CPTColor blackColor];
    minorLineStyle.lineWidth = 1.0;
	
	CPTMutableTextStyle *blackTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	blackTextStyle.color = [CPTColor blackColor];
	blackTextStyle.fontSize = 14.0;

	CPTMutableTextStyle *minorTickBlackTextStyle = [[[CPTMutableTextStyle alloc] init] autorelease];
	minorTickBlackTextStyle.color = [CPTColor blackColor];
	minorTickBlackTextStyle.fontSize = 12.0;
	
    for (CPTXYAxis *axis in axisSet.axes) {
        [self applyThemeToAxis:axis usingMajorLineStyle:majorLineStyle minorLineStyle:minorLineStyle textStyle:blackTextStyle minorTickTextStyle:minorTickBlackTextStyle];
    }
}

@end
