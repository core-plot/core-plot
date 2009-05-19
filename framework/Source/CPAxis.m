

#import "CPAxis.h"
#import "CPPlotSpace.h"
#import "CPUtilities.h"
#import "CPPlotRange.h"
#import "CPLineStyle.h"

@interface CPAxis ()

-(NSSet *)tickLocationsBeginningAt:(NSDecimalNumber *)beginNumber increasing:(BOOL)increasing;

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

-(NSSet *)tickLocationsBeginningAt:(NSDecimalNumber *)beginNumber increasing:(BOOL)increasing
{
    NSMutableSet *tickLocations = [NSMutableSet set];
    NSDecimalNumber *coord = beginNumber;
    CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
    while ( (increasing && [coord isLessThanOrEqualTo:range.end]) || (!increasing && [coord isGreaterThanOrEqualTo:range.location]) ) {
        if ( [coord isLessThanOrEqualTo:range.end] && [coord isGreaterThanOrEqualTo:range.location] ) [tickLocations addObject:coord];
        if ( increasing ) {
            coord = [coord decimalNumberByAdding:self.majorIntervalLength];
        }
        else {
            coord = [coord decimalNumberBySubtracting:self.majorIntervalLength];
        }
    }
    return tickLocations;
}

-(void)relabel
{
    if ( plotSpace == nil ) return;
    if ( axisLabelingPolicy == CPAxisLabelingPolicyFixedInterval ) {
        NSMutableSet *tickLocations = [NSMutableSet set];
        
        // Add ticks 
        NSSet *newLocations = [self tickLocationsBeginningAt:self.fixedPoint increasing:NO];
        [tickLocations unionSet:newLocations];  
        NSDecimalNumber *beginNumber = [self.fixedPoint decimalNumberByAdding:self.majorIntervalLength];
        newLocations = [self tickLocationsBeginningAt:beginNumber increasing:YES];
        [tickLocations unionSet:newLocations];

        self.majorTickLocations = tickLocations;
    }
}

@end
