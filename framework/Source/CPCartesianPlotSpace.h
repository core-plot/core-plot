
#import <Foundation/Foundation.h>
#import "CPPlotSpace.h"
#import "CPDefinitions.h"

@class CPLineStyle;

@interface CPCartesianPlotSpace : CPPlotSpace {
	CPPlotRange XRange, YRange;
	NSArray* XMajorTickLocations, *YMajorTickLocations;
	CPLineStyle* majorTickLineStyle;
}

@property (nonatomic, readwrite, assign) CPPlotRange XRange, YRange;
@property (nonatomic, readwrite, retain) NSArray* XMajorTickLocations, *YMajorTickLocations;
@property (nonatomic, readwrite, retain) CPLineStyle* majorTickLineStyle;

@end
