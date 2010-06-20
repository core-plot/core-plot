
// Based on CTGradient (http://blog.oofn.net/2006/01/15/gradients-in-cocoa/)
// CTGradient is in public domain (Thanks Chad Weider!)

/// @file

#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

/**
 *	@brief A structure representing one node in a linked list of RGBA colors.
 **/
typedef struct _CPGradientElement {
	CPRGBAColor color;	///< Color
	CGFloat position;	///< Gradient position (0 ≤ position ≤ 1)
	
	struct _CPGradientElement *nextElement;	///< Pointer to the next CPGradientElement in the list (last element == NULL)
} CPGradientElement;

/**
 *	@brief Enumeration of blending modes
 **/
typedef enum _CPBlendingMode {
	CPLinearBlendingMode,			///< Linear blending mode
	CPChromaticBlendingMode,		///< Chromatic blending mode
	CPInverseChromaticBlendingMode	///< Inverse chromatic blending mode
} CPGradientBlendingMode;

/**
 *	@brief Enumeration of gradient types
 **/
typedef enum _CPGradientType {
	CPGradientTypeAxial,	///< Axial gradient
	CPGradientTypeRadial	///< Radial gradient
} CPGradientType;

@class CPColorSpace;
@class CPColor;

@interface CPGradient : NSObject <NSCopying, NSCoding> {
@private
	CPColorSpace *colorspace;
	CPGradientElement *elementList;
	CPGradientBlendingMode blendingMode;
	CGFunctionRef gradientFunction;
	CGFloat angle;	// angle in degrees
	CPGradientType gradientType;
}

@property (assign, readonly) CPGradientBlendingMode blendingMode;
@property (assign) CGFloat angle;
@property (assign) CPGradientType gradientType;

/// @name Factory Methods
/// @{
+(CPGradient *)gradientWithBeginningColor:(CPColor *)begin endingColor:(CPColor *)end;
+(CPGradient *)gradientWithBeginningColor:(CPColor *)begin endingColor:(CPColor *)end beginningPosition:(CGFloat)beginningPosition endingPosition:(CGFloat)endingPosition;

+(CPGradient *)aquaSelectedGradient;
+(CPGradient *)aquaNormalGradient;
+(CPGradient *)aquaPressedGradient;

+(CPGradient *)unifiedSelectedGradient;
+(CPGradient *)unifiedNormalGradient;
+(CPGradient *)unifiedPressedGradient;
+(CPGradient *)unifiedDarkGradient;

+(CPGradient *)sourceListSelectedGradient;
+(CPGradient *)sourceListUnselectedGradient;

+(CPGradient *)rainbowGradient;
+(CPGradient *)hydrogenSpectrumGradient;
///	@}

/// @name Modification
/// @{
-(CPGradient *)gradientWithAlphaComponent:(CGFloat)alpha;
-(CPGradient *)gradientWithBlendingMode:(CPGradientBlendingMode)mode;

-(CPGradient *)addColorStop:(CPColor *)color atPosition:(CGFloat)position;	// positions given relative to [0,1]
-(CPGradient *)removeColorStopAtIndex:(NSUInteger)index;
-(CPGradient *)removeColorStopAtPosition:(CGFloat)position;
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
