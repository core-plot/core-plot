
#import <Foundation/Foundation.h>

@class CPLineStyle;
@class CPPlotSpace;

@interface CPAxis : NSObject {    
    CPPlotSpace *plotSpace;
    NSArray *majorTickLocations;
    NSArray *minorTickLocations;
    CGFloat majorTickLength;
    CGFloat minorTickLength;
    CPLineStyle *axisLineStyle;
    CPLineStyle *majorTickLineStyle;
    CPLineStyle *minorTickLineStyle;
}

@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
@property (nonatomic, readwrite, retain) NSArray *majorTickLocations;
@property (nonatomic, readwrite, retain) NSArray *minorTickLocations;
@property (nonatomic, readwrite, assign) CGFloat minorTickLength;
@property (nonatomic, readwrite, assign) CGFloat majorTickLength;

@end
