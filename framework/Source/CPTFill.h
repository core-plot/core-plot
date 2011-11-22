#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPTGradient;
@class CPTImage;
@class CPTColor;

@interface CPTFill : NSObject<NSCopying, NSCoding> {
}

/// @name Factory Methods
/// @{
+(CPTFill *)fillWithColor:(CPTColor *)aColor;
+(CPTFill *)fillWithGradient:(CPTGradient *)aGradient;
+(CPTFill *)fillWithImage:(CPTImage *)anImage;
///	@}

/// @name Initialization
/// @{
-(id)initWithColor:(CPTColor *)aColor;
-(id)initWithGradient:(CPTGradient *)aGradient;
-(id)initWithImage:(CPTImage *)anImage;
///	@}

@end

/**	@category CPTFill(AbstractMethods)
 *	@brief CPTFill abstract methods—must be overridden by subclasses
 **/
@interface CPTFill(AbstractMethods)

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
