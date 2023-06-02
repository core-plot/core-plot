/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTConstraints.h>
#else
#import "CPTConstraints.h"
#endif

@interface _CPTConstraintsFixed : CPTConstraints

/// @name Initialization
/// @{
-(nonnull instancetype)initWithLowerOffset:(CGFloat)newOffset NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithUpperOffset:(CGFloat)newOffset NS_DESIGNATED_INITIALIZER;
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

@end
