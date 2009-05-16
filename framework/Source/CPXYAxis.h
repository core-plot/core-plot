

#import <Foundation/Foundation.h>
#import "CPAxis.h"
#import "CPDefinitions.h"

@interface CPXYAxis : CPAxis {
    CPCoordinate coordinate;
    NSDecimal constantCoordinateValue;
}

@property (nonatomic, readwrite, assign) CPCoordinate coordinate;
@property (nonatomic, readwrite, assign) NSDecimal constantCoordinateValue;

@end
