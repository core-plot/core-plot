
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"


@interface CPScatterPlot : CPPlot {
    CPNumericType numericType;
    id observedObjectForXValues;
    id observedObjectForYValues;
    NSString *keyPathForXValues;
    NSString *keyPathForYValues;
} 

@property (nonatomic, readwrite, assign) CPNumericType numericType;

@end
