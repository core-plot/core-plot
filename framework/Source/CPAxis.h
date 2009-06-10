
#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPDefinitions.h"

@class CPLineStyle;
@class CPPlotSpace;
@class CPPlotRange;

typedef enum _CPAxisLabelingPolicy {
    CPAxisLabelingPolicyAdHoc,
    CPAxisLabelingPolicyFixedInterval,
    CPAxisLabelingPolicyLogarithmic // TODO: Implement logarithmic labeling
} CPAxisLabelingPolicy;

@interface CPAxis : CPLayer {   
    @private
    CPCoordinate coordinate;
	CPPlotSpace *plotSpace;
    NSSet *majorTickLocations;
    NSSet *minorTickLocations;
    CGFloat majorTickLength;
    CGFloat minorTickLength;
	CGFloat axisLabelOffset;
    CPLineStyle *axisLineStyle;
    CPLineStyle *majorTickLineStyle;
    CPLineStyle *minorTickLineStyle;
    NSDecimalNumber *fixedPoint;
    NSDecimalNumber *majorIntervalLength;
    NSUInteger minorTicksPerInterval;
    CPAxisLabelingPolicy axisLabelingPolicy;
	NSNumberFormatter *tickLabelFormatter;
	NSSet *axisLabels;
    CPSign tickDirection;
    BOOL needsRelabel;
	BOOL drawsAxisLine;
}

@property (nonatomic, readwrite, retain) NSSet *majorTickLocations;
@property (nonatomic, readwrite, retain) NSSet *minorTickLocations;
@property (nonatomic, readwrite, assign) CGFloat minorTickLength;
@property (nonatomic, readwrite, assign) CGFloat majorTickLength;
@property (nonatomic, readwrite, assign) CGFloat axisLabelOffset;
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
@property (nonatomic, readwrite, assign) CPCoordinate coordinate;
@property (nonatomic, readwrite, copy) CPLineStyle *axisLineStyle;
@property (nonatomic, readwrite, copy) CPLineStyle *majorTickLineStyle;
@property (nonatomic, readwrite, copy) CPLineStyle *minorTickLineStyle;
@property (nonatomic, readwrite, copy) NSDecimalNumber *fixedPoint;
@property (nonatomic, readwrite, copy) NSDecimalNumber *majorIntervalLength;
@property (nonatomic, readwrite, assign) NSUInteger minorTicksPerInterval;
@property (nonatomic, readwrite, assign) CPAxisLabelingPolicy axisLabelingPolicy;
@property (nonatomic, readwrite, retain) NSNumberFormatter *tickLabelFormatter;
@property (nonatomic, readwrite, retain) NSSet *axisLabels;
@property (nonatomic, readwrite, assign) CPSign tickDirection;
@property (nonatomic, readonly, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) BOOL drawsAxisLine;

-(void)relabel;
-(void)setNeedsRelabel;

-(NSArray *)newAxisLabelsAtLocations:(NSArray *)locations;

@end

@interface CPAxis (AbstractMethods)

-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimalNumber;

@end

