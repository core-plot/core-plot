#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTShadow.h>
#else
#import "CPTShadow.h"
#endif

@class CPTColor;

@interface CPTMutableShadow : CPTShadow

@property (nonatomic, readwrite, assign) CGSize shadowOffset;
@property (nonatomic, readwrite, assign) CGFloat shadowBlurRadius;
@property (nonatomic, readwrite, strong, nullable) CPTColor *shadowColor;

@end
