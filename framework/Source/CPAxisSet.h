
#import <Foundation/Foundation.h>
#import "CPLayer.h"


@class CPPlotSpace;

@interface CPAxisSet : NSObject {
    NSArray *axes;
}

@property (nonatomic, readwrite, retain) NSArray *axes;

-(void)drawInContext:(CGContextRef)theContext withPlotSpace:(CPPlotSpace*)aPlotSpace;


@end
