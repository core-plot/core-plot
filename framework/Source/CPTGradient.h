
// Based on CTGradient (http://blog.oofn.net/2006/01/15/gradients-in-cocoa/)
// CTGradient is in public domain (Thanks Chad Weider!)

/// @file

#import <Foundation/Foundation.h>
#import "CPTDefinitions.h"

/**
 *	@brief A structure representing one node in a linked list of RGBA colors.
 **/
typedef struct _CPTGradientElement {
	CPTRGBAColor color;	///< Color
	CGFloat position;	///< Gradient position (0 ≤ position ≤ 1)
	
	struct _CPTGradientElement *nextElement;	///< Pointer to the next CPTGradientElement in the list (last element == NULL)
} CPTGradientElement;

/**
 *	@brief Enumeration of blending modes
 **/
typedef enum _CPTBlendingMode {
	CPTLinearBlendingMode,			///< Linear blending mode
	CPTChromaticBlendingMode,		///< Chromatic blending mode
	CPTInverseChromaticBlendingMode	///< Inverse chromatic blending mode
} CPTGradientBlendingMode;

/**
 *	@brief Enumeration of gradient types
 **/
typedef enum _CPTGradientType {
	CPTGradientTypeAxial,	///< Axial gradient
	CPTGradientTypeRadial	///< Radial gradient
} CPTGradientType;

@class CPTColorSpace;
@class CPTColor;

@interface CPTGradient : NSObject <NSCopying, NSCoding> {
@private
	CPTColorSpace *colorspace;
	CPTGradientElement *elementList;
	CPTGradientBlendingMode blendingMode;
	CGFunctionRef gradientFunction;
	CGFloat angle;	// angle in degrees
	CPTGradientType gradientType;
}

@property (nonatomic, readonly, assign) CPTGradientBlendingMode blendingMode;
@property (nonatomic, readwrite, assign) CGFloat angle;
@property (nonatomic, readwrite, assign) CPTGradientType gradientType;

/// @name Factory Methods
/// @{
+(CPTGradient *)gradientWithBeginningColor:(CPTColor *)begin endingColor:(CPTColor *)end;
+(CPTGradient *)gradientWithBeginningColor:(CPTColor *)begin endingColor:(CPTColor *)end beginningPosition:(CGFloat)beginningPosition endingPosition:(CGFloat)endingPosition;

+(CPTGradient *)aquaSelectedGradient;
+(CPTGradient *)aquaNormalGradient;
+(CPTGradient *)aquaPressedGradient;

+(CPTGradient *)unifiedSelectedGradient;
+(CPTGradient *)unifiedNormalGradient;
+(CPTGradient *)unifiedPressedGradient;
+(CPTGradient *)unifiedDarkGradient;

+(CPTGradient *)sourceListSelectedGradient;
+(CPTGradient *)sourceListUnselectedGradient;

+(CPTGradient *)rainbowGradient;
+(CPTGradient *)hydrogenSpectrumGradient;
///	@}

/// @name Modification
/// @{
-(CPTGradient *)gradientWithAlphaComponent:(CGFloat)alpha;
-(CPTGradient *)gradientWithBlendingMode:(CPTGradientBlendingMode)mode;

-(CPTGradient *)addColorStop:(CPTColor *)color atPosition:(CGFloat)position;	// positions given relative to [0,1]
-(CPTGradient *)removeColorStopAtIndex:(NSUInteger)index;
-(CPTGradient *)removeColorStopAtPosition:(CGFloat)position;
///	@}

/// @name Information
/// @{
-(CGColorRef)newColorStopAtIndex:(NSUInteger)index;
-(CGColorRef)newColorAtPosition:(CGFloat)position;
///	@}

/// @name Drawing
/// @{
-(void)drawSwatchInRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillRect:(CGRect)rect inContext:(CGContextRef)context;
-(void)fillPathInContext:(CGContextRef)context;
///	@}

@end
