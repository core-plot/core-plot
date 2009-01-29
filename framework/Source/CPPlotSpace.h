
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPPlotArea;


@interface CPPlotSpace : CALayer {
    CPPlotArea *plotArea;
}

@property (nonatomic, readwrite, assign) CPPlotArea *plotArea;

@end


@interface CPPlotSpace (AbstractMethods)

-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
-(NSArray *)plotPointForViewPoint:(CGPoint)point;

@end
