
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

@class CPGradient;
@class CPImage;
@class CPColor;

@interface CPFill : NSObject <NSCopying, NSCoding> {
	
}

/// @name Factory Methods
/// @{
+(CPFill *)fillWithColor:(CPColor *)aColor;
+(CPFill *)fillWithGradient:(CPGradient *)aGradient;
+(CPFill *)fillWithImage:(CPImage *)anImage;
///	@}

/// @name Initialization
/// @{
-(id)initWithColor:(CPColor *)aColor;
-(id)initWithGradient:(CPGradient *)aGradient;
-(id)initWithImage:(CPImage *)anImage;
///	@}

@end

/**	@category CPFill(AbstractMethods)
 *	@brief CPFill abstract methods—must be overridden by subclasses
 **/
@interface CPFill(AbstractMethods)

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
