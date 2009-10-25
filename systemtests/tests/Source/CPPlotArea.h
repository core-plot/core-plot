#import "CPBorderedLayer.h"

@class CPAxisSet;
@class CPPlotGroup;

@interface CPPlotArea : CPBorderedLayer {
@private
    CPAxisSet *axisSet;
    CPPlotGroup *plotGroup;
}

@property (nonatomic, readwrite, retain) CPAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPPlotGroup *plotGroup;

@end
