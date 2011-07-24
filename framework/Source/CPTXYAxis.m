#import "CPTAxisLabel.h"
#import "CPTConstrainedPosition.h"
#import "CPTDefinitions.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLimitBand.h"
#import "CPTLineStyle.h"
#import "CPTPlotArea.h"
#import "CPTPlotRange.h"
#import "CPTPlotSpace.h"
#import "CPTUtilities.h"
#import "CPTXYAxis.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"

/**	@cond */
@interface CPTXYAxis ()

@property (readwrite, retain) CPTConstrainedPosition *constrainedPosition;

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major; 

-(void)orthogonalCoordinateViewLowerBound:(CGFloat *)lower upperBound:(CGFloat *)upper;
-(CGPoint)viewPointForOrthogonalCoordinateDecimal:(NSDecimal)orthogonalCoord axisCoordinateDecimal:(NSDecimal)coordinateDecimalNumber;
-(void)updateConstraints;

@end
/**	@endcond */

#pragma mark -

/**	@brief A 2-dimensional cartesian (X-Y) axis class.
 **/
@implementation CPTXYAxis

/**	@property orthogonalCoordinateDecimal
 *	@brief The data coordinate value where the axis crosses the orthogonal axis.
 **/
@synthesize orthogonalCoordinateDecimal;

/**	@property constraints
 *	@brief The constraints used when positioning relative to the plot area.
 *  For axes fixed in the plot coordinate system, this is ignored.
 **/
@synthesize constraints;

/**	@property isFloatingAxis
 *	@brief True if the axis floats independent of the plot space.
 *  If false, the axis is fixed relative to the plot space coordinates, and moves
 *  whenever the plot space ranges change.
 *  When true, the axis must be constrained relative to the plot area, in view coordinates.
 *  The default value is NO, meaning the axis is positioned in plot coordinates.
 **/
@synthesize isFloatingAxis;

@synthesize constrainedPosition;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
    	CPTConstraints newConstraints = {CPTConstraintNone, CPTConstraintNone};
        orthogonalCoordinateDecimal = [[NSDecimalNumber zero] decimalValue];
        isFloatingAxis = NO;
        self.constraints = newConstraints;
		self.tickDirection = CPTSignNone;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTXYAxis *theLayer = (CPTXYAxis *)layer;
		
		isFloatingAxis = theLayer->isFloatingAxis;
		orthogonalCoordinateDecimal = theLayer->orthogonalCoordinateDecimal;
		constraints = theLayer->constraints;
		constrainedPosition = [theLayer->constrainedPosition retain];
	}
	return self;
}

-(void)dealloc 
{
    [constrainedPosition release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];
	
	[coder encodeBool:self.isFloatingAxis forKey:@"CPTXYAxis.isFloatingAxis"];
	[coder encodeDecimal:self.orthogonalCoordinateDecimal forKey:@"CPTXYAxis.orthogonalCoordinateDecimal"];
	[coder encodeInteger:self.constraints.lower forKey:@"CPTXYAxis.constraints.lower"];
	[coder encodeInteger:self.constraints.upper forKey:@"CPTXYAxis.constraints.upper"];
	[coder encodeObject:self.constrainedPosition forKey:@"CPTXYAxis.constrainedPosition"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
		isFloatingAxis = [coder decodeBoolForKey:@"CPTXYAxis.isFloatingAxis"];
		orthogonalCoordinateDecimal = [coder decodeDecimalForKey:@"CPTXYAxis.orthogonalCoordinateDecimal"];
		constraints.lower = [coder decodeIntegerForKey:@"CPTXYAxis.constraints.lower"];
		constraints.upper = [coder decodeIntegerForKey:@"CPTXYAxis.constraints.upper"];
		constrainedPosition = [[coder decodeObjectForKey:@"CPTXYAxis.constrainedPosition"] retain];
	}
    return self;
}

#pragma mark -
#pragma mark Coordinate Transforms

-(void)orthogonalCoordinateViewLowerBound:(CGFloat *)lower upperBound:(CGFloat *)upper 
{
	NSDecimal zero = CPTDecimalFromInteger(0);
    CPTCoordinate orthogonalCoordinate = (self.coordinate == CPTCoordinateX ? CPTCoordinateY : CPTCoordinateX);
    CPTXYPlotSpace *xyPlotSpace = (CPTXYPlotSpace *)self.plotSpace;
    CPTPlotRange *orthogonalRange = [xyPlotSpace plotRangeForCoordinate:orthogonalCoordinate];
    NSAssert( orthogonalRange != nil, @"The orthogonalRange was nil in orthogonalCoordinateViewLowerBound:upperBound:" );
    CGPoint lowerBoundPoint = [self viewPointForOrthogonalCoordinateDecimal:orthogonalRange.location axisCoordinateDecimal:zero];
    CGPoint upperBoundPoint = [self viewPointForOrthogonalCoordinateDecimal:orthogonalRange.end axisCoordinateDecimal:zero];
    *lower = (self.coordinate == CPTCoordinateX ? lowerBoundPoint.y : lowerBoundPoint.x);
    *upper = (self.coordinate == CPTCoordinateX ? upperBoundPoint.y : upperBoundPoint.x);
}

-(CGPoint)viewPointForOrthogonalCoordinateDecimal:(NSDecimal)orthogonalCoord axisCoordinateDecimal:(NSDecimal)coordinateDecimalNumber
{
    CPTCoordinate orthogonalCoordinate = (self.coordinate == CPTCoordinateX ? CPTCoordinateY : CPTCoordinateX);
    NSDecimal plotPoint[2];
    plotPoint[self.coordinate] = coordinateDecimalNumber;
    plotPoint[orthogonalCoordinate] = orthogonalCoord;
    CGPoint point = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
    return point;
}

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber
{    
    CGPoint point = [self viewPointForOrthogonalCoordinateDecimal:self.orthogonalCoordinateDecimal axisCoordinateDecimal:coordinateDecimalNumber];
    
    if ( self.isFloatingAxis ) {
        if ( self.constrainedPosition ) {
        	CGFloat lb, ub;
            [self orthogonalCoordinateViewLowerBound:&lb upperBound:&ub];
        	constrainedPosition.lowerBound = lb;
            constrainedPosition.upperBound = ub;
            CGFloat position = constrainedPosition.position;
            if ( self.coordinate == CPTCoordinateX ) {
                point.y = position;
            }
            else {
                point.x = position;
            }
        }
        else {
			[NSException raise:CPTException format:@"Plot area relative positioning requires a CPTConstrainedPosition"];
        }
    }
    
    return point;
}

#pragma mark -
#pragma mark Drawing

-(void)drawTicksInContext:(CGContextRef)theContext atLocations:(NSSet *)locations withLength:(CGFloat)length isMajor:(BOOL)major
{
	CPTLineStyle *lineStyle = (major ? self.majorTickLineStyle : self.minorTickLineStyle);
    if ( !lineStyle ) return;
    
	[lineStyle setLineStyleInContext:theContext];
	CGContextBeginPath(theContext);
    
    for ( NSDecimalNumber *tickLocation in locations ) {
        // Tick end points
        CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:[tickLocation decimalValue]];
		CGPoint startViewPoint = baseViewPoint;
        CGPoint endViewPoint = baseViewPoint;
		
		CGFloat startFactor = 0.0;
		CGFloat endFactor = 0.0;
		switch ( self.tickDirection ) {
			case CPTSignPositive:
				endFactor = 1.0;
				break;
			case CPTSignNegative:
				endFactor = -1.0;
				break;
			case CPTSignNone:
				startFactor = -0.5;
				endFactor = 0.5;
				break;
			default:
				NSLog(@"Invalid sign in [CPTXYAxis drawTicksInContext:]");
		}
		
        switch ( self.coordinate ) {
			case CPTCoordinateX:
				startViewPoint.y += length * startFactor;
				endViewPoint.y += length * endFactor;
				break;
			case CPTCoordinateY:
				startViewPoint.x += length * startFactor;
				endViewPoint.x += length * endFactor;
				break;
			default:
				NSLog(@"Invalid coordinate in [CPTXYAxis drawTicksInContext:]");
		}
        
		startViewPoint = CPTAlignPointToUserSpace(theContext, startViewPoint);
		endViewPoint = CPTAlignPointToUserSpace(theContext, endViewPoint);
		
        // Add tick line
        CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
        CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
    }    
	// Stroke tick line
	CGContextStrokePath(theContext);
}

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) return;
	
	[super renderAsVectorInContext:theContext];
	
	[self relabel];
	
    // Ticks
    [self drawTicksInContext:theContext atLocations:self.minorTickLocations withLength:self.minorTickLength isMajor:NO];
    [self drawTicksInContext:theContext atLocations:self.majorTickLocations withLength:self.majorTickLength isMajor:YES];
    
    // Axis Line
	if ( self.axisLineStyle ) {
		CPTPlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] copy];
        if ( self.visibleRange ) {
            [range intersectionPlotRange:self.visibleRange];
        }
		CGPoint startViewPoint = CPTAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:range.location]);
		CGPoint endViewPoint = CPTAlignPointToUserSpace(theContext, [self viewPointForCoordinateDecimalNumber:range.end]);
		[self.axisLineStyle setLineStyleInContext:theContext];
		CGContextBeginPath(theContext);
		CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
		CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
		CGContextStrokePath(theContext);
        [range release];
	}
}

#pragma mark -
#pragma mark Grid Lines

-(void)drawGridLinesInContext:(CGContextRef)context isMajor:(BOOL)major
{
	CPTLineStyle *lineStyle = (major ? self.majorGridLineStyle : self.minorGridLineStyle);
	
	if ( lineStyle ) {
		[super renderAsVectorInContext:context];
		
		[self relabel];
		
		CPTPlotSpace *thePlotSpace = self.plotSpace;
		NSSet *locations = (major ? self.majorTickLocations : self.minorTickLocations);
		CPTCoordinate selfCoordinate = self.coordinate;
		CPTCoordinate orthogonalCoordinate = (selfCoordinate == CPTCoordinateX ? CPTCoordinateY : CPTCoordinateX);
		CPTPlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] copy];
		CPTPlotRange *theGridLineRange = self.gridLinesRange;
		if ( theGridLineRange ) {
			[orthogonalRange intersectionPlotRange:theGridLineRange];
		}
		
		CPTPlotArea *thePlotArea = self.plotArea;
		NSDecimal startPlotPoint[2];
		NSDecimal endPlotPoint[2];
		startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
		endPlotPoint[orthogonalCoordinate] = orthogonalRange.end;
		
		CGContextBeginPath(context);
		
		for ( NSDecimalNumber *location in locations ) {
			startPlotPoint[selfCoordinate] = endPlotPoint[selfCoordinate] = [location decimalValue];
            
			// Start point
			CGPoint startViewPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint] fromLayer:thePlotArea];
			
			// End point
			CGPoint endViewPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint] fromLayer:thePlotArea];
			
			// Align to pixels
			startViewPoint = CPTAlignPointToUserSpace(context, startViewPoint);
			endViewPoint = CPTAlignPointToUserSpace(context, endViewPoint);
			
			// Add grid line 
			CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
			CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
		}
		
		// Stroke grid lines
		[lineStyle setLineStyleInContext:context];
		CGContextStrokePath(context);
		
		[orthogonalRange release];
	}
}

#pragma mark -
#pragma mark Background Bands

-(void)drawBackgroundBandsInContext:(CGContextRef)context
{
	NSArray *bandArray = self.alternatingBandFills;
	NSUInteger bandCount = bandArray.count;
	
	if ( bandCount > 0 ) {
		NSArray *locations = [self.majorTickLocations allObjects];
		
		if ( locations.count > 0 ) {
			CPTPlotSpace *thePlotSpace = self.plotSpace;
			
			CPTCoordinate selfCoordinate = self.coordinate;
			CPTPlotRange *range = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] copy];
			if ( range ) {
				CPTPlotRange *theVisibleRange = self.visibleRange;
				if ( theVisibleRange ) {
					[range intersectionPlotRange:theVisibleRange];
				}
			}
			
			CPTCoordinate orthogonalCoordinate = (selfCoordinate == CPTCoordinateX ? CPTCoordinateY : CPTCoordinateX);
			CPTPlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] copy];
			CPTPlotRange *theGridLineRange = self.gridLinesRange;
			if ( theGridLineRange ) {
				[orthogonalRange intersectionPlotRange:theGridLineRange];
			}
			
			NSDecimal zero = CPTDecimalFromInteger(0);
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
			id null = [NSNull null];
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
				endPlotPoint[orthogonalCoordinate] = orthogonalRange.end;
			}
			else {
				startPlotPoint[orthogonalCoordinate] = CPTDecimalNaN();
				endPlotPoint[orthogonalCoordinate] = CPTDecimalNaN();
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
						CGRect fillRect = CGRectMake(MIN(startViewPoint.x, endViewPoint.x),
													 MIN(startViewPoint.y, endViewPoint.y),
													 ABS(endViewPoint.x - startViewPoint.x),
													 ABS(endViewPoint.y - startViewPoint.y));
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
					CGRect fillRect = CGRectMake(MIN(startViewPoint.x, endViewPoint.x),
												 MIN(startViewPoint.y, endViewPoint.y),
												 ABS(endViewPoint.x - startViewPoint.x),
												 ABS(endViewPoint.y - startViewPoint.y));
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
		CPTPlotRange *range = [[thePlotSpace plotRangeForCoordinate:selfCoordinate] copy];
		if ( range ) {
			CPTPlotRange *theVisibleRange = self.visibleRange;
			if ( theVisibleRange ) {
				[range intersectionPlotRange:theVisibleRange];
			}
		}
		
		CPTCoordinate orthogonalCoordinate = (selfCoordinate == CPTCoordinateX ? CPTCoordinateY : CPTCoordinateX);
		CPTPlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] copy];
		CPTPlotRange *theGridLineRange = self.gridLinesRange;
		if ( theGridLineRange ) {
			[orthogonalRange intersectionPlotRange:theGridLineRange];
		}
		
		NSDecimal startPlotPoint[2];
		NSDecimal endPlotPoint[2];
		startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
		endPlotPoint[orthogonalCoordinate] = orthogonalRange.end;
		
		for ( CPTLimitBand *band in self.backgroundLimitBands ) {
			CPTFill *bandFill = band.fill;
			
			if ( bandFill ) {
				CPTPlotRange *bandRange = [band.range copy];
				if ( bandRange ) {
					[bandRange intersectionPlotRange:range];
					
					// Start point
					startPlotPoint[selfCoordinate] = bandRange.location;
					CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint];
					
					// End point
					endPlotPoint[selfCoordinate] = bandRange.end;
					CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint];
					
					// Fill band
					CGRect fillRect = CGRectMake(MIN(startViewPoint.x, endViewPoint.x),
												 MIN(startViewPoint.y, endViewPoint.y),
												 ABS(endViewPoint.x - startViewPoint.x),
												 ABS(endViewPoint.y - startViewPoint.y));
					[bandFill fillRect:CPTAlignRectToUserSpace(context, fillRect) inContext:context];
					
					[bandRange release];
				}
			}
		}
		
		[range release];
		[orthogonalRange release];
	}
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
    CPTPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
	CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:range.end];
	
	return [NSString stringWithFormat:@"<%@ with range: %@ viewCoordinates: %@ to %@>",
			[super description],
			range,
			CPTStringFromPoint(startViewPoint),
			CPTStringFromPoint(endViewPoint)];
};

#pragma mark -
#pragma mark Titles

// Center title in the plot range by default
-(NSDecimal)defaultTitleLocation
{
	CPTPlotSpace *thePlotSpace = self.plotSpace;
	CPTCoordinate theCoordinate = self.coordinate;
	
	CPTPlotRange *axisRange = [thePlotSpace plotRangeForCoordinate:theCoordinate];
	if ( axisRange ) {
		CPTScaleType scaleType = [thePlotSpace scaleTypeForCoordinate:theCoordinate];
		
		switch ( scaleType ) {
			case CPTScaleTypeLinear:
				return axisRange.midPoint;
				break;
				
			case CPTScaleTypeLog: {
				double loc = axisRange.locationDouble;
				double end = axisRange.endDouble;
				
				if ( (loc > 0.0) && (end >= 0.0) ) {
					return CPTDecimalFromDouble(pow(10.0, (log10(loc) + log10(end)) / 2.0));
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

#pragma mark -
#pragma mark Constraints

-(void)updateConstraints
{
    if ( self.plotSpace ) {
        CGPoint axisPoint = [self viewPointForOrthogonalCoordinateDecimal:self.orthogonalCoordinateDecimal axisCoordinateDecimal:CPTDecimalFromInteger(0)];
        CGFloat position = (self.coordinate == CPTCoordinateX ? axisPoint.y : axisPoint.x);
        
        CGFloat lb, ub;
        [self orthogonalCoordinateViewLowerBound:&lb upperBound:&ub];
        
		CPTConstrainedPosition *cp = [[CPTConstrainedPosition alloc] initWithPosition:position lowerBound:lb upperBound:ub];
		cp.constraints = self.constraints;
        self.constrainedPosition = cp;
        [cp release];         
    }
    else {
        self.constrainedPosition = nil;
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setConstraints:(CPTConstraints)newConstraints
{
    if ( (constraints.lower != newConstraints.lower) || (constraints.upper != newConstraints.upper) ) {
        constraints = newConstraints;
        [self updateConstraints];
    }
}

-(void)setOrthogonalCoordinateDecimal:(NSDecimal)newCoord 
{
    if ( NSDecimalCompare(&orthogonalCoordinateDecimal, &newCoord) != NSOrderedSame ) {
        orthogonalCoordinateDecimal = newCoord;
        [self updateConstraints];
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

@end
