

#import "CPAxis.h"
#import "CPPlotSpace.h"
#import "CPUtilities.h"
#import "CPPlotRange.h"
#import "CPLineStyle.h"
#import "CPTextLayer.h"
#import "CPAxisLabel.h"

@interface CPAxis ()

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

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	self = [super init];
	if (self != nil) {
		self.plotSpace = nil;
		self.majorTickLocations = [NSArray array];
		self.minorTickLocations = [NSArray array];
		self.minorTickLength = 0.f;
		self.majorTickLength = 0.f;
		self.axisLabelOffset = 0.f;
		self.majorTickLineStyle = [CPLineStyle lineStyle];
		self.minorTickLineStyle = [CPLineStyle lineStyle];
        self.fixedPoint = [NSDecimalNumber zero];
        self.majorIntervalLength = [NSDecimalNumber one];
        self.minorTicksPerInterval = 1;
        self.coordinate = CPCoordinateX;
        self.axisLabelingPolicy = CPAxisLabelingPolicyFixedInterval;
		self.tickLabelFormatter = [[[NSNumberFormatter alloc] init] autorelease];
		self.tickLabelFormatter.format = @"#0.0";
		self.axisLabels = [NSSet set];
        self.tickDirection = CPDirectionDown;
	}
	return self;
}


-(void)dealloc {
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
    }
    else {
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

-(NSArray *)createAxisLabelsAtLocations:(NSArray *)locations
{
    NSMutableArray *newLabels = [NSMutableArray arrayWithCapacity:locations.count];
	for ( NSDecimalNumber *tickLocation in locations ) {
        NSString *labelString = [self.tickLabelFormatter stringForObjectValue:tickLocation];
        CPAxisLabel *newLabel = [[CPAxisLabel alloc] initWithText:labelString];
        newLabel.tickLocation = tickLocation;
        newLabel.offset = self.axisLabelOffset;
        [newLabels addObject:newLabel];
        [newLabel release];
	}
	return newLabels;
}

-(void)relabel
{
    if ( plotSpace == nil ) return;
	
    if ( axisLabelingPolicy == CPAxisLabelingPolicyFixedInterval ) {
        NSMutableSet *allNewMajorLocations = [NSMutableSet set];
        NSMutableSet *allNewMinorLocations = [NSMutableSet set];

        // Add ticks in negative direction
        NSSet *newMajorLocations, *newMinorLocations;
        [self tickLocationsBeginningAt:self.fixedPoint increasing:NO majorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
        [allNewMajorLocations unionSet:newMajorLocations];  
        [allNewMinorLocations unionSet:newMinorLocations];  
        
        // Add ticks in positive direction
        [self tickLocationsBeginningAt:self.fixedPoint increasing:YES majorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
		
        [allNewMajorLocations unionSet:newMajorLocations];  
        [allNewMinorLocations unionSet:newMinorLocations];  
        
        self.majorTickLocations = allNewMajorLocations;
        self.minorTickLocations = allNewMinorLocations;
        
        // Label ticks
        NSArray *newLabels = [self createAxisLabelsAtLocations:self.majorTickLocations.allObjects];
        self.axisLabels = [NSSet setWithArray:newLabels];
    }
}

#pragma mark -
#pragma mark Sublayer Layout

-(void)layoutSublayers 
{
    [self relabel];
    for ( CPAxisLabel *label in axisLabels ) {
        CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
        [label positionRelativeToViewPoint:tickBasePoint inDirection:tickDirection];
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
        [axisLabels release];
        axisLabels = [newLabels retain];
        for ( CPAxisLabel *label in axisLabels ) {
            [self addSublayer:label];
        }
    }
}

@end
