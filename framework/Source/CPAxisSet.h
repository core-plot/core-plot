
#import <Foundation/Foundation.h>
#import "CPLayer.h"


@class CPPlotSpace;

@interface CPAxisSet : CPLayer {
    NSArray *axes;
}

@property (nonatomic, readwrite, retain) NSArray *axes;

@end
