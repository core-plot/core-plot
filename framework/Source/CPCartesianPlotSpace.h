
#import <Foundation/Foundation.h>
#import "CPPlotSpace.h"

@interface CPCartesianPlotSpace : CPPlotSpace {
    CGPoint scale, offset;
	NSDecimalNumber* lowerX, *lowerY, *upperX, *upperY;
}

@property (nonatomic, readwrite, assign) CGPoint scale, offset;

- (NSArray*) XRange;
- (void) setXRange:(NSArray*)limits;

- (NSArray*) YRange;
- (void) setYRange:(NSArray*)limits;

@end
