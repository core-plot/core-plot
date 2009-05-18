

#import "CPAxis.h"
#import "CPPlotSpace.h"
#import "CPUtilities.h"
#import "CPPlotRange.h"
#import "CPLineStyle.h"

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

-(void)relabel
{
    if ( plotSpace == nil ) return;
    if ( axisLabelingPolicy == CPAxisLabelingPolicyFixedInterval ) {
        NSMutableSet *tickLocations = [NSMutableSet set];
        CPPlotRange *range = [self.plotSpace plotRangeForCoordinate:self.coordinate];
        
        // Add ticks below fixed point
        NSDecimalNumber *coord = self.fixedPoint;
        while ( [coord isGreaterThanOrEqualTo:range.location] ) {
            [tickLocations addObject:coord];
            coord = [coord decimalNumberBySubtracting:self.majorIntervalLength];
        }
        
        // Add ticks above fixed point
        coord = [self.fixedPoint decimalNumberByAdding:[NSDecimalNumber minimumDecimalNumber]];;
        while ( [coord isLessThanOrEqualTo:range.end] ) {
            [tickLocations addObject:coord];
            coord = [coord decimalNumberByAdding:self.majorIntervalLength];
        }
        
        self.majorTickLocations = tickLocations;
    }
}

@end
