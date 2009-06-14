
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPPlotArea;


@interface CPPlotSpace : CALayer {
    CPPlotArea *plotArea;
    CGAffineTransform transformToView;
    CGAffineTransform transformToPlot;
}

@property (nonatomic, readwrite, assign) CPPlotArea *plotArea;
@property (nonatomic, readwrite, assign) CGAffineTransform transformToView;
@property (nonatomic, readwrite, assign) CGAffineTransform transformToPlot;

/* 
  Should this method be private? I can't see why it will be used externally.
  NB use CGAffineTransformInvert() to get the 'to plot' transform.
*/
- (CGAffineTransform) calculateTransformToView;

@end


@interface CPPlotSpace (AbstractMethods)

-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers;
-(NSArray *)plotPointForViewPoint:(CGPoint)point;

@end
