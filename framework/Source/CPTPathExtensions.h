#import <CoreGraphics/CoreGraphics.h>
/// @file

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

CF_IMPLICIT_BRIDGING_ENABLED

__nonnull CGPathRef CPTCreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);

CF_IMPLICIT_BRIDGING_DISABLED

void CPTAddRoundedRectPath(__nonnull CGContextRef context, CGRect rect, CGFloat cornerRadius);

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif
