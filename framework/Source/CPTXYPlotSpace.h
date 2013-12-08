#import "CPTAnimation.h"
#import "CPTDefinitions.h"
#import "CPTPlotSpace.h"

@class CPTPlotRange;

@interface CPTXYPlotSpace : CPTPlotSpace<CPTAnimationDelegate> {
    @private
    CPTPlotRange *xRange;
    CPTPlotRange *yRange;
    CPTPlotRange *globalXRange;
    CPTPlotRange *globalYRange;
    CPTScaleType xScaleType;
    CPTScaleType yScaleType;
    CGPoint lastDragPoint;
    CGPoint lastDisplacement;
    NSTimeInterval lastDragTime;
    NSTimeInterval lastDeltaTime;
    BOOL isDragging;
    BOOL allowsMomentumX;
    BOOL allowsMomentumY;
    NSMutableArray *animations;
    CPTAnimationCurve momentumAnimationCurve;
    CPTAnimationCurve bounceAnimationCurve;
    CGFloat momentumAcceleration;
    CGFloat bounceAcceleration;
}

@property (nonatomic, readwrite, copy) CPTPlotRange *xRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *yRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalXRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalYRange;
@property (nonatomic, readwrite, assign) CPTScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType yScaleType;

@property (nonatomic, readwrite) BOOL allowsMomentum;
@property (nonatomic, readwrite) BOOL allowsMomentumX;
@property (nonatomic, readwrite) BOOL allowsMomentumY;
@property (nonatomic, readwrite) CPTAnimationCurve momentumAnimationCurve;
@property (nonatomic, readwrite) CPTAnimationCurve bounceAnimationCurve;
@property (nonatomic, readwrite) CGFloat momentumAcceleration;
@property (nonatomic, readwrite) CGFloat bounceAcceleration;

@end
