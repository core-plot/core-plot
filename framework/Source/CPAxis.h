
#import <Foundation/Foundation.h>

@class CPLineStyle;
@class CPPlotSpace;
@class CPPlotRange;

@interface CPAxis : NSObject {    
    NSArray *majorTickLocations;
    NSArray *minorTickLocations;
    CGFloat majorTickLength;
    CGFloat minorTickLength;
    CPLineStyle *axisLineStyle;
    CPLineStyle *majorTickLineStyle;
    CPLineStyle *minorTickLineStyle;

	CPPlotRange *range;
}

@property (nonatomic, readwrite, retain) NSArray *majorTickLocations;
@property (nonatomic, readwrite, retain) NSArray *minorTickLocations;
@property (nonatomic, readwrite, assign) CGFloat minorTickLength;
@property (nonatomic, readwrite, assign) CGFloat majorTickLength;
@property (nonatomic, readwrite, retain) CPPlotRange *range;

-(void)drawInContext:(CGContextRef)theContext withPlotSpace:(CPPlotSpace*)aPlotSpace;

@end
