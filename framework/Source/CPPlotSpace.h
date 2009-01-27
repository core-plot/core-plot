
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPPlotArea;

@interface CPPlotSpace : CALayer {
    CPPlotArea *plotArea;
}

@property (nonatomic, readwrite, assign) CPPlotArea *plotArea;

@end
