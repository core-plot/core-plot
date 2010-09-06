#import "CPMutableNumericData.h"
#import "CPNumericData.h"
#import "CPPieChart.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPPlotSpaceAnnotation.h"
#import "CPColor.h"
#import "CPFill.h"
#import "CPUtilities.h"
#import "CPTextLayer.h"
#import "CPLineStyle.h"

NSString * const CPPieChartBindingPieSliceWidthValues = @"sliceWidths";		///< Pie slice widths.

static NSString * const CPPieChartBindingPieSliceWidthContext = @"CPPieChartBindingPieSliceWidthContext";

/// @cond
@interface CPPieChart ()

@property (nonatomic, readwrite, assign) id observedObjectForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForPieSliceWidthValues;
@property (nonatomic, readwrite, copy) NSArray *sliceWidths;

-(void)updateNormalizedDataInRange:(NSRange)indexRange;
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
@dynamic sliceWidths;

/** @property pieRadius
 *	@brief The radius of the overall pie chart. Defaults to 80% of the initial frame size.
 **/
@synthesize pieRadius;

/** @property sliceLabelOffset
 *	@brief The radial offset of the slice labels from the edge of each slice. Defaults to 10.0
 *	@deprecated This property has been replaced by the CPPlot::labelOffset property.
 **/
@dynamic sliceLabelOffset;

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

+(void)initialize
{
	if ( self == [CPPieChart class] ) {
		[self exposeBinding:CPPieChartBindingPieSliceWidthValues];	
	}
}

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		pieRadius = 0.8 * (MIN(newFrame.size.width, newFrame.size.height) / 2.0);
		startAngle = M_PI_2;	// pi/2
		sliceDirection = CPPieDirectionClockwise;
		centerAnchor = CGPointMake(0.5, 0.5);
		borderLineStyle = nil;
		
		self.labelOffset = 10.0;
		self.labelField = CPPieChartFieldSliceWidth;
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
#pragma mark Bindings

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
	if ( [binding isEqualToString:CPPieChartBindingPieSliceWidthValues] ) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPPieChartBindingPieSliceWidthContext];
		self.observedObjectForPieSliceWidthValues = observable;
		self.keyPathForPieSliceWidthValues = keyPath;
		[self setDataNeedsReloading];
	}
}

-(void)unbind:(NSString *)bindingName
{
	if ( [bindingName isEqualToString:CPPieChartBindingPieSliceWidthValues] ) {
		[self.observedObjectForPieSliceWidthValues removeObserver:self forKeyPath:self.keyPathForPieSliceWidthValues];
		self.observedObjectForPieSliceWidthValues = nil;
		self.keyPathForPieSliceWidthValues = nil;
		[self setDataNeedsReloading];
	}	
	[super unbind:bindingName];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( context == CPPieChartBindingPieSliceWidthContext ) {
		[self setDataNeedsReloading];
	}
}

-(Class)valueClassForBinding:(NSString *)binding
{
	if ( [binding isEqualToString:CPPieChartBindingPieSliceWidthValues] ) {
		return [NSArray class];
	}
	else {
		return [super valueClassForBinding:binding];
	}
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadData 
{	 
	[super reloadData];

	NSRange indexRange = NSMakeRange(0, 0);
	
    // Pie slice widths
    if ( self.observedObjectForPieSliceWidthValues ) {
        // Use bindings to retrieve data
		id rawSliceValues = [self.observedObjectForPieSliceWidthValues valueForKeyPath:self.keyPathForPieSliceWidthValues];
		[self cacheNumbers:rawSliceValues forField:CPPieChartFieldSliceWidth];
		
		indexRange = NSMakeRange(0, self.cachedDataCount);
    }
    else if ( self.dataSource ) {
		// Grab all values from the data source
        indexRange = NSMakeRange(0, [self.dataSource numberOfRecordsForPlot:self]);
		id rawSliceValues = [self numbersFromDataSourceForField:CPPieChartFieldSliceWidth recordIndexRange:indexRange];
		[self cacheNumbers:rawSliceValues forField:CPPieChartFieldSliceWidth];
    }
	else {
		[self cacheNumbers:nil forField:CPPieChartFieldSliceWidth];
	}
	
	[self updateNormalizedDataInRange:indexRange];
}

-(void)updateNormalizedDataInRange:(NSRange)indexRange
{
	// Normalize these widths to 1.0 for the whole pie
	NSUInteger sampleCount = self.cachedDataCount;
	if ( sampleCount > 0 ) {
		CPMutableNumericData *rawSliceValues = [self cachedNumbersForField:CPPieChartFieldSliceWidth];
		if ( self.doublePrecisionCache ) {
			double valueSum = 0.0;
			const double *dataBytes = (const double *)rawSliceValues.bytes;
			const double *dataEnd = dataBytes + sampleCount;
			while ( dataBytes < dataEnd ) {
				valueSum += *dataBytes++;
			}
			
			CPNumericDataType dataType = CPDataType(CPFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent());
			
			CPMutableNumericData *normalizedSliceValues = [[CPMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			((NSMutableData *)normalizedSliceValues.data).length = sampleCount * sizeof(double);
			CPMutableNumericData *cumulativeSliceValues = [[CPMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			((NSMutableData *)cumulativeSliceValues.data).length = sampleCount * sizeof(double);
			
			double cumulativeSum = 0.0;
			
			dataBytes = (const double *)rawSliceValues.bytes;
			double *normalizedBytes = normalizedSliceValues.mutableBytes;
			double *cumulativeBytes = cumulativeSliceValues.mutableBytes;
			while ( dataBytes < dataEnd ) {
				double currentWidth = *dataBytes++;
				*normalizedBytes++ = currentWidth / valueSum;
				
				cumulativeSum += currentWidth;
				*cumulativeBytes++ = cumulativeSum / valueSum;
			}
			[self cacheNumbers:normalizedSliceValues forField:CPPieChartFieldSliceWidthNormalized];
			[self cacheNumbers:cumulativeSliceValues forField:CPPieChartFieldSliceWidthSum];
			[normalizedSliceValues release];
			[cumulativeSliceValues release];
		}
		else {
			NSDecimal valueSum = CPDecimalFromInteger(0);
			const NSDecimal *dataBytes = (const NSDecimal *)rawSliceValues.bytes;
			const NSDecimal *dataEnd = dataBytes + sampleCount;
			while ( dataBytes < dataEnd ) {
				valueSum = CPDecimalAdd(valueSum, *dataBytes++);
			}
			
			CPNumericDataType dataType = CPDataType(CPDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent());
			
			CPMutableNumericData *normalizedSliceValues = [[CPMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			((NSMutableData *)normalizedSliceValues.data).length = sampleCount * sizeof(NSDecimal);
			CPMutableNumericData *cumulativeSliceValues = [[CPMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			((NSMutableData *)cumulativeSliceValues.data).length = sampleCount * sizeof(NSDecimal);
			
			NSDecimal cumulativeSum = CPDecimalFromInteger(0);
			
			dataBytes = (const NSDecimal *)rawSliceValues.bytes;
			NSDecimal *normalizedBytes = normalizedSliceValues.mutableBytes;
			NSDecimal *cumulativeBytes = cumulativeSliceValues.mutableBytes;
			while ( dataBytes < dataEnd ) {
				NSDecimal currentWidth = *dataBytes++;
				*normalizedBytes++ = CPDecimalDivide(currentWidth, valueSum);
				
				cumulativeSum = CPDecimalAdd(cumulativeSum, currentWidth);
				*cumulativeBytes++ = CPDecimalDivide(cumulativeSum, valueSum);
			}
			[self cacheNumbers:normalizedSliceValues forField:CPPieChartFieldSliceWidthNormalized];
			[self cacheNumbers:cumulativeSliceValues forField:CPPieChartFieldSliceWidthSum];
			[normalizedSliceValues release];
			[cumulativeSliceValues release];
		}
	}
	else {
		[self cacheNumbers:nil forField:CPPieChartFieldSliceWidthNormalized];
		[self cacheNumbers:nil forField:CPPieChartFieldSliceWidthSum];
	}
	
	// Labels
	[self relabelIndexRange:indexRange];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	NSUInteger sampleCount = self.cachedDataCount;
	if ( sampleCount == 0 ) return;

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
	id <CPPieChartDataSource> theDataSource = (id <CPPieChartDataSource>)self.dataSource;
	BOOL dataSourceProvidesFills = [theDataSource respondsToSelector:@selector(sliceFillForPieChart:recordIndex:)];
	
	while ( currentIndex < sampleCount ) {
		CPFill *currentFill = nil;
		if ( dataSourceProvidesFills ) {
			CPFill *dataSourceFill = [theDataSource sliceFillForPieChart:self recordIndex:currentIndex];
			if ( nil != dataSourceFill ) currentFill = dataSourceFill;
		}
		else {
			currentFill = [CPFill fillWithColor:[CPPieChart defaultPieSliceColorForIndex:currentIndex]];
		}
		
		CGFloat currentWidth = [self cachedDoubleForField:CPPieChartFieldSliceWidthNormalized recordIndex:currentIndex];
		
		[self drawSliceInContext:context centerPoint:centerPoint startingValue:startingWidth width:currentWidth fill:currentFill];
		
		startingWidth += currentWidth;
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
#pragma mark Fields

-(NSUInteger)numberOfFields 
{
    return 1;
}

-(NSArray *)fieldIdentifiers 
{
    return [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPPieChartFieldSliceWidth]];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord 
{
	return nil;
}

#pragma mark -
#pragma mark Data Labels

-(void)positionLabelAnnotation:(CPPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	CGRect plotAreaBounds = self.plotArea.bounds;
	CGPoint anchor = self.centerAnchor;
	CGPoint centerPoint = CGPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
									  plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
	
	NSDecimal plotPoint[2];
	[self.plotSpace plotPoint:plotPoint forPlotAreaViewPoint:centerPoint];
	NSDecimalNumber *xValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPCoordinateX]];
	NSDecimalNumber *yValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPCoordinateY]];
	label.anchorPlotPoint = [NSArray arrayWithObjects:xValue, yValue, nil];
	[xValue release];
	[yValue release];
	
	CGFloat labelRadius = self.pieRadius + self.labelOffset;
	
	double startingWidth = 0.0;
	if ( index > 0 ) {
		startingWidth = [self cachedDoubleForField:CPPieChartFieldSliceWidthSum recordIndex:index - 1];
	}
	double currentWidth = [self cachedDoubleForField:CPPieChartFieldSliceWidthNormalized recordIndex:index];
	
	double labelAngle = [self radiansForPieSliceValue:startingWidth + currentWidth / 2.0];
	
	label.displacement = CGPointMake(labelRadius * cos(labelAngle), labelRadius * sin(labelAngle));
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
		
		NSUInteger sampleCount = self.cachedDataCount;
		if ( sampleCount == 0 ) return NO;
		
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
		CGFloat startingAngle = [self normalizedPosition:self.startAngle / (2.0 * M_PI)];
		
		switch ( self.sliceDirection ) {
			case CPPieDirectionClockwise:
				for ( NSUInteger currentIndex = 0; currentIndex < sampleCount; currentIndex++ ) {
					CGFloat width = [self cachedDoubleForField:CPPieChartFieldSliceWidthNormalized recordIndex:currentIndex];
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
				for ( NSUInteger currentIndex = 0; currentIndex < sampleCount; currentIndex++ ) {
					CGFloat width = [self cachedDoubleForField:CPPieChartFieldSliceWidthNormalized recordIndex:currentIndex];
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

-(NSArray *)sliceWidths {
    return [[self cachedNumbersForField:CPPieChartFieldSliceWidthNormalized] sampleArray];
}

-(void)setSliceWidths:(NSArray *)newSliceWidths 
{
    [self cacheNumbers:newSliceWidths forField:CPPieChartFieldSliceWidthNormalized];
	[self updateNormalizedDataInRange:NSMakeRange(0, newSliceWidths.count)];
}

-(void)setPieRadius:(CGFloat)newPieRadius 
{
    if ( pieRadius != newPieRadius ) {
        pieRadius = ABS(newPieRadius);
        [self setNeedsDisplay];
		[self setNeedsRelabel];
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
		[self setNeedsRelabel];
    }
}

-(CGFloat)sliceLabelOffset
{
	return self.labelOffset;
}

-(void)setSliceLabelOffset:(CGFloat)newOffset 
{
    self.labelOffset = newOffset;
}

@end
