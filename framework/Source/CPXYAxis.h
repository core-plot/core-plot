

#import <Foundation/Foundation.h>
#import "CPAxis.h"
#import "CPDefinitions.h"

@interface CPXYAxis : CPAxis {
    NSDecimal constantCoordinateValue;
}

@property (nonatomic, readwrite, assign) NSDecimal constantCoordinateValue;

@end
