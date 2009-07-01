
#import "CPAxis.h"
#import "CPPlotSpace.h"
#import "CPUtilities.h"
#import "CPPlotRange.h"
#import "CPLineStyle.h"
#import "CPTextStyle.h"
#import "CPTextLayer.h"
#import "CPAxisLabel.h"
#import "CPPlatformSpecificCategories.h"
#import "CPUtilities.h"

@interface CPAxis ()

@property (nonatomic, readwrite, assign) BOOL needsRelabel;

-(void)tickLocationsBeginningAt:(NSDecimalNumber *)beginNumber increasing:(BOOL)increasing majorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(NSDecimalNumber *)nextLocationFromCoordinateValue:(NSDecimalNumber *)coord increasing:(BOOL)increasing interval:(NSDecimalNumber *)interval;

-(NSSet *)filteredTickLocations:(NSSet *)allLocations;

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
@synthesize axisLabelTextStyle;
@synthesize tickLabelFormatter;
@synthesize axisLabels;
@synthesize tickDirection;
@synthesize needsRelabel;
@synthesize drawsAxisLine;
@synthesize labelExclusionRanges;
@synthesize delegate;

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
		self.axisLabelTextStyle = [[[CPTextStyle alloc] init] autorelease];
		NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
		newFormatter.maximumFractionDigits = 1; 
        newFormatter.minimumFractionDigits = 1;
        self.tickLabelFormatter = newFormatter;
		[newFormatter release];
		self.axisLabels = [NSSet set];
        self.tickDirection = CPSignNone;
        self.needsRelabel = YES;
		self.drawsAxisLine = YES;
		self.labelExclusionRanges = nil;
		self.delegate = nil;
	}
	return self;
}


-(void)dealloc {
	self.plotSpace = nil;
	[majorTickLocations release];
	[minorTickLocations release];
	self.axisLineStyle = nil;
	[majorTickLineStyle release];
	[minorTickLineStyle release];
	self.fixedPoint = nil;
	self.majorIntervalLength = nil;
	self.tickLabelFormatter = nil;
	[axisLabels release];
	[axisLabelTextStyle release];
	self.labelExclusionRanges = nil;
	self.delegate = nil;
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
        CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText:labelString textStyle:self.axisLabelTextStyle];
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
	if ( self.delegate && ![self.delegate axisShouldRelabel:self] ) {
        self.needsRelabel = NO;
        return;
    }
	
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
	
	// Filter and set tick locations	
	self.majorTickLocations = [self filteredMajorTickLocations:allNewMajorLocations];
	self.minorTickLocations = [self filteredMinorTickLocations:allNewMinorLocations];
	
	// Label ticks
	NSArray *newLabels = [self newAxisLabelsAtLocations:self.majorTickLocations.allObjects];
	self.axisLabels = [NSSet setWithArray:newLabels];
    [newLabels release];
    
    self.needsRelabel = NO;
	
	[self.delegate axisDidRelabel:self];
}

-(NSSet *)filteredTickLocations:(NSSet *)allLocations 
{
	NSMutableSet *filteredLocations = [allLocations mutableCopy];
	for ( CPPlotRange *range in self.labelExclusionRanges ) {
		for ( NSDecimalNumber *location in allLocations ) {
			if ( [range contains:location] ) [filteredLocations removeObject:location];
		}
	}
	return [filteredLocations autorelease];
}

-(NSSet *)filteredMajorTickLocations:(NSSet *)allLocations
{
	return [self filteredTickLocations:allLocations];
}

-(NSSet *)filteredMinorTickLocations:(NSSet *)allLocations
{
	return [self filteredTickLocations:allLocations];
}

#pragma mark -
#pragma mark Sublayer Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxis;
}

-(void)layoutSublayers 
{
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];

	if ( self.needsRelabel ) [self relabel];
	
    for ( CPAxisLabel *label in self.axisLabels ) {
        CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
        [label positionRelativeToViewPoint:tickBasePoint forCoordinate:OrthogonalCoordinate(self.coordinate) inDirection:self.tickDirection];
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setAxisLabels:(NSSet *)newLabels 
{
    if ( newLabels != axisLabels ) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		
        for ( CPAxisLabel *label in axisLabels ) {
            [label removeFromSuperlayer];
        }
		
		[newLabels retain];
        [axisLabels release];
        axisLabels = newLabels;

        for ( CPAxisLabel *label in axisLabels ) {
            [self addSublayer:label];
        }

		[CATransaction commit];
		
		[self setNeedsDisplay];		
	}
}

-(void)setAxisLabelTextStyle:(CPTextStyle *)newStyle 
{
	if ( newStyle != axisLabelTextStyle ) {
		[axisLabelTextStyle release];
		axisLabelTextStyle = [newStyle copy];
		[self setNeedsLayout];
	}
}

-(void)setLabelExclusionRanges:(NSArray *)ranges {
	if ( ranges != labelExclusionRanges ) {
		[labelExclusionRanges release];
		labelExclusionRanges = [ranges retain];
		[self setNeedsRelabel];
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
        [self setNeedsRelabel];
    }
}

-(void)setMinorTickLocations:(NSSet *)newLocations 
{
    if ( newLocations != majorTickLocations ) {
        [minorTickLocations release];
        minorTickLocations = [newLocations retain];
		[self setNeedsDisplay];		
        [self setNeedsRelabel];
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
		[self setNeedsLayout];
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

-(void)setDrawsAxisLine:(BOOL)newDraws 
{
    if ( newDraws != drawsAxisLine ) {
        drawsAxisLine = newDraws;
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

-(void)setTickDirection:(CPSign)newDirection 
{
    if (newDirection != tickDirection) {
        tickDirection = newDirection;
		[self setNeedsLayout];
    }
}

@end
