

#import "CPAxis.h"
#import "CPPlotSpace.h"
#import "CPUtilities.h"
#import "CPPlotRange.h"
#import "CPLineStyle.h"

@interface CPAxis ()

-(void)tickLocationsBeginningAt:(NSDecimalNumber *)beginNumber increasing:(BOOL)increasing majorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(NSDecimalNumber *)nextLocationFromCoordinateValue:(NSDecimalNumber *)coord increasing:(BOOL)increasing interval:(NSDecimalNumber *)interval;

@end


@implementation CPAxis

@synthesize majorTickLocations;
@synthesize minorTickLocations;
@synthesize minorTickLength;
@synthesize majorTickLength;
@synthesize axisLineStyle;
@synthesize majorTickLineStyle;
@synthesize minorTickLineStyle;
@synthesize plotSpace;
@synthesize coordinate;
@synthesize fixedPoint;
@synthesize majorIntervalLength;
@synthesize minorTicksPerInterval;
@synthesize axisLabelingPolicy;

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
		self.majorTickLineStyle = [CPLineStyle lineStyle];
		self.minorTickLineStyle = [CPLineStyle lineStyle];
        self.fixedPoint = [NSDecimalNumber zero];
        self.majorIntervalLength = [NSDecimalNumber one];
        self.minorTicksPerInterval = 1;
        self.coordinate = CPCoordinateX;
        self.axisLabelingPolicy = CPAxisLabelingPolicyFixedInterval;
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
    [super dealloc];
}

#pragma mark -
#pragma mark Labeling

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
    NSDecimalNumber *coord = beginNumber;
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    while ( (increasing && [coord isLessThanOrEqualTo:range.end]) || (!increasing && [coord isGreaterThanOrEqualTo:range.location]) ) {
    
        // Major tick
        if ( [coord isLessThanOrEqualTo:range.end] && [coord isGreaterThanOrEqualTo:range.location] ) {
            [majorLocations addObject:coord];
        }
        
        // Minor ticks
        if ( self.minorTicksPerInterval > 0 ) {
            NSDecimalNumber *minorInterval = [self.majorIntervalLength decimalNumberByDividingBy:(id)[NSDecimalNumber numberWithInt:self.minorTicksPerInterval+1]];
            NSDecimalNumber *minorCoord;
            minorCoord = [self nextLocationFromCoordinateValue:coord increasing:increasing interval:minorInterval];
            for ( NSUInteger minorTickIndex = 0; minorTickIndex < self.minorTicksPerInterval; ++minorTickIndex ) {
                if ( [minorCoord isLessThanOrEqualTo:range.end] && [minorCoord isGreaterThanOrEqualTo:range.location] ) {
                    [minorLocations addObject:minorCoord];
                }
                minorCoord = [self nextLocationFromCoordinateValue:minorCoord increasing:increasing interval:minorInterval];
            }
        }
        
        coord = [self nextLocationFromCoordinateValue:coord increasing:increasing interval:self.majorIntervalLength];
    }
    *newMajorLocations = majorLocations;
    *newMinorLocations = minorLocations;
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
        NSDecimalNumber *beginNumber = [self.fixedPoint decimalNumberByAdding:self.majorIntervalLength];
        [self tickLocationsBeginningAt:beginNumber increasing:YES majorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
        [allNewMajorLocations unionSet:newMajorLocations];  
        [allNewMinorLocations unionSet:newMinorLocations];  
        
        self.majorTickLocations = allNewMajorLocations;
        self.minorTickLocations = allNewMinorLocations;
    }
}

@end
