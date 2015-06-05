#import "CPTLayer.h"

@class CPTAxis;
@class CPTLineStyle;

@interface CPTAxisSet : CPTLayer

/// @name Axes
/// @{
@property (nonatomic, readwrite, strong, nullable) NSArray *axes;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy, nullable) CPTLineStyle *borderLineStyle;
/// @}

/// @name Labels
/// @{
-(void)relabelAxes;
/// @}

/// @name Axes
/// @{
-(nullable CPTAxis *)axisForCoordinate:(CPTCoordinate)coordinate atIndex:(NSUInteger)idx;
/// @}

@end
