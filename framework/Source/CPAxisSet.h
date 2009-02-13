
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPPlotArea;
@class CPAxis;

@interface CPAxisSet : CPLayer {
    NSArray *axes;
}

@property (nonatomic, readwrite, retain) NSArray *axes;

@end
