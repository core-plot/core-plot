#import "CPTLayer.h"

@class CPTAxis;
@class CPTLineStyle;

@interface CPTAxisSet : CPTLayer {
    @private
    NSArray *axes;
    CPTLineStyle *borderLineStyle;
}

/// @name Axes
/// @{
@property (nonatomic, readwrite, retain) NSArray *axes;
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
