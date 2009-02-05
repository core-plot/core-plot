
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPPlotArea;
@class CPAxis;

@interface CPAxisSet : CALayer {
    NSArray *axes;
    CPPlotArea *plotArea;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;

@end
