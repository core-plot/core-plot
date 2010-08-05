#import "CPPieChart.h"
#import "CPPlotArea.h"
#import "CPColor.h"
#import "CPFill.h"
#import "CPUtilities.h"
#import "CPTextLayer.h"
#import "CPLineStyle.h"

/// @cond
@interface CPPieChart ()

@property (nonatomic, readwrite, assign) id observedObjectForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSArray *normalizedSliceWidths;

-(void)drawSliceInContext:(CGContextRef)context centerPoint:(CGPoint)centerPoint startingValue:(CGFloat)startingValue width:(CGFloat)sliceWidth fill:(CPFill *)sliceFill;
-(CGFloat)radiansForPieSliceValue:(CGFloat)pieSliceValue;
-(CGFloat)normalizedPosition:(CGFloat)rawPosition;

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

/** @property borderLineStyle
 *	@brief The line style used to outline the pie slices.  If nil, no border is drawn.  Defaults to nil.
 **/
@synthesize borderLineStyle;

@dynamic normalizedSliceWidths;

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
		borderLineStyle = nil;
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	[borderLineStyle release];
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
	NSArray *sliceWidths = self.normalizedSliceWidths;
	if ( sliceWidths.count == 0 ) return;

	[super renderAsVectorInContext:context];
	CGRect plotAreaBounds = self.plotArea.bounds;
	CGPoint anchor = self.centerAnchor;
	CGPoint centerPoint = CGPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
									  plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
	centerPoint = [self convertPoint:centerPoint fromLayer:self.plotArea];
	centerPoint = CPAlignPointToUserSpace(context, centerPoint);
	
	CGFloat labelRadius = self.pieRadius + self.sliceLabelOffset;
	
	// TODO: Add NSDecimal rendering path
	
	NSUInteger currentIndex = 0;
	CGFloat startingWidth = 0.0;
	id <CPPieChartDataSource> theDataSource = (id <CPPieChartDataSource>)self.dataSource;
	
	for ( NSNumber *currentWidth in sliceWidths ) {
		CPFill *currentFill = nil;
		if ( [theDataSource respondsToSelector:@selector(sliceFillForPieChart:recordIndex:)] ) {
			CPFill *dataSourceFill = [theDataSource sliceFillForPieChart:self recordIndex:currentIndex];
			if ( nil != dataSourceFill ) currentFill = dataSourceFill;
		}
		else {
			currentFill = [CPFill fillWithColor:[CPPieChart defaultPieSliceColorForIndex:currentIndex]];
		}
		
		CGFloat currentWidthAsDouble = [currentWidth doubleValue];
		
		[self drawSliceInContext:context centerPoint:centerPoint startingValue:startingWidth width:currentWidthAsDouble fill:currentFill];
		
		// Draw the slice label if provided
		if ( [theDataSource respondsToSelector:@selector(sliceLabelForPieChart:recordIndex:)] ) {
			CPTextLayer *textLayer = [theDataSource sliceLabelForPieChart:self recordIndex:currentIndex];

			if ( [textLayer isKindOfClass:[CPTextLayer class]] ) {
				CGContextSaveGState(context);
				
				CGFloat labelAngle = [self radiansForPieSliceValue:startingWidth + currentWidthAsDouble/2.0];
				CGContextTranslateCTM(context, labelRadius*cos(labelAngle) + centerPoint.x - textLayer.bounds.size.width/2.0, labelRadius*sin(labelAngle) + centerPoint.y - textLayer.bounds.size.height/2.0);
				[textLayer renderAsVectorInContext:context];
			
				CGContextRestoreGState(context);
			}
		}
		
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
	bool direction = (self.sliceDirection == CPPieDirectionClockwise) ? true : false;
    CGContextSaveGState(context);
	
	CGMutablePathRef slicePath = CGPathCreateMutable();
	CGPathMoveToPoint(slicePath, nil, centerPoint.x, centerPoint.y);
	CGPathAddArc(slicePath, nil, centerPoint.x, centerPoint.y, self.pieRadius, [self radiansForPieSliceValue:startingValue], [self radiansForPieSliceValue:startingValue + sliceWidth], direction);
	CGPathCloseSubpath(slicePath);

	if ( sliceFill ) {
		CGContextBeginPath(context);
		CGContextAddPath(context, slicePath);
		[sliceFill fillPathInContext:context]; 
	}
	
	// Draw the border line around the slice
	CPLineStyle *borderStyle = self.borderLineStyle;
	if ( borderStyle ) {
		CGContextBeginPath(context);
		CGContextAddPath(context, slicePath);
		[borderStyle setLineStyleInContext:context];
		CGContextStrokePath(context);
	}
	
	CGPathRelease(slicePath);
	CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Responder Chain and User interaction

-(CGFloat)normalizedPosition:(CGFloat)rawPosition
{
	CGFloat result = rawPosition;
	if ( result < 0.0 ) {
		result = 1.0 + result;
	}
#if CGFLOAT_IS_DOUBLE
	result = fmod(result, 1.0);
#else
	result = fmodf(result, 1.0f);
#endif
	return result;
}

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result = NO;
	CPGraph *theGraph = self.graph;
	CPPlotArea *thePlotArea = self.plotArea;
	if ( !theGraph || !thePlotArea ) return NO;
	
	id <CPPieChartDelegate> theDelegate = self.delegate;
	if ( [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:)] ) {
    	// Inform delegate if a slice was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
		
		NSArray *sliceWidths = self.normalizedSliceWidths;
		if ( sliceWidths.count == 0 ) return NO;
		
		CGRect plotAreaBounds = thePlotArea.bounds;
		CGPoint anchor = self.centerAnchor;
		CGPoint centerPoint = CGPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
										  plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
		centerPoint = [self convertPoint:centerPoint fromLayer:thePlotArea];
		
		CGFloat chartRadius = self.pieRadius;
		CGFloat dx = plotAreaPoint.x - centerPoint.x;
		CGFloat dy = plotAreaPoint.y - centerPoint.y;
		CGFloat distanceSquared = dx * dx + dy * dy;
		if ( distanceSquared > chartRadius * chartRadius ) return NO;
		
		CGFloat touchedAngle = [self normalizedPosition:atan2(dy, dx) / (2.0 * M_PI)];
		
		NSUInteger currentIndex = 0;
		CGFloat startingAngle = [self normalizedPosition:self.startAngle / (2.0 * M_PI)];
		
		switch ( self.sliceDirection ) {
			case CPPieDirectionClockwise:
				for ( NSNumber *currentWidth in sliceWidths ) {
					CGFloat width = [currentWidth doubleValue];
					CGFloat endingAngle = startingAngle - width;
					
					if ( (touchedAngle <= startingAngle) && (touchedAngle >= endingAngle) ) {
						[theDelegate pieChart:self sliceWasSelectedAtRecordIndex:currentIndex];
						return YES;
					}
					else if ( (endingAngle < 0.0) && (touchedAngle - 1 >= endingAngle) ) {
						[theDelegate pieChart:self sliceWasSelectedAtRecordIndex:currentIndex];
						return YES;
					}
					
					startingAngle = endingAngle;
					currentIndex++;
				}
				break;
			case CPPieDirectionCounterClockwise:
				for ( NSNumber *currentWidth in sliceWidths ) {
					CGFloat width = [currentWidth doubleValue];
					CGFloat endingAngle = startingAngle + width;
					
					if ( (touchedAngle >= startingAngle) && (touchedAngle <= endingAngle) ) {
						[theDelegate pieChart:self sliceWasSelectedAtRecordIndex:currentIndex];
						return YES;
					}
					else if ( (endingAngle > 1.0) && (touchedAngle + 1 <= endingAngle) ) {
						[theDelegate pieChart:self sliceWasSelectedAtRecordIndex:currentIndex];
						return YES;
					}
				
					startingAngle = endingAngle;
					currentIndex++;
				}
				break;
			default:
				break;
		}
	}
    else {
        result = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    }
    
	return result;
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

- (void) setBorderLineStyle:(CPLineStyle *)newStyle
{
	if ( borderLineStyle != newStyle ) {
		[borderLineStyle release];
		borderLineStyle = [newStyle copy];
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
