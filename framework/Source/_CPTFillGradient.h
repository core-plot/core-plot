#import "CPTFill.h"

@class CPTGradient;

@interface _CPTFillGradient : CPTFill<NSCopying, NSCoding, NSSecureCoding>

/// @name Initialization
/// @{
-(nonnull instancetype)initWithGradient:(nullable CPTGradient *)aGradient NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(nonnull CGContextRef)context;
-(void)fillPathInContext:(nonnull CGContextRef)context;
/// @}

@end
