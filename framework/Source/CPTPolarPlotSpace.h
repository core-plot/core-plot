#import "CPTAnimation.h"
#import "CPTDefinitions.h"
#import "CPTPlotSpace.h"

@class CPTPlotRange;

@interface CPTPolarPlotSpace : CPTPlotSpace<CPTAnimationDelegate>

/// @name Angle
/// @{
@property (nonatomic, readwrite, assign) CPTPolarRadialAngleMode radialAngleOption;
/// @}

/// @name Coordinate Range & Scale Types
/// @{
@property (nonatomic, readwrite, copy, nonnull) CPTPlotRange *majorRange;
@property (nonatomic, readwrite, copy, nonnull) CPTPlotRange *minorRange;
@property (nonatomic, readwrite, copy, nullable) CPTPlotRange *globalMajorRange;
@property (nonatomic, readwrite, copy, nullable) CPTPlotRange *globalMinorRange;
@property (nonatomic, readwrite, copy, nonnull) CPTPlotRange *radialRange;
@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *centrePosition;
@property (nonatomic, readwrite, assign) CPTScaleType majorScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType minorScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType radialScaleType;
/// @}

@property (nonatomic, readwrite) BOOL allowsMomentum;
@property (nonatomic, readwrite) BOOL allowsMomentumMajor;
@property (nonatomic, readwrite) BOOL allowsMomentumMinor;
@property (nonatomic, readwrite) CPTAnimationCurve momentumAnimationCurve;
@property (nonatomic, readwrite) CPTAnimationCurve bounceAnimationCurve;
@property (nonatomic, readwrite) CGFloat momentumAcceleration;
@property (nonatomic, readwrite) CGFloat bounceAcceleration;
@property (nonatomic, readwrite) CGFloat minimumDisplacementToDrag;

-(void)cancelAnimations;

@end
