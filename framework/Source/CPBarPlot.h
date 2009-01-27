
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPBarPlot;


@protocol CPBarPlotDataSource <CPPlotDataSource>

-(NSUInteger)numberOfSiblings;

@optional

-(NSNumber *)numberForBarPlot:(CPBarPlot *)plot field:(NSString *)fieldIdentifier siblingIndex:(NSUInteger)siblingIndex recordIndex:(NSUInteger)index; 

@end 


@interface CPBarPlot : CPPlot {
    CPNumericType numericTypeForX;
    CPNumericType numericTypeForY;
    NSMutableArray *observedObjectsForXValues;
    NSMutableArray *observedObjectsForYValues;
    NSMutableArray *keyPathsForXValues;
    NSMutableArray *keyPathsForYValues;
} 

@property (nonatomic, readwrite, assign) CPNumericType numericTypeForX;
@property (nonatomic, readwrite, assign) CPNumericType numericTypeForY;

@end
