// Based on CTGradient (http://blog.oofn.net/2006/01/15/gradients-in-cocoa/)
// CTGradient is in public domain (Thanks Chad Weider!)

/// @file

#import "CPTDefinitions.h"

/**
 *  @brief A structure representing one node in a linked list of RGBA colors.
 **/
typedef struct _CPTGradientElement {
    CPTRGBAColor color; ///< Color
    CGFloat position;   ///< Gradient position (0 ≤ @par{position} ≤ 1)

    struct _CPTGradientElement *nextElement; ///< Pointer to the next CPTGradientElement in the list (last element == @NULL)
}
CPTGradientElement;

/**
 *  @brief Enumeration of blending modes
 **/
typedef NS_ENUM (NSInteger, CPTGradientBlendingMode) {
    CPTLinearBlendingMode,          ///< Linear blending mode
    CPTChromaticBlendingMode,       ///< Chromatic blending mode
    CPTInverseChromaticBlendingMode ///< Inverse chromatic blending mode
};

/**
 *  @brief Enumeration of gradient types
 **/
typedef NS_ENUM (NSInteger, CPTGradientType) {
    CPTGradientTypeAxial, ///< Axial gradient
    CPTGradientTypeRadial ///< Radial gradient
};

@class CPTColorSpace;
@class CPTColor;

@interface CPTGradient : NSObject<NSCopying, NSCoding>

@property (nonatomic, readonly, getter = isOpaque) BOOL opaque;

/// @name Gradient Type
/// @{
@property (nonatomic, readonly) CPTGradientBlendingMode blendingMode;
@property (nonatomic, readwrite, assign) CPTGradientType gradientType;
/// @}

/// @name Axial Gradients
/// @{
@property (nonatomic, readwrite, assign) CGFloat angle;
/// @}

/// @name Radial Gradients
/// @{
@property (nonatomic, readwrite, assign) CGPoint startAnchor;
@property (nonatomic, readwrite, assign) CGPoint endAnchor;
/// @}

/// @name Factory Methods
/// @{
+(instancetype)gradientWithBeginningColor:(CPTColor *)begin endingColor:(CPTColor *)end;
+(instancetype)gradientWithBeginningColor:(CPTColor *)begin endingColor:(CPTColor *)end beginningPosition:(CGFloat)beginningPosition endingPosition:(CGFloat)endingPosition;

+(instancetype)aquaSelectedGradient;
+(instancetype)aquaNormalGradient;
+(instancetype)aquaPressedGradient;

+(instancetype)unifiedSelectedGradient;
+(instancetype)unifiedNormalGradient;
+(instancetype)unifiedPressedGradient;
+(instancetype)unifiedDarkGradient;

+(instancetype)sourceListSelectedGradient;
+(instancetype)sourceListUnselectedGradient;

+(instancetype)rainbowGradient;
+(instancetype)hydrogenSpectrumGradient;
/// @}

/// @name Modification
/// @{
-(CPTGradient *)gradientWithAlphaComponent:(CGFloat)alpha;
-(CPTGradient *)gradientWithBlendingMode:(CPTGradientBlendingMode)mode;

-(CPTGradient *)addColorStop:(CPTColor *)color atPosition:(CGFloat)position; // positions given relative to [0,1]
-(CPTGradient *)removeColorStopAtIndex:(NSUInteger)idx;
-(CPTGradient *)removeColorStopAtPosition:(CGFloat)position;
/// @}

/// @name Information
/// @{
-(CGColorRef)newColorStopAtIndex:(NSUInteger)idx;
-(CGColorRef)newColorAtPosition:(CGFloat)position;
/// @}

/// @name Drawing
/// @{
-(void)drawSwatchInRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
/// @}

@end
