/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTLayer.h>
#else
#import "CPTLayer.h"
#endif

@class CPTAxis;

@interface CPTGridLines : CPTLayer

@property (nonatomic, readwrite, cpt_weak_property, nullable) CPTAxis *axis;
@property (nonatomic, readwrite) BOOL major;

@end
