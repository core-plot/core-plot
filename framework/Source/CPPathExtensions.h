
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/// @file

CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);
void AddRoundedRectPath(CGContextRef context, CGRect rect, CGFloat cornerRadius);
