
#import "CPDataSourceTestCase.h"
#import "CPExceptions.h"
#import "CPScatterPlot.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

@interface CPDataSourceTestCase ()
- (CPPlotRange*)plotRangeForData:(NSArray*)dataArray;
@end


@implementation CPDataSourceTestCase
@synthesize xData;
@synthesize yData;
@synthesize nRecords;
@synthesize xRange;
@synthesize yRange;

- (void)tearDown
{
    self.xData = nil;
    self.yData = nil;
}

- (void)buildData
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.nRecords];
    for(NSUInteger i=0; i<self.nRecords; i++) {
        [arr insertObject:[NSDecimalNumber numberWithInteger:i] atIndex:i];
    }
    self.xData = arr;
    
    arr = [NSMutableArray arrayWithCapacity:self.nRecords];
    for(NSUInteger i=0; i<self.nRecords; i++) {
        [arr insertObject:[NSDecimalNumber numberWithFloat:sin(2*M_PI*(float)i/(float)nRecords)] atIndex:i];
    }
    self.yData = arr;
}

- (CPPlotRange*)xRange {
    return [self plotRangeForData:self.xData];
}

- (CPPlotRange*)yRange {
    return [self plotRangeForData:self.yData];
}

- (CPPlotRange*)plotRangeForData:(NSArray*)dataArray {
    double min = [[dataArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    double max = [[dataArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double range = max-min;
    
    return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(min - .05*range)
                                       length:CPDecimalFromDouble(range + .05*range)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords 
{
    return self.nRecords;
}

-(NSArray *)numbersForPlot:(CPPlot *)plot 
                     field:(NSUInteger)fieldEnum 
          recordIndexRange:(NSRange)indexRange
{
    
    NSArray *result;
    
    switch(fieldEnum) {
        case CPScatterPlotFieldX:
            result = [[self xData] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;
        case CPScatterPlotFieldY:
            result = [[self yData] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;
        default:
            [NSException raise:CPDataException format:@"Unexpected fieldEnum"];
    }
    
    return result;
}
@end
