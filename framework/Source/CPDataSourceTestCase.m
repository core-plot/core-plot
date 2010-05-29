#import "CPDataSourceTestCase.h"
#import "CPExceptions.h"
#import "CPScatterPlot.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

const CGFloat CPDataSourceTestCasePlotOffset = 0.5;

///	@cond
@interface CPDataSourceTestCase ()

-(CPPlotRange *)plotRangeForData:(NSArray *)dataArray;

@end
///	@endcond


@implementation CPDataSourceTestCase

@synthesize xData;
@synthesize yData;
@synthesize nRecords;
@synthesize xRange;
@synthesize yRange;
@synthesize plots;

-(void)dealloc 
{
    self.plots = nil;
    [super dealloc];
}

-(void)setUp
{
    //check CPDataSource conformance
    STAssertTrue([self conformsToProtocol:@protocol(CPPlotDataSource)], @"CPDataSourceTestCase should conform to <CPPlotDataSource>");
}


-(void)tearDown
{
    self.xData = nil;
    self.yData = nil;
    [[self plots] removeAllObjects];
}

-(void)buildData
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.nRecords];
    for ( NSUInteger i=0; i < self.nRecords; i++ ) {
        [arr insertObject:[NSDecimalNumber numberWithUnsignedInteger:i] atIndex:i];
    }
    self.xData = arr;
    
    arr = [NSMutableArray arrayWithCapacity:self.nRecords];
    for ( NSUInteger i=0; i < self.nRecords; i++ ) {
        [arr insertObject:[NSDecimalNumber numberWithFloat:sin(2*M_PI*(float)i/(float)nRecords)] atIndex:i];
    }
    self.yData = arr;
}

-(void)addPlot:(CPPlot *)newPlot
{
    if ( nil == self.plots ) {
        self.plots = [NSMutableArray array];
    }
    
    [[self plots] addObject:newPlot];
}

-(CPPlotRange *)xRange
{
    [self buildData];
    return  [self plotRangeForData:self.xData];
}

-(CPPlotRange *)yRange
{
    [self buildData];
    CPPlotRange *range = [self plotRangeForData:self.yData];
    
    if ( self.plots.count > 1 ) {
        range.length = CPDecimalAdd([range length], CPDecimalFromDouble(self.plots.count));
    }
    
    return range;
}

-(CPPlotRange *)plotRangeForData:(NSArray *)dataArray
{
    double min = [[dataArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    double max = [[dataArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double range = max-min;
    
    return [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(min - 0.05*range)
                                       length:CPDecimalFromDouble(range + 0.1*range)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
    return self.nRecords;
}

-(NSArray *)numbersForPlot:(CPPlot *)plot 
                     field:(NSUInteger)fieldEnum 
          recordIndexRange:(NSRange)indexRange
{
    NSArray *result;
    
    switch ( fieldEnum ) {
        case CPScatterPlotFieldX:
            result = [[self xData] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;
        case CPScatterPlotFieldY:
            result = [[self yData] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            if ( self.plots.count > 1 ) {
                STAssertTrue([[self plots] containsObject:plot], @"Plot missing");
                NSMutableArray *shiftedResult = [NSMutableArray arrayWithCapacity:result.count];
                for ( NSDecimalNumber *d in result ) {
                    [shiftedResult addObject:[d decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromDouble(CPDataSourceTestCasePlotOffset * ([[self plots] indexOfObject:plot]+1))]]];
                }
                
                result = shiftedResult;
            }
            
            break;
        default:
            [NSException raise:CPDataException format:@"Unexpected fieldEnum"];
    }
    
    return result;
}
@end
