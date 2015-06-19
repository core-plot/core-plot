/// @file

#if __cplusplus
extern "C" {
#endif

CGPathRef CPTCreateRoundedRectPath(CGRect rect, CGFloat cornerRadius);
void CPTAddRoundedRectPath(CGContextRef context, CGRect rect, CGFloat cornerRadius);

#if __cplusplus
}
#endif
