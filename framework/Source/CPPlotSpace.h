
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLayer.h"
#import "CPDefinitions.h"

@class CPAxisSet;
@class CPPlotRange;

@interface CPPlotSpace : CPLayer {
	id <NSCopying, NSObject> identifier;
}

@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;

@end


@interface CPPlotSpace (AbstractMethods)

-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
-(NSArray *)plotPointForViewPoint:(CGPoint)point;

-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate;

@end
