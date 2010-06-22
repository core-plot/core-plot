#import "CPBorderedLayer.h"

@class CPAxisSet;
@class CPPlotGroup;
@class CPPlotArea;

@interface CPPlotAreaFrame : CPBorderedLayer {
	@private
    CPPlotArea *plotArea;
}

@property (nonatomic, readonly, retain) CPPlotArea *plotArea;
@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotGroup *plotGroup;

@end
