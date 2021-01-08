#import "CPTAxisSet.h"

@class CPTPolarAxis;

@interface CPTPolarAxisSet : CPTAxisSet

@property (nonatomic, readonly, retain) CPTPolarAxis *majorAxis;
@property (nonatomic, readonly, retain) CPTPolarAxis *minorAxis;
@property (nonatomic, readonly, retain) CPTPolarAxis *radialAxis;

@end
