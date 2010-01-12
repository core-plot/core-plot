#import "CPPieChart.h"
#import "CPColor.h"
#import "CPFill.h"
#import "CPUtilities.h"

/// @cond
@interface CPPieChart ()

@property (nonatomic, readwrite, assign) id observedObjectForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSArray *normalizedSliceWidths;

-(void)drawSliceInContext:(CGContextRef)context centerPoint:(CGPoint)centerPoint startingValue:(CGFloat)startingValue width:(CGFloat)sliceWidth fill:(CPFill *)sliceFill;

@end
/// @endcond


/** @brief A pie chart.
 **/
@implementation CPPieChart

@synthesize observedObjectForPieSliceWidthValues;
@synthesize keyPathForPieSliceWidthValues;
@synthesize normalizedSliceWidths;

/** @property pieRadius
 *	@brief The radius of the overall pie chart.
 **/
@synthesize pieRadius;

/** @property sliceLabelOffset
 *	@brief The radial offset of the slice labels from the edge of each slice.
 **/
@synthesize sliceLabelOffset;

#pragma mark -
#pragma mark Convenience Factory Methods

static float colorLookupTable[10][3] = 
{    
	{1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {0.0, 0.0, 1.0}, {1.0, 1.0, 0.0}, {0.25, 0.5, 0.25},   
	{1.0, 0, 1.0}, {0.5, 0.5, 0.5}, {0.25, 0.5, 0},    
	{0.25, 0.25, 0.25}, {0, 1.0, 1.0}, 
};

/** @brief Creates and returns a CPColor that acts as the default color for that pie chart index.
 *	@param pieSliceIndex The pie slice index to return a color for.
 *	@return A new CPColor instance corresponding to the default value for this pie slice index.
 **/

+(CPColor *)defaultPieSliceColorForIndex:(NSUInteger)pieSliceIndex;
{
	if (pieSliceIndex > 9)
		return [CPColor colorWithComponentRed:colorLookupTable[pieSliceIndex][0] green:colorLookupTable[pieSliceIndex][1] blue:colorLookupTable[pieSliceIndex][2] alpha:1.0f];
	else
		return [CPColor colorWithComponentRed:(colorLookupTable[pieSliceIndex % 10][0] + (float)(pieSliceIndex / 10) * 0.1f) green:(colorLookupTable[pieSliceIndex % 10][1] + (float)(pieSliceIndex / 10) * 0.1f) blue:(colorLookupTable[pieSliceIndex % 10][2] + (float)(pieSliceIndex / 10) * 0.1f) alpha:1.0f];	
}

#pragma mark -
#pragma mark Initialization

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		pieRadius = 0.8f * (newFrame.size.width / 2.0f);
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
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
	if ([rawSliceValues count] > 0) {
		if ([[rawSliceValues objectAtIndex:0] isKindOfClass:[NSDecimalNumber class]]) {
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
#pragma mark Layout

-(void)layoutSublayers 
{
    [super layoutSublayers];
//    [self addLabelLayers];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if (( self.normalizedSliceWidths == nil ) || ([self.normalizedSliceWidths count] < 1)) return;

	[super renderAsVectorInContext:context];
	CGPoint centerPoint = CPAlignPointToUserSpace(context, CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f));
	// TODO: Add NSDecimal rendering path
	
	NSUInteger currentIndex = 0;
	double startingWidth = 0.0;
	
	for (NSNumber *currentWidth in self.normalizedSliceWidths) {
		CPFill *currentFill = nil;
		if ( [self.dataSource respondsToSelector:@selector(sliceFillForPieChart:recordIndex:)] ) {
			CPFill *dataSourceFill = [(id <CPPieChartDataSource>)self.dataSource sliceFillForPieChart:self recordIndex:currentIndex];
			if ( nil != dataSourceFill ) currentFill = dataSourceFill;
		}
		else {
			currentFill = [CPFill fillWithColor:[CPPieChart defaultPieSliceColorForIndex:currentIndex]];
		}
		
		[self drawSliceInContext:context centerPoint:centerPoint startingValue:startingWidth width:[currentWidth doubleValue] fill:currentFill];
		
		startingWidth += [currentWidth doubleValue];
		
		currentIndex++;
	}
}	

double radiansForPieSliceValue(double pieSliceValue)
{
	// Start from the top of the circle (pi / 2) and proceed in a clockwise direction
	return (M_PI / 2.0) - (pieSliceValue * M_PI * 2.0);
}

-(void)drawSliceInContext:(CGContextRef)context centerPoint:(CGPoint)centerPoint startingValue:(CGFloat)startingValue width:(CGFloat)sliceWidth fill:(CPFill *)sliceFill;
{
    CGContextSaveGState(context);
	
	CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
	CGContextAddArc(context, centerPoint.x, centerPoint.y, self.pieRadius, radiansForPieSliceValue(startingValue), 
					radiansForPieSliceValue(startingValue + sliceWidth), 1);
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
    if (pieRadius != newPieRadius) {
        pieRadius = ABS(newPieRadius);
        [self setNeedsDisplay];
    }
}

@end
