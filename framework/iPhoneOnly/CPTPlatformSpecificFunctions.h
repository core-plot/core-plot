/// @file

#if __cplusplus
extern "C" {
#endif

/// @name Graphics Context Save Stack
/// @{
void CPTPushCGContext(__nonnull CGContextRef context);
void CPTPopCGContext(void);

/// @}

/// @name Graphics Context
/// @{
__nonnull CGContextRef CPTGetCurrentContext(void);

/// @}

#if __cplusplus
}
#endif
