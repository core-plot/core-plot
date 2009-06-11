
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPBarPlot;


typedef enum _CPBarPlotField {
    CPBarPlotFieldY,
    CPBarPlotFieldErrorMinimum,
    CPBarPlotFieldErrorMaximum
} CPBarPlotField;


@protocol CPBarPlotDataSource <CPPlotDataSource>

-(NSUInteger)numberOfSiblings;

@optional

-(NSNumber *)numberForBarPlot:(CPBarPlot *)plot field:(NSUInteger)fieldEnum siblingIndex:(NSUInteger)siblingIndex recordIndex:(NSUInteger)index; 

@end 


@interface CPBarPlot : CPPlot {
    CPNumericType numericTypeForX;
    CPNumericType numericTypeForY;
    NSMutableArray *observedObjectsForXValues;
    NSMutableArray *observedObjectsForYValues;
    NSMutableArray *keyPathsForXValues;
    NSMutableArray *keyPathsForYValues;
    BOOL hasErrorBars;
} 

@property (nonatomic, readwrite, assign) CPNumericType numericTypeForX;
@property (nonatomic, readwrite, assign) CPNumericType numericTypeForY;
@property (nonatomic, readwrite, assign) BOOL hasErrorBars;

@end
