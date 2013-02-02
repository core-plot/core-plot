#import "CPTLayer.h"

@class CPTAxis;

@interface CPTGridLines : CPTLayer {
    @private
    __cpt_weak CPTAxis *axis;
    BOOL major;
}

@property (nonatomic, readwrite, cpt_weak_property) __cpt_weak CPTAxis *axis;
@property (nonatomic, readwrite) BOOL major;

@end
