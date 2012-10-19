#import "CPTAnnotationHostLayer.h"
#import <Foundation/Foundation.h>

@class CPTLineStyle;
@class CPTFill;

@interface CPTBorderedLayer : CPTAnnotationHostLayer {
    @private
    CPTLineStyle *borderLineStyle;
    CPTFill *fill;
    BOOL inLayout;
}

/// @name Drawing
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
/// @}

/// @name Layout
/// @{
@property (nonatomic, readwrite) BOOL inLayout;
/// @}

/// @name Drawing
/// @{
-(void)renderBorderedLayer:(CPTBorderedLayer *)layer asVectorInContext:(CGContextRef)context;
/// @}

@end
