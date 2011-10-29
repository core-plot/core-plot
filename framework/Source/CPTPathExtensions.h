#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/// @file

#if __cplusplus
extern "C" {
#endif

CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);
void AddRoundedRectPath(CGContextRef context, CGRect rect, CGFloat cornerRadius);

#if __cplusplus
}
#endif
