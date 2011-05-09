#import "CPTLayer.h"

@class CPTPlotArea;

@interface CPTGridLineGroup : CPTLayer {
@private
	__weak CPTPlotArea *plotArea;
	BOOL major;
}

@property (nonatomic, readwrite, assign) __weak CPTPlotArea *plotArea;
@property (nonatomic, readwrite) BOOL major;

@end
