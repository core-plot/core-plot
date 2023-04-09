#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTLayer.h>
#else
#import "CPTLayer.h"
#endif

@class CPTPlotArea;

@interface CPTGridLineGroup : CPTLayer

@property (nonatomic, readwrite, cpt_weak_property, nullable) CPTPlotArea *plotArea;
@property (nonatomic, readwrite) BOOL major;

@end
