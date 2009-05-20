
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@class CPLineStyle;
@class CPPlotSpace;
@class CPPlotRange;

typedef enum _CPAxisLabelingPolicy {
    CPAxisLabelingPolicyAdHoc,
    CPAxisLabelingPolicyFixedInterval,
    CPAxisLabelingPolicyLogarithmic // Not implemented
} CPAxisLabelingPolicy;

@interface CPAxis : NSObject {   
    @private
    CPCoordinate coordinate;
	CPPlotSpace *plotSpace;
    NSSet *majorTickLocations;
    NSSet *minorTickLocations;
    CGFloat majorTickLength;
    CGFloat minorTickLength;
	CGFloat tickLabelOffset;
    CPLineStyle *axisLineStyle;
    CPLineStyle *majorTickLineStyle;
    CPLineStyle *minorTickLineStyle;
    NSDecimalNumber *fixedPoint;
    NSDecimalNumber *majorIntervalLength;
    NSUInteger minorTicksPerInterval;
    CPAxisLabelingPolicy axisLabelingPolicy;
	NSNumberFormatter *tickLabelFormatter;
}

@property (nonatomic, readwrite, retain) NSSet *majorTickLocations;
@property (nonatomic, readwrite, retain) NSSet *minorTickLocations;
@property (nonatomic, readwrite, assign) CGFloat minorTickLength;
@property (nonatomic, readwrite, assign) CGFloat majorTickLength;
@property (nonatomic, readwrite, assign) CGFloat tickLabelOffset;
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
@property (nonatomic, readwrite, assign) CPCoordinate coordinate;
@property (nonatomic, readwrite, retain) CPLineStyle *axisLineStyle;
@property (nonatomic, readwrite, retain) CPLineStyle *majorTickLineStyle;
@property (nonatomic, readwrite, retain) CPLineStyle *minorTickLineStyle;
@property (nonatomic, readwrite, retain) NSDecimalNumber *fixedPoint;
@property (nonatomic, readwrite, retain) NSDecimalNumber *majorIntervalLength;
@property (nonatomic, readwrite, assign) NSUInteger minorTicksPerInterval;
@property (nonatomic, readwrite, assign) CPAxisLabelingPolicy axisLabelingPolicy;
@property (nonatomic, readwrite, retain) NSNumberFormatter *tickLabelFormatter;

-(void)relabel;

@end

@interface CPAxis (AbstractMethods)

-(void)drawInContext:(CGContextRef)theContext;

@end
