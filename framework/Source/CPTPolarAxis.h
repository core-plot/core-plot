#import "CPTAxis.h"

@class CPTConstraints;

@interface CPTPolarAxis : CPTAxis

/// @name Positioning
/// @{
@property (nonatomic, readonly, strong, nullable) NSNumber *orthogonalPosition;
@property (nonatomic, readwrite, strong, nullable) CPTConstraints *axisConstraints;
@property (nonatomic, readwrite, strong, nullable) NSSet *alteredMajorTickLocations;

/// @}

/// @name Label
/// @{

@property (nonatomic, readwrite, strong, nullable) NSNumber *radialLabelLocation;
@property (nonatomic, readonly, nonnull) NSNumber *defaultRadialLabelLocation;

/// @}

@end
