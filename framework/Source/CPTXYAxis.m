#import "CPTXYAxis.h"

#import "CPTAxisLabel.h"
#import "CPTConstraints.h"
#import "CPTDefinitions.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLimitBand.h"
#import "CPTLineCap.h"
#import "CPTLineStyle.h"
#import "CPTMutablePlotRange.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"

///	@cond
@interface CPTXYAxis()

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length inRange:(CPTPlotRange *)labeledRange isMajor:(BOOL)major;

-(void)orthogonalCoordinateViewLowerBound:(CGFloat *)lower upperBound:(CGFloat *)upper;
-(CGPoint)viewPointForOrthogonalCoordinateDecimal:(NSDecimal)orthogonalCoord axisCoordinateDecimal:(NSDecimal)coordinateDecimalNumber;

@end

///	@endcond

#pragma mark -

/**
 *	@brief A 2-dimensional cartesian (X-Y) axis class.
 **/
@implementation CPTXYAxis

/**	@property orthogonalCoordinateDecimal
 *	@brief The data coordinate value where the axis crosses the orthogonal axis.
 **/
@synthesize orthogonalCoordinateDecimal;

/**	@property axisConstraints
 *	@brief The constraints used when positioning relative to the plot area.
 *  If <code>nil</code> (the default), the axis is fixed relative to the plot space coordinates, and moves
 *  whenever the plot space ranges change.
 **/
@synthesize axisConstraints;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTXYAxis object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTXYAxis::orthogonalCoordinateDecimal orthogonalCoordinateDecimal @endlink = 0
 *	- @link CPTXYAxis::axisConstraints axisConstraints @endlink = <code>nil</code>
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTXYAxis object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
		axisConstraints				= nil;
		self.tickDirection			= CPTSignNone;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTXYAxis *theLayer = (CPTXYAxis *)layer;

		orthogonalCoordinateDecimal = theLayer->orthogonalCoordinateDecimal;
		axisConstraints				= [theLayer->axisConstraints retain];
	}
	return self;
}

-(void)dealloc
{
	[axisConstraints release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeDecimal:self.orthogonalCoordinateDecimal forKey:@"CPTXYAxis.orthogonalCoordinateDecimal"];
	[coder encodeObject:self.axisConstraints forKey:@"CPTXYAxis.axisConstraints"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		orthogonalCoordinateDecimal = [coder decodeDecimalForKey:@"CPTXYAxis.orthogonalCoordinateDecimal"];
		axisConstraints				= [[coder decodeObjectForKey:@"CPTXYAxis.axisConstraints"] retain];
	}
	return self;
}

#pragma mark -
#pragma mark Coordinate Transforms

///	@cond

-(void)orthogonalCoordinateViewLowerBound:(CGFloat *)lower upperBound:(CGFloat *)upper
{
	CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
	CPTXYPlotSpace *xyPlotSpace		   = (CPTXYPlotSpace *)self.plotSpace;
	CPTPlotRange *orthogonalRange	   = [xyPlotSpace plotRangeForCoordinate:orthogonalCoordinate];

	NSAssert(orthogonalRange != nil, @"The orthogonalRange was nil in orthogonalCoordinateViewLowerBound:upperBound:");

	NSDecimal zero			= CPTDecimalFromInteger(0);
	CGPoint lowerBoundPoint = [self viewPointForOrthogonalCoordinateDecimal:orthogonalRange.location axisCoordinateDecimal:zero];
	CGPoint upperBoundPoint = [self viewPointForOrthogonalCoordinateDecimal:orthogonalRange.end axisCoordinateDecimal:zero];

	switch ( self.coordinate ) {
		case CPTCoordinateX:
			*lower = lowerBoundPoint.y;
			*upper = upperBoundPoint.y;
			break;

		case CPTCoordinateY:
			*lower = lowerBoundPoint.x;
			*upper = upperBoundPoint.x;
			break;

		default:
			break;
	}
}

-(CGPoint)viewPointForOrthogonalCoordinateDecimal:(NSDecimal)orthogonalCoord axisCoordinateDecimal:(NSDecimal)coordinateDecimalNumber
{
	CPTCoordinate myCoordinate		   = self.coordinate;
	CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(myCoordinate);

	double plotPoint[2];

	plotPoint[myCoordinate]			= CPTDecimalDoubleValue(coordinateDecimalNumber);
	plotPoint[orthogonalCoordinate] = CPTDecimalDoubleValue(orthogonalCoord);

	return [self convertPoint:[self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:self.plotArea];
}

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber
{
	CGPoint point = [self viewPointForOrthogonalCoordinateDecimal:self.orthogonalCoordinateDecimal
											axisCoordinateDecimal:coordinateDecimalNumber];

	CPTConstraints *theAxisConstraints = self.axisConstraints;

	if ( theAxisConstraints ) {
		CGFloat lb, ub;
		[self orthogonalCoordinateViewLowerBound:&lb upperBound:&ub];
		CGFloat constrainedPosition = [theAxisConstraints positionForLowerBound:lb upperBound:ub];

		switch ( self.coordinate ) {
			case CPTCoordinateX:
				point.y = constrainedPosition;
				break;

			case CPTCoordinateY:
				point.x = constrainedPosition;
				break;

			default:
				break;
		}
	}

	return point;
}

///	@endcond

#pragma mark -
#pragma mark Drawing

///	@cond

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length inRange:(CPTPlotRange *)labeledRange isMajor:(BOOL)major;
{
	CPTLineStyle *lineStyle = (major ? self.majorTickLineStyle : self.minorTickLineStyle);

	if ( !lineStyle ) {
		return;
	}

	[lineStyle setLineStyleInContext:theContext];
	CGContextBeginPath(theContext);

	for ( NSDecimalNumber *tickLocation in locations ) {
		NSDecimal locationDecimal = tickLocation.decimalValue;

		if ( labeledRange && ![labeledRange contains:locationDecimal] ) {
			continue;
		}

		// Tick end points
		CGPoint baseViewPoint  = [self viewPointForCoordinateDecimalNumber:locationDecimal];
		CGPoint startViewPoint = baseViewPoint;
		CGPoint endViewPoint   = baseViewPoint;

		CGFloat startFactor = 0.0;
		CGFloat endFactor	= 0.0;
		switch ( self.tickDirection ) {
			case CPTSignPositive:
				endFactor = 1.0;
				break;

			case CPTSignNegative:
				endFactor = -1.0;
				break;

			case CPTSignNone:
				startFactor = -0.5;
				endFactor	= 0.5;
				break;

			default:
				NSLog(@"Invalid sign in [CPTXYAxis drawTicksInContext:]");
		}

		switch ( self.coordinate ) {
			case CPTCoordinateX:
				startViewPoint.y += length * startFactor;
				endViewPoint.y	 += length * endFactor;
				break;

			case CPTCoordinateY:
				startViewPoint.x += length * startFactor;
				endViewPoint.x	 += length * endFactor;
				break;

			default:
				NSLog(@"Invalid coordinate in [CPTXYAxis drawTicksInContext:]");
		}

		startViewPoint = CPTAlignPointToUserSpace(theContext, startViewPoint);
		endViewPoint   = CPTAlignPointToUserSpace(theContext, endViewPoint);

		// Add tick line
		CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
		CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
	}
	// Stroke tick line
	CGContextStrokePath(theContext);
}

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) {
		return;
	}

	[super renderAsVectorInContext:theContext];

	CPTMutablePlotRange *range	  = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
	CPTPlotRange *theVisibleRange = self.visibleRange;
	if ( theVisibleRange ) {
		[range intersectionPlotRange:theVisibleRange];
	}

	CPTMutablePlotRange *labeledRange = nil;

	switch ( self.labelingPolicy ) {
		case CPTAxisLabelingPolicyNone:
		case CPTAxisLabelingPolicyLocationsProvided:
			labeledRange = range;
			break;

		default:
			break;
	}

	// Ticks
	[self drawTicksInContext:theContext atLocations:self.minorTickLocations withLength:self.minorTickLength inRange:labeledRange isMajor:NO];
	[self drawTicksInContext:theContext atLocations:self.majorTickLocations withLength:self.majorTickLength inRange:labeledRange isMajor:YES];

	// Axis Line
	CPTLineStyle *theLineStyle = self.axisLineStyle;
	CPTLineCap *minCap		   = self.axisLineCapMin;
	CPTLineCap *maxCap		   = self.axisLineCapMax;

	if ( theLineStyle || minCap || maxCap ) {
		if ( theLineStyle ) {
			CGPoint startViewPoint = CPTAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:range.location]);
			CGPoint endViewPoint   = CPTAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:range.end]);
			[theLineStyle setLineStyleInContext:theContext];
			CGContextBeginPath(theContext);
			CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
			CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
			CGContextStrokePath(theContext);
		}

		CGPoint axisDirection = CGPointZero;
		if ( minCap || maxCap ) {
			switch ( self.coordinate ) {
				case CPTCoordinateX:
					axisDirection = (range.lengthDouble >= 0.0) ? CGPointMake(1.0, 0.0) : CGPointMake(-1.0, 0.0);
					break;

				case CPTCoordinateY:
					axisDirection = (range.lengthDouble >= 0.0) ? CGPointMake(0.0, 1.0) : CGPointMake(0.0, -1.0);
					break;

				default:
					break;
			}
		}

		if ( minCap ) {
			NSDecimal endPoint = range.minLimit;
			CGPoint viewPoint  = CPTAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:endPoint]);
			[minCap renderAsVectorInContext:theContext atPoint:viewPoint inDirection:CGPointMake(-axisDirection.x, -axisDirection.y)];
		}

		if ( maxCap ) {
			NSDecimal endPoint = range.maxLimit;
			CGPoint viewPoint  = CPTAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:endPoint]);
			[maxCap renderAsVectorInContext:theContext atPoint:viewPoint inDirection:axisDirection];
		}
	}

	[range release];
}

///	@endcond

#pragma mark -
#pragma mark Grid Lines

///	@cond

-(void)drawGridLinesInContext:(CGContextRef)context isMajor:(BOOL)major
{
	CPTLineStyle *lineStyle = (major ? self.majorGridLineStyle : self.minorGridLineStyle);

	if ( lineStyle ) {
		[super renderAsVectorInContext:context];

		[self relabel];

		CPTPlotSpace *thePlotSpace			 = self.plotSpace;
		NSSet *locations					 = (major ? self.majorTickLocations : self.minorTickLocations);
		CPTCoordinate selfCoordinate		 = self.coordinate;
		CPTCoordinate orthogonalCoordinate	 = CPTOrthogonalCoordinate(selfCoordinate);
		CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
		CPTPlotRange *theGridLineRange		 = self.gridLinesRange;
		CPTMutablePlotRange *labeledRange	 = nil;

		switch ( self.labelingPolicy ) {
			case CPTAxisLabelingPolicyNone:
			case CPTAxisLabelingPolicyLocationsProvided:
			{
				labeledRange = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
				CPTPlotRange *theVisibleRange = self.visibleRange;
				if ( theVisibleRange ) {
					[labeledRange intersectionPlotRange:theVisibleRange];
				}
			}
			break;

			default:
				break;
		}

		if ( theGridLineRange ) {
			[orthogonalRange intersectionPlotRange:theGridLineRange];
		}

		CPTPlotArea *thePlotArea = self.plotArea;
		NSDecimal startPlotPoint[2];
		NSDecimal endPlotPoint[2];
		startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
		endPlotPoint[orthogonalCoordinate]	 = orthogonalRange.end;
		CGPoint originTransformed = [self convertPoint:self.frame.origin fromLayer:thePlotArea];

		CGContextBeginPath(context);

		for ( NSDecimalNumber *location in locations ) {
			NSDecimal locationDecimal = location.decimalValue;

			if ( labeledRange && ![labeledRange contains:locationDecimal] ) {
				continue;
			}

			startPlotPoint[selfCoordinate] = endPlotPoint[selfCoordinate] = locationDecimal;

			// Start point
			CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint];
			startViewPoint.x += originTransformed.x;
			startViewPoint.y += originTransformed.y;

			// End point
			CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint];
			endViewPoint.x += originTransformed.x;
			endViewPoint.y += originTransformed.y;

			// Align to pixels
			startViewPoint = CPTAlignPointToUserSpace(context, startViewPoint);
			endViewPoint   = CPTAlignPointToUserSpace(context, endViewPoint);

			// Add grid line
			CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
			CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
		}

		// Stroke grid lines
		[lineStyle setLineStyleInContext:context];
		CGContextStrokePath(context);

		[orthogonalRange release];
		[labeledRange release];
	}
}

///	@endcond

#pragma mark -
#pragma mark Background Bands

///	@cond

-(void)drawBackgroundBandsInContext:(CGContextRef)context
{
	NSArray *bandArray	 = self.alternatingBandFills;
	NSUInteger bandCount = bandArray.count;

	if ( bandCount > 0 ) {
		NSArray *locations = [self.majorTickLocations allObjects];

		if ( locations.count > 0 ) {
			CPTPlotSpace *thePlotSpace = self.plotSpace;

			CPTCoordinate selfCoordinate = self.coordinate;
			CPTMutablePlotRange *range	 = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] mutableCopy];
			if ( range ) {
				CPTPlotRange *theVisibleRange = self.visibleRange;
				if ( theVisibleRange ) {
					[range intersectionPlotRange:theVisibleRange];
				}
			}

			CPTCoordinate orthogonalCoordinate	 = CPTOrthogonalCoordinate(selfCoordinate);
			CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
			CPTPlotRange *theGridLineRange		 = self.gridLinesRange;

			if ( theGridLineRange ) {
				[orthogonalRange intersectionPlotRange:theGridLineRange];
			}

			NSDecimal zero					 = CPTDecimalFromInteger(0);
			NSSortDescriptor *sortDescriptor = nil;
			if ( range ) {
				if ( CPTDecimalGreaterThanOrEqualTo(range.length, zero) ) {
					sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
				}
				else {
					sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:NO];
				}
			}
			else {
				sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
			}
			locations = [locations sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
			[sortDescriptor release];

			NSUInteger bandIndex = 0;
			id null				 = [NSNull null];
			NSDecimal lastLocation;
			if ( range ) {
				lastLocation = range.location;
			}
			else {
				lastLocation = CPTDecimalNaN();
			}

			NSDecimal startPlotPoint[2];
			NSDecimal endPlotPoint[2];
			if ( orthogonalRange ) {
				startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
				endPlotPoint[orthogonalCoordinate]	 = orthogonalRange.end;
			}
			else {
				startPlotPoint[orthogonalCoordinate] = CPTDecimalNaN();
				endPlotPoint[orthogonalCoordinate]	 = CPTDecimalNaN();
			}

			for ( NSDecimalNumber *location in locations ) {
				NSDecimal currentLocation = [location decimalValue];
				if ( !CPTDecimalEquals(CPTDecimalSubtract(currentLocation, lastLocation), zero) ) {
					CPTFill *bandFill = [bandArray objectAtIndex:bandIndex++];
					bandIndex %= bandCount;

					if ( bandFill != null ) {
						// Start point
						startPlotPoint[selfCoordinate] = currentLocation;
						CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint];

						// End point
						endPlotPoint[selfCoordinate] = lastLocation;
						CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint];

						// Fill band
						CGRect fillRect = CGRectMake( MIN(startViewPoint.x, endViewPoint.x),
													  MIN(startViewPoint.y, endViewPoint.y),
													  ABS(endViewPoint.x - startViewPoint.x),
													  ABS(endViewPoint.y - startViewPoint.y) );
						[bandFill fillRect:CPTAlignRectToUserSpace(context, fillRect) inContext:context];
					}
				}

				lastLocation = currentLocation;
			}

			// Fill space between last location and the range end
			NSDecimal endLocation;
			if ( range ) {
				endLocation = range.end;
			}
			else {
				endLocation = CPTDecimalNaN();
			}
			if ( !CPTDecimalEquals(lastLocation, endLocation) ) {
				CPTFill *bandFill = [bandArray objectAtIndex:bandIndex];

				if ( bandFill != null ) {
					// Start point
					startPlotPoint[selfCoordinate] = endLocation;
					CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint];

					// End point
					endPlotPoint[selfCoordinate] = lastLocation;
					CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint];

					// Fill band
					CGRect fillRect = CGRectMake( MIN(startViewPoint.x, endViewPoint.x),
												  MIN(startViewPoint.y, endViewPoint.y),
												  ABS(endViewPoint.x - startViewPoint.x),
												  ABS(endViewPoint.y - startViewPoint.y) );
					[bandFill fillRect:CPTAlignRectToUserSpace(context, fillRect) inContext:context];
				}
			}

			[range release];
			[orthogonalRange release];
		}
	}
}

-(void)drawBackgroundLimitsInContext:(CGContextRef)context
{
	NSArray *limitArray = self.backgroundLimitBands;

	if ( limitArray.count > 0 ) {
		CPTPlotSpace *thePlotSpace = self.plotSpace;

		CPTCoordinate selfCoordinate = self.coordinate;
		CPTMutablePlotRange *range	 = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] mutableCopy];

		if ( range ) {
			CPTPlotRange *theVisibleRange = self.visibleRange;
			if ( theVisibleRange ) {
				[range intersectionPlotRange:theVisibleRange];
			}
		}

		CPTCoordinate orthogonalCoordinate	 = CPTOrthogonalCoordinate(selfCoordinate);
		CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
		CPTPlotRange *theGridLineRange		 = self.gridLinesRange;

		if ( theGridLineRange ) {
			[orthogonalRange intersectionPlotRange:theGridLineRange];
		}

		NSDecimal startPlotPoint[2];
		NSDecimal endPlotPoint[2];
		startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
		endPlotPoint[orthogonalCoordinate]	 = orthogonalRange.end;

		for ( CPTLimitBand *band in self.backgroundLimitBands ) {
			CPTFill *bandFill = band.fill;

			if ( bandFill ) {
				CPTMutablePlotRange *bandRange = [band.range mutableCopy];
				if ( bandRange ) {
					[bandRange intersectionPlotRange:range];

					// Start point
					startPlotPoint[selfCoordinate] = bandRange.location;
					CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint];

					// End point
					endPlotPoint[selfCoordinate] = bandRange.end;
					CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint];

					// Fill band
					CGRect fillRect = CGRectMake( MIN(startViewPoint.x, endViewPoint.x),
												  MIN(startViewPoint.y, endViewPoint.y),
												  ABS(endViewPoint.x - startViewPoint.x),
												  ABS(endViewPoint.y - startViewPoint.y) );
					[bandFill fillRect:CPTAlignRectToUserSpace(context, fillRect) inContext:context];

					[bandRange release];
				}
			}
		}

		[range release];
		[orthogonalRange release];
	}
}

///	@endcond

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	CPTPlotRange *range	   = [self.plotSpace plotRangeForCoordinate:self.coordinate];
	CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
	CGPoint endViewPoint   = [self viewPointForCoordinateDecimalNumber:range.end];

	return [NSString stringWithFormat:@"<%@ with range: %@ viewCoordinates: %@ to %@>",
			[super description],
			range,
			CPTStringFromPoint(startViewPoint),
			CPTStringFromPoint(endViewPoint)];
}

#pragma mark -
#pragma mark Titles

///	@cond

// Center title in the plot range by default
-(NSDecimal)defaultTitleLocation
{
	CPTPlotSpace *thePlotSpace	= self.plotSpace;
	CPTCoordinate theCoordinate = self.coordinate;

	CPTPlotRange *axisRange = [thePlotSpace plotRangeForCoordinate:theCoordinate];

	if ( axisRange ) {
		CPTScaleType scaleType = [thePlotSpace scaleTypeForCoordinate:theCoordinate];

		switch ( scaleType ) {
			case CPTScaleTypeLinear:
				return axisRange.midPoint;

				break;

			case CPTScaleTypeLog:
			{
				double loc = axisRange.locationDouble;
				double end = axisRange.endDouble;

				if ( (loc > 0.0) && (end >= 0.0) ) {
					return CPTDecimalFromDouble( pow(10.0, ( log10(loc) + log10(end) ) / 2.0) );
				}
				else {
					return axisRange.midPoint;
				}
			}
			break;

			default:
				return axisRange.midPoint;

				break;
		}
	}
	else {
		return CPTDecimalFromInteger(0);
	}
}

///	@endcond

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setAxisConstraints:(CPTConstraints *)newConstraints
{
	if ( ![axisConstraints isEqualToConstraint:newConstraints] ) {
		[axisConstraints release];
		axisConstraints = [newConstraints retain];
		[self setNeedsDisplay];
		[self setNeedsLayout];
	}
}

-(void)setOrthogonalCoordinateDecimal:(NSDecimal)newCoord
{
	if ( NSDecimalCompare(&orthogonalCoordinateDecimal, &newCoord) != NSOrderedSame ) {
		orthogonalCoordinateDecimal = newCoord;
		[self setNeedsDisplay];
		[self setNeedsLayout];
	}
}

-(void)setCoordinate:(CPTCoordinate)newCoordinate
{
	if ( self.coordinate != newCoordinate ) {
		[super setCoordinate:newCoordinate];
		switch ( newCoordinate ) {
			case CPTCoordinateX:
				switch ( self.labelAlignment ) {
					case CPTAlignmentLeft:
					case CPTAlignmentCenter:
					case CPTAlignmentRight:
						// ok--do nothing
						break;

					default:
						self.labelAlignment = CPTAlignmentCenter;
						break;
				}
				break;

			case CPTCoordinateY:
				switch ( self.labelAlignment ) {
					case CPTAlignmentTop:
					case CPTAlignmentMiddle:
					case CPTAlignmentBottom:
						// ok--do nothing
						break;

					default:
						self.labelAlignment = CPTAlignmentMiddle;
						break;
				}
				break;

			default:
				[NSException raise:NSInvalidArgumentException format:@"Invalid coordinate: %lu", newCoordinate];
				break;
		}
	}
}

///	@endcond

@end
