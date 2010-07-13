#import "CPPieChart.h"
#import "CPPlotArea.h"
#import "CPColor.h"
#import "CPFill.h"
#import "CPUtilities.h"

/// @cond
@interface CPPieChart ()

@property (nonatomic, readwrite, assign) id observedObjectForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSArray *normalizedSliceWidths;

-(void)drawSliceInContext:(CGContextRef)context centerPoint:(CGPoint)centerPoint startingValue:(CGFloat)startingValue width:(CGFloat)sliceWidth fill:(CPFill *)sliceFill;
-(CGFloat)radiansForPieSliceValue:(CGFloat)pieSliceValue;

@end
/// @endcond

#pragma mark -

/** @brief A pie chart.
 **/
@implementation CPPieChart

@synthesize observedObjectForPieSliceWidthValues;
@synthesize keyPathForPieSliceWidthValues;

/** @property pieRadius
 *	@brief The radius of the overall pie chart. Defaults to 80% of the initial frame size.
 **/
@synthesize pieRadius;

/** @property sliceLabelOffset
 *	@brief The radial offset of the slice labels from the edge of each slice. Defaults to 10.0
 **/
@synthesize sliceLabelOffset;

/** @property startAngle
 *	@brief The starting angle for the first slice in radians. Defaults to pi/2.
 **/
@synthesize startAngle;

/** @property sliceDirection
 *	@brief Determines whether the pie slices are drawn in a clockwise or counter-clockwise
 *	direction from the starting point. Defaults to clockwise.
 **/
@synthesize sliceDirection;

/** @property centerAnchor
 *	@brief The position of the center of the pie chart with the x and y coordinates
 *	given as a fraction of the width and height, respectively. Defaults to (0.5, 0.5).
 **/
@synthesize centerAnchor;

#pragma mark -
#pragma mark Convenience Factory Methods

static CGFloat colorLookupTable[10][3] = 
{    
	{1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}, {1.0, 1.0, 0.0}, {0.25, 0.5, 0.25},   
	{1.0, 0.0, 1.0}, {0.5, 0.5, 0.5}, {0.25, 0.5, 0.0}, {0.25, 0.25, 0.25}, {0.0, 1.0, 1.0}
};

/** @brief Creates and returns a CPColor that acts as the default color for that pie chart index.
 *	@param pieSliceIndex The pie slice index to return a color for.
 *	@return A new CPColor instance corresponding to the default value for this pie slice index.
 **/

+(CPColor *)defaultPieSliceColorForIndex:(NSUInteger)pieSliceIndex;
{
	return [CPColor colorWithComponentRed:(colorLookupTable[pieSliceIndex % 10][0] + (CGFloat)(pieSliceIndex / 10) * 0.1) green:(colorLookupTable[pieSliceIndex % 10][1] + (CGFloat)(pieSliceIndex / 10) * 0.1) blue:(colorLookupTable[pieSliceIndex % 10][2] + (CGFloat)(pieSliceIndex / 10) * 0.1) alpha:1.0];	
}

#pragma mark -
#pragma mark Initialization

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		pieRadius = 0.8 * (MIN(newFrame.size.width, newFrame.size.height) / 2.0);
		startAngle = M_PI_2;	// pi/2
		sliceDirection = CPPieDirectionClockwise;
		sliceLabelOffset = 10.0;
		centerAnchor = CGPointMake(0.5, 0.5);
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	observedObjectForPieSliceWidthValues = nil;
	[keyPathForPieSliceWidthValues release];
	[super dealloc];
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadData 
{	 
	[super reloadData];

	self.normalizedSliceWidths = nil;
	
    // Pie slice widths
	NSArray *rawSliceValues = nil;
    if ( self.observedObjectForPieSliceWidthValues ) {
        // Use bindings to retrieve data
        rawSliceValues = [self.observedObjectForPieSliceWidthValues valueForKeyPath:self.keyPathForPieSliceWidthValues];
    }
    else if ( self.dataSource ) {
		// Grab all values from the data source
        NSRange indexRange = NSMakeRange(0, [self.dataSource numberOfRecordsForPlot:self]);
		rawSliceValues = [self numbersFromDataSourceForField:CPPieChartFieldSliceWidth recordIndexRange:indexRange];
    }
	
	// Normalize these widths to 1.0 for the whole pie
	if ( [rawSliceValues count] > 0 ) {
		if ( [[rawSliceValues objectAtIndex:0] isKindOfClass:[NSDecimalNumber class]] ) {
			NSDecimal valueSum = [[NSDecimalNumber zero] decimalValue];
			for (NSNumber *currentWidth in rawSliceValues) {
				valueSum = CPDecimalAdd(valueSum, [currentWidth decimalValue]);
			}
			NSMutableArray *normalizedSliceValues = [[NSMutableArray alloc] initWithCapacity:[rawSliceValues count]];
			for (NSNumber *currentWidth in rawSliceValues) {
				NSDecimal normalizedWidth = CPDecimalDivide([currentWidth decimalValue], valueSum);
				NSDecimalNumber *normalizedValue = [[NSDecimalNumber alloc] initWithDecimal:normalizedWidth];
				[normalizedSliceValues addObject:normalizedValue];
				[normalizedValue release];
			}
			self.normalizedSliceWidths = normalizedSliceValues;
			[normalizedSliceValues release];
		}
		else {
			double valueSum = 0.0;
			for (NSNumber *currentWidth in rawSliceValues) {
				valueSum += [currentWidth doubleValue];
			}
			NSMutableArray *normalizedSliceValues = [[NSMutableArray alloc] initWithCapacity:[rawSliceValues count]];
			for (NSNumber *currentWidth in rawSliceValues) {
				NSNumber *normalizedValue = [[NSNumber alloc] initWithDouble:([currentWidth doubleValue] / valueSum)];
				[normalizedSliceValues addObject:normalizedValue];
				[normalizedValue release];
			}
			self.normalizedSliceWidths = normalizedSliceValues;
			[normalizedSliceValues release];
		}
	}
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if (( self.normalizedSliceWidths == nil ) || ([self.normalizedSliceWidths count] < 1)) return;

	[super renderAsVectorInContext:context];
	CGRect plotAreaBounds = self.plotArea.bounds;
	CGPoint anchor = self.centerAnchor;
	CGPoint centerPoint = CGPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
									  plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
	centerPoint = [self convertPoint:centerPoint fromLayer:self.plotArea];
	centerPoint = CPAlignPointToUserSpace(context, centerPoint);
	// TODO: Add NSDecimal rendering path
	
	NSUInteger currentIndex = 0;
	CGFloat startingWidth = 0.0;
	
	for ( NSNumber *currentWidth in self.normalizedSliceWidths ) {
		CPFill *currentFill = nil;
		if ( [self.dataSource respondsToSelector:@selector(sliceFillForPieChart:recordIndex:)] ) {
			CPFill *dataSourceFill = [(id <CPPieChartDataSource>)self.dataSource sliceFillForPieChart:self recordIndex:currentIndex];
			if ( nil != dataSourceFill ) currentFill = dataSourceFill;
		}
		else {
			currentFill = [CPFill fillWithColor:[CPPieChart defaultPieSliceColorForIndex:currentIndex]];
		}
		
		CGFloat currentWidthAsDouble = [currentWidth doubleValue];
		
		[self drawSliceInContext:context centerPoint:centerPoint startingValue:startingWidth width:currentWidthAsDouble fill:currentFill];
		
		startingWidth += currentWidthAsDouble;
		
		currentIndex++;
	}
}	

-(CGFloat)radiansForPieSliceValue:(CGFloat)pieSliceValue
{
	CGFloat angle = self.startAngle;
	switch ( self.sliceDirection ) {
		case CPPieDirectionClockwise:
			angle -= pieSliceValue * M_PI * 2.0;
			break;
		case CPPieDirectionCounterClockwise:
			angle += pieSliceValue * M_PI * 2.0;
			break;
	}
	return angle;
}

-(void)drawSliceInContext:(CGContextRef)context centerPoint:(CGPoint)centerPoint startingValue:(CGFloat)startingValue width:(CGFloat)sliceWidth fill:(CPFill *)sliceFill;
{
	int direction = 0;
	if ( self.sliceDirection == CPPieDirectionClockwise ) {
		direction = 1;
	}
    CGContextSaveGState(context);
	
	CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
	CGContextAddArc(context, centerPoint.x, centerPoint.y, self.pieRadius, [self radiansForPieSliceValue:startingValue], [self radiansForPieSliceValue:startingValue + sliceWidth], direction);
	CGContextClosePath(context);
	
	[sliceFill fillPathInContext:context]; 
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Accessors

-(NSArray *)normalizedSliceWidths {
    return [self cachedNumbersForField:CPPieChartFieldSliceWidth];
}

-(void)setNormalizedSliceWidths:(NSArray *)newSliceWidths 
{
    [self cacheNumbers:[[newSliceWidths copy] autorelease] forField:CPPieChartFieldSliceWidth];
}

-(void)setPieRadius:(CGFloat)newPieRadius 
{
    if ( pieRadius != newPieRadius ) {
        pieRadius = ABS(newPieRadius);
        [self setNeedsDisplay];
    }
}

-(void)setCenterAnchor:(CGPoint)newCenterAnchor 
{
    if ( !CGPointEqualToPoint(centerAnchor, newCenterAnchor) ) {
        centerAnchor = newCenterAnchor;
        [self setNeedsDisplay];
    }
}

@end
