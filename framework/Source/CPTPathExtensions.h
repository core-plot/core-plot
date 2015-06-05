/// @file

#if __cplusplus
extern "C" {
#endif

__nonnull CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);
void AddRoundedRectPath(__nonnull CGContextRef context, CGRect rect, CGFloat cornerRadius);

#if __cplusplus
}
#endif
