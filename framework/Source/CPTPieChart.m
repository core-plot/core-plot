#import "CPTPieChart.h"

#import "CPTColor.h"
#import "CPTFill.h"
#import "CPTLegend.h"
#import "CPTLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTNumericData.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTTextLayer.h"
#import "CPTUtilities.h"
#import "NSCoderExtensions.h"
#import <tgmath.h>

/**	@defgroup plotAnimationPieChart Pie Chart
 *	@ingroup plotAnimation
 **/

/**	@if MacOnly
 *	@defgroup plotBindingsPieChart Pie Chart Bindings
 *	@ingroup plotBindings
 *	@endif
 **/

NSString *const CPTPieChartBindingPieSliceWidthValues = @"sliceWidths"; ///< Pie slice widths.

///	@cond
@interface CPTPieChart()

@property (nonatomic, readwrite, copy) NSArray *sliceWidths;

-(void)updateNormalizedData;
-(CGFloat)radiansForPieSliceValue:(CGFloat)pieSliceValue;
-(CGFloat)normalizedPosition:(CGFloat)rawPosition;
-(BOOL)angle:(CGFloat)touchedAngle betweenStartAngle:(CGFloat)startingAngle endAngle:(CGFloat)endingAngle;

-(void)addSliceToPath:(CGMutablePathRef)slicePath centerPoint:(CGPoint)center startingAngle:(CGFloat)startingAngle finishingAngle:(CGFloat)finishingAngle;
-(CPTFill *)sliceFillForIndex:(NSUInteger)index;

@end

///	@endcond

#pragma mark -

/**
 *	@brief A pie chart.
 *	@see See @ref plotAnimationPieChart "Pie Chart" for a list of animatable properties.
 *	@if MacOnly
 *	@see See @ref plotBindingsPieChart "Pie Chart Bindings" for a list of supported binding identifiers.
 *	@endif
 **/
@implementation CPTPieChart

@dynamic sliceWidths;

/** @property pieRadius
 *	@brief The radius of the overall pie chart. Defaults to 80% of the initial frame size.
 *	@ingroup plotAnimationPieChart
 **/
@synthesize pieRadius;

/** @property pieInnerRadius
 *	@brief The inner radius of the pie chart, used to create a "donut hole". Defaults to 0.
 *	@ingroup plotAnimationPieChart
 **/
@synthesize pieInnerRadius;

/** @property startAngle
 *	@brief The starting angle for the first slice in radians. Defaults to π/2.
 *	@ingroup plotAnimationPieChart
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
 *	@ingroup plotAnimationPieChart
 **/
@synthesize centerAnchor;

/** @property borderLineStyle
 *	@brief The line style used to outline the pie slices.  If <code>nil</code>, no border is drawn.  Defaults to <code>nil</code>.
 **/
@synthesize borderLineStyle;

/** @property overlayFill
 *	@brief A fill drawn on top of the pie chart.
 *  Can be used to add shading and/or gloss effects. Defaults to <code>nil</code>.
 **/
@synthesize overlayFill;

#pragma mark -
#pragma mark Convenience Factory Methods

static const CGFloat colorLookupTable[10][3] =
{
	{
		1.0, 0.0, 0.0
	},{
		0.0, 1.0, 0.0
	},{
		0.0, 0.0, 1.0
	},{
		1.0, 1.0, 0.0
	},{
		0.25, 0.5, 0.25
	},{
		1.0, 0.0, 1.0
	},{
		0.5, 0.5, 0.5
	},{
		0.25, 0.5, 0.0
	},{
		0.25, 0.25, 0.25
	},{
		0.0, 1.0, 1.0
	}
};

/** @brief Creates and returns a CPTColor that acts as the default color for that pie chart index.
 *	@param pieSliceIndex The pie slice index to return a color for.
 *	@return A new CPTColor instance corresponding to the default value for this pie slice index.
 **/

+(CPTColor *)defaultPieSliceColorForIndex:(NSUInteger)pieSliceIndex;
{
	return [CPTColor colorWithComponentRed:(colorLookupTable[pieSliceIndex % 10][0] + (CGFloat)(pieSliceIndex / 10) * (CGFloat)0.1)
									 green:(colorLookupTable[pieSliceIndex % 10][1] + (CGFloat)(pieSliceIndex / 10) * (CGFloat)0.1)
									  blue:(colorLookupTable[pieSliceIndex % 10][2] + (CGFloat)(pieSliceIndex / 10) * (CGFloat)0.1)
									 alpha:1.0];
}

#pragma mark -
#pragma mark Initialization

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
	if ( self == [CPTPieChart class] ) {
		[self exposeBinding:CPTPieChartBindingPieSliceWidthValues];
	}
}

#endif

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPieChart object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTPieChart::pieRadius pieRadius @endlink = 40% of the minimum of the width and height of the frame rectangle
 *	- @link CPTPieChart::pieInnerRadius pieInnerRadius @endlink = 0.0
 *	- @link CPTPieChart::startAngle startAngle @endlink = π/2
 *	- @link CPTPieChart::sliceDirection sliceDirection @endlink = #CPTPieDirectionClockwise
 *	- @link CPTPieChart::centerAnchor centerAnchor @endlink = (0.5, 0.5)
 *	- @link CPTPieChart::borderLineStyle borderLineStyle @endlink = <code>nil</code>
 *	- @link CPTPieChart::overlayFill overlayFill @endlink = <code>nil</code>
 *	- @link CPTPlot::labelOffset labelOffset @endlink = 10.0
 *	- @link CPTPlot::labelField labelField @endlink = #CPTPieChartFieldSliceWidth
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTPieChart object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		pieRadius		= (CGFloat)0.8 * (MIN(newFrame.size.width, newFrame.size.height) / (CGFloat)2.0);
		pieInnerRadius	= 0.0;
		startAngle		= M_PI_2; // pi/2
		sliceDirection	= CPTPieDirectionClockwise;
		centerAnchor	= CGPointMake(0.5, 0.5);
		borderLineStyle = nil;
		overlayFill		= nil;

		self.labelOffset = 10.0;
		self.labelField	 = CPTPieChartFieldSliceWidth;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTPieChart *theLayer = (CPTPieChart *)layer;

		pieRadius		= theLayer->pieRadius;
		pieInnerRadius	= theLayer->pieInnerRadius;
		startAngle		= theLayer->startAngle;
		sliceDirection	= theLayer->sliceDirection;
		centerAnchor	= theLayer->centerAnchor;
		borderLineStyle = [theLayer->borderLineStyle retain];
		overlayFill		= [theLayer->overlayFill retain];
	}
	return self;
}

-(void)dealloc
{
	[borderLineStyle release];
	[overlayFill release];

	[super dealloc];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeCGFloat:self.pieRadius forKey:@"CPTPieChart.pieRadius"];
	[coder encodeCGFloat:self.pieInnerRadius forKey:@"CPTPieChart.pieInnerRadius"];
	[coder encodeCGFloat:self.startAngle forKey:@"CPTPieChart.startAngle"];
	[coder encodeInteger:self.sliceDirection forKey:@"CPTPieChart.sliceDirection"];
	[coder encodeCPTPoint:self.centerAnchor forKey:@"CPTPieChart.centerAnchor"];
	[coder encodeObject:self.borderLineStyle forKey:@"CPTPieChart.borderLineStyle"];
	[coder encodeObject:self.overlayFill forKey:@"CPTPieChart.overlayFill"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		pieRadius		= [coder decodeCGFloatForKey:@"CPTPieChart.pieRadius"];
		pieInnerRadius	= [coder decodeCGFloatForKey:@"CPTPieChart.pieInnerRadius"];
		startAngle		= [coder decodeCGFloatForKey:@"CPTPieChart.startAngle"];
		sliceDirection	= [coder decodeIntegerForKey:@"CPTPieChart.sliceDirection"];
		centerAnchor	= [coder decodeCPTPointForKey:@"CPTPieChart.centerAnchor"];
		borderLineStyle = [[coder decodeObjectForKey:@"CPTPieChart.borderLineStyle"] copy];
		overlayFill		= [[coder decodeObjectForKey:@"CPTPieChart.overlayFill"] copy];
	}
	return self;
}

#pragma mark -
#pragma mark Data Loading

///	@cond

-(void)reloadData
{
	[super reloadData];
	[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsReloadEntriesForPlotNotification object:self];
}

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
	[super reloadDataInIndexRange:indexRange];

	// Pie slice widths
	if ( self.dataSource ) {
		// Grab all values from the data source
		id rawSliceValues = [self numbersFromDataSourceForField:CPTPieChartFieldSliceWidth recordIndexRange:indexRange];
		[self cacheNumbers:rawSliceValues forField:CPTPieChartFieldSliceWidth atRecordIndex:indexRange.location];
	}
	else {
		[self cacheNumbers:nil forField:CPTPieChartFieldSliceWidth];
	}

	[self updateNormalizedData];

	id<CPTPieChartDataSource> theDataSource = (id<CPTPieChartDataSource>)self.dataSource;

	if ( [theDataSource respondsToSelector:@selector(legendTitleForPieChart:recordIndex:)] ||
		 [theDataSource respondsToSelector:@selector(sliceFillForPieChart:recordIndex:)] ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

-(void)insertDataAtIndex:(NSUInteger)index numberOfRecords:(NSUInteger)numberOfRecords
{
	[super insertDataAtIndex:index numberOfRecords:numberOfRecords];
	[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsReloadEntriesForPlotNotification object:self];
}

-(void)deleteDataInIndexRange:(NSRange)indexRange
{
	[super deleteDataInIndexRange:indexRange];
	[self updateNormalizedData];

	[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsReloadEntriesForPlotNotification object:self];
}

-(void)updateNormalizedData
{
	// Normalize these widths to 1.0 for the whole pie
	NSUInteger sampleCount = self.cachedDataCount;

	if ( sampleCount > 0 ) {
		CPTMutableNumericData *rawSliceValues = [self cachedNumbersForField:CPTPieChartFieldSliceWidth];
		if ( self.doublePrecisionCache ) {
			double valueSum			= 0.0;
			const double *dataBytes = (const double *)rawSliceValues.bytes;
			const double *dataEnd	= dataBytes + sampleCount;
			while ( dataBytes < dataEnd ) {
				double currentWidth = *dataBytes++;
				if ( !isnan(currentWidth) ) {
					valueSum += currentWidth;
				}
			}

			CPTNumericDataType dataType = CPTDataType( CPTFloatingPointDataType, sizeof(double), CFByteOrderGetCurrent() );

			CPTMutableNumericData *normalizedSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			normalizedSliceValues.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:sampleCount]];
			CPTMutableNumericData *cumulativeSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			cumulativeSliceValues.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:sampleCount]];

			double cumulativeSum = 0.0;

			dataBytes = (const double *)rawSliceValues.bytes;
			double *normalizedBytes = normalizedSliceValues.mutableBytes;
			double *cumulativeBytes = cumulativeSliceValues.mutableBytes;
			while ( dataBytes < dataEnd ) {
				double currentWidth = *dataBytes++;
				if ( isnan(currentWidth) ) {
					*normalizedBytes++ = NAN;
				}
				else {
					*normalizedBytes++ = currentWidth / valueSum;
					cumulativeSum	  += currentWidth;
				}
				*cumulativeBytes++ = cumulativeSum / valueSum;
			}
			[self cacheNumbers:normalizedSliceValues forField:CPTPieChartFieldSliceWidthNormalized];
			[self cacheNumbers:cumulativeSliceValues forField:CPTPieChartFieldSliceWidthSum];
			[normalizedSliceValues release];
			[cumulativeSliceValues release];
		}
		else {
			NSDecimal valueSum		   = CPTDecimalFromInteger(0);
			const NSDecimal *dataBytes = (const NSDecimal *)rawSliceValues.bytes;
			const NSDecimal *dataEnd   = dataBytes + sampleCount;
			while ( dataBytes < dataEnd ) {
				NSDecimal currentWidth = *dataBytes++;
				if ( !NSDecimalIsNotANumber(&currentWidth) ) {
					valueSum = CPTDecimalAdd(valueSum, currentWidth);
				}
			}

			CPTNumericDataType dataType = CPTDataType( CPTDecimalDataType, sizeof(NSDecimal), CFByteOrderGetCurrent() );

			CPTMutableNumericData *normalizedSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			normalizedSliceValues.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:sampleCount]];
			CPTMutableNumericData *cumulativeSliceValues = [[CPTMutableNumericData alloc] initWithData:[NSData data] dataType:dataType shape:nil];
			cumulativeSliceValues.shape = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInteger:sampleCount]];

			NSDecimal cumulativeSum = CPTDecimalFromInteger(0);

			NSDecimal decimalNAN = CPTDecimalNaN();
			dataBytes = (const NSDecimal *)rawSliceValues.bytes;
			NSDecimal *normalizedBytes = normalizedSliceValues.mutableBytes;
			NSDecimal *cumulativeBytes = cumulativeSliceValues.mutableBytes;
			while ( dataBytes < dataEnd ) {
				NSDecimal currentWidth = *dataBytes++;
				if ( NSDecimalIsNotANumber(&currentWidth) ) {
					*normalizedBytes++ = decimalNAN;
				}
				else {
					*normalizedBytes++ = CPTDecimalDivide(currentWidth, valueSum);
					cumulativeSum	   = CPTDecimalAdd(cumulativeSum, currentWidth);
				}
				*cumulativeBytes++ = CPTDecimalDivide(cumulativeSum, valueSum);
			}
			[self cacheNumbers:normalizedSliceValues forField:CPTPieChartFieldSliceWidthNormalized];
			[self cacheNumbers:cumulativeSliceValues forField:CPTPieChartFieldSliceWidthSum];
			[normalizedSliceValues release];
			[cumulativeSliceValues release];
		}
	}
	else {
		[self cacheNumbers:nil forField:CPTPieChartFieldSliceWidthNormalized];
		[self cacheNumbers:nil forField:CPTPieChartFieldSliceWidthSum];
	}

	// Labels
	[self relabelIndexRange:NSMakeRange(0, [self.dataSource numberOfRecordsForPlot:self])];
}

///	@endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.hidden ) {
		return;
	}

	NSUInteger sampleCount = self.cachedDataCount;
	if ( sampleCount == 0 ) {
		return;
	}

	CPTPlotArea *thePlotArea = self.plotArea;
	if ( !thePlotArea ) {
		return;
	}

	[super renderAsVectorInContext:context];

	CGContextBeginTransparencyLayer(context, NULL);

	CGRect plotAreaBounds = thePlotArea.bounds;
	CGPoint anchor		  = self.centerAnchor;
	CGPoint centerPoint	  = CGPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
										plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
	centerPoint = [self convertPoint:centerPoint fromLayer:self.plotArea];
	if ( self.alignsPointsToPixels ) {
		centerPoint = CPTAlignPointToUserSpace(context, centerPoint);
	}

	NSUInteger currentIndex = 0;
	CGFloat startingWidth	= 0.0;

	id<CPTPieChartDataSource> theDataSource = (id<CPTPieChartDataSource>)self.dataSource;
	BOOL dataSourceProvidesRadialOffsets	= [theDataSource respondsToSelector:@selector(radialOffsetForPieChart:recordIndex:)];

	CPTLineStyle *borderStyle = self.borderLineStyle;
	CPTFill *overlay		  = self.overlayFill;

	CGRect bounds;
	if ( overlay && dataSourceProvidesRadialOffsets ) {
		CGFloat radius = self.pieRadius + borderStyle.lineWidth * (CGFloat)0.5;
		bounds = CGRectMake(centerPoint.x - radius, centerPoint.y - radius, radius * 2.0, radius * 2.0);
	}

	[borderStyle setLineStyleInContext:context];

	while ( currentIndex < sampleCount ) {
		CGFloat currentWidth = [self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:currentIndex];

		if ( !isnan(currentWidth) ) {
			CGFloat radialOffset = 0.0;
			if ( dataSourceProvidesRadialOffsets ) {
				radialOffset = [theDataSource radialOffsetForPieChart:self recordIndex:currentIndex];
			}

			// draw slice
			CGContextSaveGState(context);

			CGFloat startingAngle  = [self radiansForPieSliceValue:startingWidth];
			CGFloat finishingAngle = [self radiansForPieSliceValue:startingWidth + currentWidth];

			CGFloat xOffset = 0.0;
			CGFloat yOffset = 0.0;
			CGPoint center	= centerPoint;
			if ( radialOffset != 0.0 ) {
				CGFloat medianAngle = (CGFloat)0.5 * (startingAngle + finishingAngle);
				xOffset = cos(medianAngle) * radialOffset;
				yOffset = sin(medianAngle) * radialOffset;

				center = CGPointMake(centerPoint.x + xOffset, centerPoint.y + yOffset);

				if ( self.alignsPointsToPixels ) {
					center = CPTAlignPointToUserSpace(context, center);
				}
			}

			CGMutablePathRef slicePath = CGPathCreateMutable();
			[self addSliceToPath:slicePath centerPoint:center startingAngle:startingAngle finishingAngle:finishingAngle];
			CGPathCloseSubpath(slicePath);

			CPTFill *currentFill = [self sliceFillForIndex:currentIndex];
			if ( currentFill ) {
				CGContextBeginPath(context);
				CGContextAddPath(context, slicePath);
				[currentFill fillPathInContext:context];
			}

			// Draw the border line around the slice
			if ( borderStyle ) {
				CGContextBeginPath(context);
				CGContextAddPath(context, slicePath);
				CGContextStrokePath(context);
			}

			// draw overlay for exploded pie charts
			if ( overlay && dataSourceProvidesRadialOffsets ) {
				CGContextSaveGState(context);

				CGContextAddPath(context, slicePath);
				CGContextClip(context);
				[overlay fillRect:CGRectOffset(bounds, xOffset, yOffset) inContext:context];

				CGContextRestoreGState(context);
			}

			CGPathRelease(slicePath);
			CGContextRestoreGState(context);

			startingWidth += currentWidth;
		}
		currentIndex++;
	}

	CGContextEndTransparencyLayer(context);

	// draw overlay all at once if not exploded
	if ( overlay && !dataSourceProvidesRadialOffsets ) {
		// no shadow for the overlay
		CGContextSetShadowWithColor(context, CGSizeZero, 0.0, NULL);

		CGMutablePathRef fillPath = CGPathCreateMutable();

		CGFloat innerRadius = self.pieInnerRadius;
		if ( innerRadius > 0.0 ) {
			CGPathAddArc(fillPath, NULL, centerPoint.x, centerPoint.y, self.pieRadius, 0.0, 2.0 * M_PI, false);
			CGPathAddArc(fillPath, NULL, centerPoint.x, centerPoint.y, innerRadius, 2.0 * M_PI, 0.0, true);
		}
		else {
			CGPathMoveToPoint(fillPath, NULL, centerPoint.x, centerPoint.y);
			CGPathAddArc(fillPath, NULL, centerPoint.x, centerPoint.y, self.pieRadius, 0.0, 2.0 * M_PI, false);
		}
		CGPathCloseSubpath(fillPath);

		CGContextBeginPath(context);
		CGContextAddPath(context, fillPath);
		[overlay fillPathInContext:context];

		CGPathRelease(fillPath);
	}
}

-(CGFloat)radiansForPieSliceValue:(CGFloat)pieSliceValue
{
	CGFloat angle = self.startAngle;

	switch ( self.sliceDirection ) {
		case CPTPieDirectionClockwise:
			angle -= pieSliceValue * (CGFloat)(M_PI * 2.0);
			break;

		case CPTPieDirectionCounterClockwise:
			angle += pieSliceValue * (CGFloat)(M_PI * 2.0);
			break;
	}
	return angle;
}

-(void)addSliceToPath:(CGMutablePathRef)slicePath centerPoint:(CGPoint)center startingAngle:(CGFloat)startingAngle finishingAngle:(CGFloat)finishingAngle
{
	bool direction		= (self.sliceDirection == CPTPieDirectionClockwise) ? true : false;
	CGFloat innerRadius = self.pieInnerRadius;

	if ( innerRadius > 0.0 ) {
		CGPathAddArc(slicePath, NULL, center.x, center.y, self.pieRadius, startingAngle, finishingAngle, direction);
		CGPathAddArc(slicePath, NULL, center.x, center.y, innerRadius, finishingAngle, startingAngle, !direction);
	}
	else {
		CGPathMoveToPoint(slicePath, NULL, center.x, center.y);
		CGPathAddArc(slicePath, NULL, center.x, center.y, self.pieRadius, startingAngle, finishingAngle, direction);
	}
}

-(CPTFill *)sliceFillForIndex:(NSUInteger)index
{
	id<CPTPieChartDataSource> theDataSource = (id<CPTPieChartDataSource>)self.dataSource;
	CPTFill *currentFill					= nil;

	if ( [theDataSource respondsToSelector:@selector(sliceFillForPieChart:recordIndex:)] ) {
		CPTFill *dataSourceFill = [theDataSource sliceFillForPieChart:self recordIndex:index];
		if ( nil != dataSourceFill ) {
			currentFill = dataSourceFill;
		}
	}
	else {
		currentFill = [CPTFill fillWithColor:[CPTPieChart defaultPieSliceColorForIndex:index]];
	}

	return currentFill;
}

-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)index inRect:(CGRect)rect inContext:(CGContextRef)context
{
	[super drawSwatchForLegend:legend atIndex:index inRect:rect inContext:context];

	CPTFill *theFill		   = [self sliceFillForIndex:index];
	CPTLineStyle *theLineStyle = self.borderLineStyle;

	if ( theFill || theLineStyle ) {
		CGPathRef swatchPath;
		CGFloat radius = legend.swatchCornerRadius;
		if ( radius > 0.0 ) {
			radius	   = MIN(MIN(radius, rect.size.width / (CGFloat)2.0), rect.size.height / (CGFloat)2.0);
			swatchPath = CreateRoundedRectPath(rect, radius);
		}
		else {
			CGMutablePathRef mutablePath = CGPathCreateMutable();
			CGPathAddRect(mutablePath, NULL, rect);
			swatchPath = mutablePath;
		}

		if ( theFill ) {
			CGContextBeginPath(context);
			CGContextAddPath(context, swatchPath);
			[theFill fillPathInContext:context];
		}

		if ( theLineStyle ) {
			[theLineStyle setLineStyleInContext:context];
			CGContextBeginPath(context);
			CGContextAddPath(context, swatchPath);
			CGContextStrokePath(context);
		}

		CGPathRelease(swatchPath);
	}
}

/// @endcond

#pragma mark -
#pragma mark Animation

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
	static NSArray *keys = nil;

	if ( !keys ) {
		keys = [[NSArray alloc] initWithObjects:
				@"pieRadius",
				@"pieInnerRadius",
				@"startAngle",
				@"centerAnchor",
				nil];
	}

	if ( [keys containsObject:aKey] ) {
		return YES;
	}
	else {
		return [super needsDisplayForKey:aKey];
	}
}

#pragma mark -
#pragma mark Fields

/// @cond

-(NSUInteger)numberOfFields
{
	return 1;
}

-(NSArray *)fieldIdentifiers
{
	return [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTPieChartFieldSliceWidth]];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
	return nil;
}

/// @endcond

#pragma mark -
#pragma mark Data Labels

/// @cond

-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	CPTLayer *contentLayer	 = label.contentLayer;
	CPTPlotArea *thePlotArea = self.plotArea;

	if ( contentLayer && thePlotArea ) {
		CGRect plotAreaBounds = thePlotArea.bounds;
		CGPoint anchor		  = self.centerAnchor;
		CGPoint centerPoint	  = CGPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
											plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);

		NSDecimal plotPoint[2];
		[self.plotSpace plotPoint:plotPoint forPlotAreaViewPoint:centerPoint];
		NSDecimalNumber *xValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPTCoordinateX]];
		NSDecimalNumber *yValue = [[NSDecimalNumber alloc] initWithDecimal:plotPoint[CPTCoordinateY]];
		label.anchorPlotPoint = [NSArray arrayWithObjects:xValue, yValue, nil];
		[xValue release];
		[yValue release];

		double currentWidth = [self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:index];
		if ( isnan(currentWidth) ) {
			contentLayer.hidden = YES;
		}
		else {
			id<CPTPieChartDataSource> theDataSource = (id<CPTPieChartDataSource>)self.dataSource;
			BOOL dataSourceProvidesRadialOffsets	= [theDataSource respondsToSelector:@selector(radialOffsetForPieChart:recordIndex:)];
			CGFloat radialOffset					= 0.0;
			if ( dataSourceProvidesRadialOffsets ) {
				radialOffset = [theDataSource radialOffsetForPieChart:self recordIndex:index];
			}

			CGFloat labelRadius = self.pieRadius + self.labelOffset + radialOffset;

			double startingWidth = 0.0;
			if ( index > 0 ) {
				startingWidth = [self cachedDoubleForField:CPTPieChartFieldSliceWidthSum recordIndex:index - 1];
			}
			CGFloat labelAngle = [self radiansForPieSliceValue:startingWidth + currentWidth / (CGFloat)2.0];

			label.displacement	= CGPointMake( labelRadius * cos(labelAngle), labelRadius * sin(labelAngle) );
			contentLayer.hidden = NO;
		}
	}
	else {
		label.anchorPlotPoint = nil;
		label.displacement	  = CGPointZero;
	}
}

/// @endcond

#pragma mark -
#pragma mark Legends

///	@cond

/**	@internal
 *	@brief The number of legend entries provided by this plot.
 *	@return The number of legend entries.
 **/
-(NSUInteger)numberOfLegendEntries
{
	[self reloadDataIfNeeded];
	return self.cachedDataCount;
}

/**	@internal
 *	@brief The title text of a legend entry.
 *	@param index The index of the desired title.
 *	@return The title of the legend entry at the requested index.
 **/
-(NSString *)titleForLegendEntryAtIndex:(NSUInteger)index
{
	NSString *legendTitle = nil;

	id<CPTPieChartDataSource> theDataSource = (id<CPTPieChartDataSource>)self.dataSource;

	if ( [theDataSource respondsToSelector:@selector(legendTitleForPieChart:recordIndex:)] ) {
		legendTitle = [theDataSource legendTitleForPieChart:self recordIndex:index];
	}
	else {
		legendTitle = [super titleForLegendEntryAtIndex:index];
	}

	return legendTitle;
}

///	@endcond

#pragma mark -
#pragma mark Responder Chain and User interaction

///	@cond

-(CGFloat)normalizedPosition:(CGFloat)rawPosition
{
	CGFloat result = rawPosition;

	result /= 2.0 * M_PI;
	result	= fmod(result, 1.0);
	if ( result < 0.0 ) {
		result += 1.0;
	}

	return result;
}

-(BOOL)angle:(CGFloat)touchedAngle betweenStartAngle:(CGFloat)startingAngle endAngle:(CGFloat)endingAngle
{
	switch ( self.sliceDirection ) {
		case CPTPieDirectionClockwise:
			if ( (touchedAngle <= startingAngle) && (touchedAngle >= endingAngle) ) {
				return YES;
			}
			else if ( (endingAngle < 0.0) && (touchedAngle - 1.0 >= endingAngle) ) {
				return YES;
			}
			break;

		case CPTPieDirectionCounterClockwise:
			if ( (touchedAngle >= startingAngle) && (touchedAngle <= endingAngle) ) {
				return YES;
			}
			else if ( (endingAngle > 1.0) && (touchedAngle + 1.0 <= endingAngle) ) {
				return YES;
			}
			break;
	}
	return NO;
}

///	@endcond

/// @name User Interaction
/// @{

/**
 *	@brief Informs the receiver that the user has
 *	@if MacOnly pressed the mouse button. @endif
 *	@if iOSOnly touched the screen. @endif
 *
 *
 *	If this plot has a delegate that responds to the
 *	@link CPTPieChartDelegate::pieChart:sliceWasSelectedAtRecordIndex: -pieChart:sliceWasSelectedAtRecordIndex: @endlink
 *	method, the <code>interactionPoint</code> is compared with each slice in index order.
 *	The delegate method will be called and this method returns <code>YES</code> for the first
 *	index where the <code>interactionPoint</code> is inside a pie slice.
 *	This method returns <code>NO</code> if the <code>interactionPoint</code> is outside all of the slices.
 *
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result				 = NO;
	CPTGraph *theGraph		 = self.graph;
	CPTPlotArea *thePlotArea = self.plotArea;

	if ( !theGraph || !thePlotArea ) {
		return NO;
	}

	id<CPTPieChartDelegate> theDelegate = self.delegate;
	if ( [theDelegate respondsToSelector:@selector(pieChart:sliceWasSelectedAtRecordIndex:)] ) {
		// Inform delegate if a slice was hit
		CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];

		NSUInteger sampleCount = self.cachedDataCount;
		if ( sampleCount == 0 ) {
			return NO;
		}

		CGRect plotAreaBounds = thePlotArea.bounds;
		CGPoint anchor		  = self.centerAnchor;
		CGPoint centerPoint	  = CGPointMake(plotAreaBounds.origin.x + plotAreaBounds.size.width * anchor.x,
											plotAreaBounds.origin.y + plotAreaBounds.size.height * anchor.y);
		centerPoint = [self convertPoint:centerPoint fromLayer:thePlotArea];

		id<CPTPieChartDataSource> theDataSource = (id<CPTPieChartDataSource>)self.dataSource;
		BOOL dataSourceProvidesRadialOffsets	= [theDataSource respondsToSelector:@selector(radialOffsetForPieChart:recordIndex:)];

		CGFloat chartRadius				= self.pieRadius;
		CGFloat chartRadiusSquared		= chartRadius * chartRadius;
		CGFloat chartInnerRadius		= self.pieInnerRadius;
		CGFloat chartInnerRadiusSquared = chartInnerRadius * chartInnerRadius;
		CGFloat dx						= plotAreaPoint.x - centerPoint.x;
		CGFloat dy						= plotAreaPoint.y - centerPoint.y;
		CGFloat distanceSquared			= dx * dx + dy * dy;

		CGFloat touchedAngle  = [self normalizedPosition:atan2(dy, dx)];
		CGFloat startingAngle = [self normalizedPosition:self.startAngle];

		switch ( self.sliceDirection ) {
			case CPTPieDirectionClockwise:
				for ( NSUInteger currentIndex = 0; currentIndex < sampleCount; currentIndex++ ) {
					// calculate angles for this slice
					CGFloat width = [self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:currentIndex];
					if ( isnan(width) ) {
						continue;
					}
					CGFloat endingAngle = startingAngle - width;

					// offset the center point of the slice if needed
					CGFloat offsetTouchedAngle	  = touchedAngle;
					CGFloat offsetDistanceSquared = distanceSquared;
					CGFloat radialOffset		  = 0.0;
					if ( dataSourceProvidesRadialOffsets ) {
						radialOffset = [theDataSource radialOffsetForPieChart:self recordIndex:currentIndex];

						if ( radialOffset != 0.0 ) {
							CGPoint offsetCenter;
							CGFloat medianAngle = (CGFloat)M_PI * (startingAngle + endingAngle);
							offsetCenter = CGPointMake(centerPoint.x + cos(medianAngle) * radialOffset,
													   centerPoint.y + sin(medianAngle) * radialOffset);

							dx = plotAreaPoint.x - offsetCenter.x;
							dy = plotAreaPoint.y - offsetCenter.y;

							offsetTouchedAngle	  = [self normalizedPosition:atan2(dy, dx)];
							offsetDistanceSquared = dx * dx + dy * dy;
						}
					}

					// check angles
					BOOL angleInSlice = NO;
					if ( [self angle:touchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
						if ( [self angle:offsetTouchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
							angleInSlice = YES;
						}
						else {
							return NO;
						}
					}

					// check distance
					if ( angleInSlice && (offsetDistanceSquared >= chartInnerRadiusSquared) && (offsetDistanceSquared <= chartRadiusSquared) ) {
						[theDelegate pieChart:self sliceWasSelectedAtRecordIndex:currentIndex];
						return YES;
					}

					// save angle for the next slice
					startingAngle = endingAngle;
				}
				break;

			case CPTPieDirectionCounterClockwise:
				for ( NSUInteger currentIndex = 0; currentIndex < sampleCount; currentIndex++ ) {
					// calculate angles for this slice
					CGFloat width = [self cachedDoubleForField:CPTPieChartFieldSliceWidthNormalized recordIndex:currentIndex];
					if ( isnan(width) ) {
						continue;
					}
					CGFloat endingAngle = startingAngle + width;

					// offset the center point of the slice if needed
					CGFloat offsetTouchedAngle	  = touchedAngle;
					CGFloat offsetDistanceSquared = distanceSquared;
					CGFloat radialOffset		  = 0.0;
					if ( dataSourceProvidesRadialOffsets ) {
						radialOffset = [theDataSource radialOffsetForPieChart:self recordIndex:currentIndex];

						if ( radialOffset != 0.0 ) {
							CGPoint offsetCenter;
							CGFloat medianAngle = (CGFloat)M_PI * (startingAngle + endingAngle);
							offsetCenter = CGPointMake(centerPoint.x + cos(medianAngle) * radialOffset,
													   centerPoint.y + sin(medianAngle) * radialOffset);

							dx = plotAreaPoint.x - offsetCenter.x;
							dy = plotAreaPoint.y - offsetCenter.y;

							offsetTouchedAngle	  = [self normalizedPosition:atan2(dy, dx)];
							offsetDistanceSquared = dx * dx + dy * dy;
						}
					}

					// check angles
					BOOL angleInSlice = NO;
					if ( [self angle:touchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
						if ( [self angle:offsetTouchedAngle betweenStartAngle:startingAngle endAngle:endingAngle] ) {
							angleInSlice = YES;
						}
						else {
							return NO;
						}
					}

					// check distance
					if ( angleInSlice && (offsetDistanceSquared >= chartInnerRadiusSquared) && (offsetDistanceSquared <= chartRadiusSquared) ) {
						[theDelegate pieChart:self sliceWasSelectedAtRecordIndex:currentIndex];
						return YES;
					}

					// save angle for the next slice
					startingAngle = endingAngle;
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

///	@}

#pragma mark -
#pragma mark Accessors

///	@cond

-(NSArray *)sliceWidths
{
	return [[self cachedNumbersForField:CPTPieChartFieldSliceWidthNormalized] sampleArray];
}

-(void)setSliceWidths:(NSArray *)newSliceWidths
{
	[self cacheNumbers:newSliceWidths forField:CPTPieChartFieldSliceWidthNormalized];
	[self updateNormalizedData];
}

-(void)setPieRadius:(CGFloat)newPieRadius
{
	if ( pieRadius != newPieRadius ) {
		pieRadius = ABS(newPieRadius);
		[self setNeedsDisplay];
		[self repositionAllLabelAnnotations];
	}
}

-(void)setPieInnerRadius:(CGFloat)newPieRadius
{
	if ( pieInnerRadius != newPieRadius ) {
		pieInnerRadius = ABS(newPieRadius);
		[self setNeedsDisplay];
	}
}

-(void)setStartAngle:(CGFloat)newAngle
{
	if ( newAngle != startAngle ) {
		startAngle = newAngle;
		[self setNeedsDisplay];
		[self repositionAllLabelAnnotations];
	}
}

-(void)setSliceDirection:(CPTPieDirection)newDirection
{
	if ( newDirection != sliceDirection ) {
		sliceDirection = newDirection;
		[self setNeedsDisplay];
		[self repositionAllLabelAnnotations];
	}
}

-(void)setBorderLineStyle:(CPTLineStyle *)newStyle
{
	if ( borderLineStyle != newStyle ) {
		[borderLineStyle release];
		borderLineStyle = [newStyle copy];
		[self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

-(void)setCenterAnchor:(CGPoint)newCenterAnchor
{
	if ( !CGPointEqualToPoint(centerAnchor, newCenterAnchor) ) {
		centerAnchor = newCenterAnchor;
		[self setNeedsDisplay];
		[self repositionAllLabelAnnotations];
	}
}

///	@endcond

@end
