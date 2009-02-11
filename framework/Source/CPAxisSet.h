
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPPlotArea;
@class CPAxis;

@interface CPAxisSet : CPLayer {
    NSArray *axes;
    CPPlotArea *plotArea;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;

@end
