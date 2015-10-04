#import "CPTLayer.h"

@class CPTPlotArea;

@interface CPTGridLineGroup : CPTLayer

@property (nonatomic, readwrite, cpt_weak_property, nullable) cpt_weak CPTPlotArea *plotArea;
@property (nonatomic, readwrite) BOOL major;

@end
