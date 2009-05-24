

#import <Foundation/Foundation.h>
#import "CPAxis.h"
#import "CPDefinitions.h"

@interface CPXYAxis : CPAxis {
    NSDecimalNumber *constantCoordinateValue; 
}

@property (nonatomic, readwrite, copy) NSDecimalNumber *constantCoordinateValue;

@end
