/// @file

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

@end
