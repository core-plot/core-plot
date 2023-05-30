/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTFill.h>
#else
#import "CPTFill.h"
#endif

@class CPTGradient;

@interface _CPTFillGradient : CPTFill

/// @name Initialization
/// @{
-(nonnull instancetype)initWithGradient:(nonnull CPTGradient *)aGradient NS_DESIGNATED_INITIALIZER;
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)rect inContext:(nonnull CGContextRef)context;
-(void)fillPathInContext:(nonnull CGContextRef)context;
/// @}

@end
