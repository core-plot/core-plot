#import "CPTLayer.h"

@class CPTAxis;
@class CPTLineStyle;

@interface CPTAxisSet : CPTLayer

/// @name Axes
/// @{
@property (nonatomic, readwrite, strong) NSArray *axes;
/// @}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
/// @}

/// @name Labels
/// @{
-(void)relabelAxes;
/// @}

/// @name Axes
/// @{
-(CPTAxis *)axisForCoordinate:(CPTCoordinate)coordinate atIndex:(NSUInteger)idx;
/// @}

@end
