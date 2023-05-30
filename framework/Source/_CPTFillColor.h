#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTFill.h>
#else
#import "CPTFill.h"
#endif

@interface _CPTFillColor : CPTFill

/// @name Initialization
/// @{
-(nonnull instancetype)initWithColor:(nonnull CPTColor *)aColor NS_DESIGNATED_INITIALIZER;
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(nonnull CGContextRef)context;
-(void)fillPathInContext:(nonnull CGContextRef)context;
/// @}

@end
