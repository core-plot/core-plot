/// @file

#if __cplusplus
extern "C" {
#endif

__nonnull CGPathRef CPTCreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);
void CPTAddRoundedRectPath(__nonnull CGContextRef context, CGRect rect, CGFloat cornerRadius);

#if __cplusplus
}
#endif
