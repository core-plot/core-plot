
#import "CPAxis.h"
#import "CPPlotSpace.h"
#import "CPUtilities.h"
#import "CPPlotRange.h"
#import "CPLineStyle.h"
#import "CPTextLayer.h"
#import "CPAxisLabel.h"
#import "CPPlatformSpecificCategories.h"

@interface CPAxis ()

@property (nonatomic, readwrite, assign) BOOL needsRelabel;

-(void)tickLocationsBeginningAt:(NSDecimalNumber *)beginNumber increasing:(BOOL)increasing majorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(NSDecimalNumber *)nextLocationFromCoordinateValue:(NSDecimalNumber *)coord increasing:(BOOL)increasing interval:(NSDecimalNumber *)interval;

@end

@implementation CPAxis

@synthesize majorTickLocations;
@synthesize minorTickLocations;
@synthesize minorTickLength;
@synthesize majorTickLength;
@synthesize axisLabelOffset;
@synthesize axisLineStyle;
@synthesize majorTickLineStyle;
@synthesize minorTickLineStyle;
@synthesize plotSpace;
@synthesize coordinate;
@synthesize fixedPoint;
@synthesize majorIntervalLength;
@synthesize minorTicksPerInterval;
@synthesize axisLabelingPolicy;
@synthesize tickLabelFormatter;
@synthesize axisLabels;
@synthesize tickDirection;
@synthesize needsRelabel;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.plotSpace = nil;
		self.majorTickLocations = [NSArray array];
		self.minorTickLocations = [NSArray array];
		self.minorTickLength = 3.f;
		self.majorTickLength = 5.f;
		self.axisLabelOffset = 2.f;
		self.majorTickLineStyle = [CPLineStyle lineStyle];
		self.minorTickLineStyle = [CPLineStyle lineStyle];
		self.fixedPoint = [NSDecimalNumber zero];
		self.majorIntervalLength = [NSDecimalNumber one];
		self.minorTicksPerInterval = 1;
		self.coordinate = CPCoordinateX;
		self.axisLabelingPolicy = CPAxisLabelingPolicyFixedInterval;
		NSNumberFormatter *newFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		newFormatter.maximumFractionDigits = 1; 
        newFormatter.minimumFractionDigits = 1;
        self.tickLabelFormatter = newFormatter;
		self.axisLabels = [NSSet set];
        self.tickDirection = CPDirectionDown;
        self.needsRelabel = YES;
	}
	return self;
}


-(void)dealloc {
    self.deallocating = YES;
	self.plotSpace = nil;
	self.majorTickLocations = nil;
	self.minorTickLocations = nil;
	self.axisLineStyle = nil;
	self.majorTickLineStyle = nil;
	self.minorTickLineStyle = nil;
	self.fixedPoint = nil;
	self.majorIntervalLength = nil;
	self.tickLabelFormatter = nil;
	self.axisLabels = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Ticks

-(NSDecimalNumber *)nextLocationFromCoordinateValue:(NSDecimalNumber *)coord increasing:(BOOL)increasing interval:(NSDecimalNumber *)interval
{
	if ( increasing ) {
		return [coord decimalNumberByAdding:interval];
	} else {
		return [coord decimalNumberBySubtracting:interval];
	}
}

-(void)tickLocationsBeginningAt:(NSDecimalNumber *)beginNumber increasing:(BOOL)increasing majorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations
{
	NSMutableSet *majorLocations = [NSMutableSet set];
	NSMutableSet *minorLocations = [NSMutableSet set];
	NSDecimalNumber *majorInterval = self.majorIntervalLength;
	NSDecimalNumber *coord = beginNumber;
	CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
	
	while ( (increasing && [coord isLessThanOrEqualTo:range.end]) || (!increasing && [coord isGreaterThanOrEqualTo:range.location]) ) {
		
		// Major tick
		if ( [coord isLessThanOrEqualTo:range.end] && [coord isGreaterThanOrEqualTo:range.location] ) {
			[majorLocations addObject:coord];
		}
		
		// Minor ticks
		if ( self.minorTicksPerInterval > 0 ) {
			NSDecimalNumber *minorInterval = [majorInterval decimalNumberByDividingBy:(id)[NSDecimalNumber numberWithInt:self.minorTicksPerInterval+1]];
			NSDecimalNumber *minorCoord;
			minorCoord = [self nextLocationFromCoordinateValue:coord increasing:increasing interval:minorInterval];
			for ( NSUInteger minorTickIndex = 0; minorTickIndex < self.minorTicksPerInterval; minorTickIndex++) {
				if ( [minorCoord isLessThanOrEqualTo:range.end] && [minorCoord isGreaterThanOrEqualTo:range.location] ) {
					[minorLocations addObject:minorCoord];
				}
				minorCoord = [self nextLocationFromCoordinateValue:minorCoord increasing:increasing interval:minorInterval];
			}
		}
		
		coord = [self nextLocationFromCoordinateValue:coord increasing:increasing interval:majorInterval];
	}
	*newMajorLocations = majorLocations;
	*newMinorLocations = minorLocations;
}


#pragma mark -
#pragma mark Labels

-(NSArray *)newAxisLabelsAtLocations:(NSArray *)locations
{
    NSMutableArray *newLabels = [[NSMutableArray alloc] initWithCapacity:locations.count];
	for ( NSDecimalNumber *tickLocation in locations ) {
        NSString *labelString = [self.tickLabelFormatter stringForObjectValue:tickLocation];
        CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText:labelString];
        newLabel.tickLocation = tickLocation;
        newLabel.offset = self.axisLabelOffset + self.majorTickLength;
        [newLabels addObject:newLabel];
        [newLabel release];
	}
	return newLabels;
}

-(void)setNeedsRelabel
{
    self.needsRelabel = YES;
}

-(void)relabel
{
    if (!self.needsRelabel) return;
	if (!self.plotSpace) return;
	
	NSMutableSet *allNewMajorLocations = [NSMutableSet set];
	NSMutableSet *allNewMinorLocations = [NSMutableSet set];
	NSSet *newMajorLocations, *newMinorLocations;
	
	switch (self.axisLabelingPolicy) {
		case CPAxisLabelingPolicyAdHoc:
			// Nothing to do. User sets labels.
			break;
		case CPAxisLabelingPolicyFixedInterval:
			// Add ticks in negative direction
			[self tickLocationsBeginningAt:self.fixedPoint increasing:NO majorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			[allNewMajorLocations unionSet:newMajorLocations];  
			[allNewMinorLocations unionSet:newMinorLocations];  
			
			// Add ticks in positive direction
			[self tickLocationsBeginningAt:self.fixedPoint increasing:YES majorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			[allNewMajorLocations unionSet:newMajorLocations];
			[allNewMinorLocations unionSet:newMinorLocations];
			
			break;
		case CPAxisLabelingPolicyLogarithmic:
			// TODO: logarithmic labeling policy
			break;
	}
	self.majorTickLocations = allNewMajorLocations;
	self.minorTickLocations = allNewMinorLocations;
	
	// Label ticks
	NSArray *newLabels = [self newAxisLabelsAtLocations:self.majorTickLocations.allObjects];
	self.axisLabels = [NSSet setWithArray:newLabels];
    [newLabels release];
    
    self.needsRelabel = NO;
}

#pragma mark -
#pragma mark Sublayer Layout

-(void)layoutSublayers 
{
    if ( self.needsRelabel ) [self relabel];
    for ( CPAxisLabel *label in self.axisLabels ) {
        CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
        [label positionRelativeToViewPoint:tickBasePoint inDirection:self.tickDirection];
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setAxisLabels:(NSSet *)newLabels 
{
    if ( newLabels != axisLabels ) {
        for ( CPAxisLabel *label in axisLabels ) {
            [label removeFromSuperlayer];
        }
		
		[newLabels retain];
        [axisLabels release];
        axisLabels = newLabels;

        for ( CPAxisLabel *label in axisLabels ) {
            [self addSublayer:label];
        }

		[self setNeedsDisplay];		
	}
}

-(void)setNeedsRelabel:(BOOL)newNeedsRelabel 
{
    if (newNeedsRelabel != needsRelabel) {
        needsRelabel = newNeedsRelabel;
        if ( needsRelabel ) {
            [self setNeedsLayout];
        }
    }
}

-(void)setMajorTickLocations:(NSSet *)newLocations 
{
    if ( newLocations != majorTickLocations ) {
        [majorTickLocations release];
        majorTickLocations = [newLocations retain];
		[self setNeedsDisplay];		
    }
}

-(void)setMinorTickLocations:(NSSet *)newLocations 
{
    if ( newLocations != majorTickLocations ) {
        [minorTickLocations release];
        minorTickLocations = [newLocations retain];
		[self setNeedsDisplay];		
    }
}

-(void)setMajorTickLength:(CGFloat)newLength 
{
    if ( newLength != majorTickLength ) {
        majorTickLength = newLength;
        [self setNeedsDisplay];
    }
}

-(void)setMinorTickLength:(CGFloat)newLength 
{
    if ( newLength != minorTickLength ) {
        minorTickLength = newLength;
        [self setNeedsDisplay];
    }
}

-(void)setAxisLabelOffset:(CGFloat)newOffset 
{
    if ( newOffset != axisLabelOffset ) {
        axisLabelOffset = newOffset;
		self.needsRelabel = YES;
    }
}

-(void)setPlotSpace:(CPPlotSpace *)newSpace 
{
    if ( newSpace != plotSpace ) {
        [plotSpace release];
        plotSpace = [newSpace retain];
        self.needsRelabel = YES;
    }
}

-(void)setCoordinate:(CPCoordinate)newCoordinate 
{
    if (newCoordinate != coordinate) {
        coordinate = newCoordinate;
        self.needsRelabel = YES;
    }
}

-(void)setAxisLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != axisLineStyle ) {
        [axisLineStyle release];
        axisLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setMajorTickLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != majorTickLineStyle ) {
        [majorTickLineStyle release];
        majorTickLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setMinorTickLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != minorTickLineStyle ) {
        [minorTickLineStyle release];
        minorTickLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setFixedPoint:(NSDecimalNumber *)newFixedPoint 
{
    if ( newFixedPoint != fixedPoint ) {
        [fixedPoint release];
        fixedPoint = [newFixedPoint copy];
        self.needsRelabel = YES;
    }
}

-(void)setMajorIntervalLength:(NSDecimalNumber *)newIntervalLength 
{
    if ( newIntervalLength != majorIntervalLength ) {
        [majorIntervalLength release];
        majorIntervalLength = [newIntervalLength copy];
        self.needsRelabel = YES;
    }
}

-(void)setMinorTicksPerInterval:(NSUInteger)newMinorTicksPerInterval 
{
    if (newMinorTicksPerInterval != minorTicksPerInterval) {
        minorTicksPerInterval = newMinorTicksPerInterval;
        self.needsRelabel = YES;
    }
}

-(void)setAxisLabelingPolicy:(CPAxisLabelingPolicy)newPolicy 
{
    if (newPolicy != axisLabelingPolicy) {
        axisLabelingPolicy = newPolicy;
        self.needsRelabel = YES;
    }
}

-(void)setTickLabelFormatter:(NSNumberFormatter *)newTickLabelFormatter 
{
    if ( newTickLabelFormatter != tickLabelFormatter ) {
        [tickLabelFormatter release];
        tickLabelFormatter = [newTickLabelFormatter retain];
        self.needsRelabel = YES;
    }
}

-(void)setTickDirection:(CPDirection)newDirection 
{
    if (newDirection != tickDirection) {
        tickDirection = newDirection;
        self.needsRelabel = YES;
    }
}

@end
