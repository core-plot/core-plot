#import "CPLayer.h"

@class CPPlotArea;

@interface CPGridLineGroup : CPLayer {
@private
	__weak CPPlotArea *plotArea;
	BOOL major;
}

@property (nonatomic, readwrite, assign) __weak CPPlotArea *plotArea;
@property (nonatomic, readwrite) BOOL major;

@end
