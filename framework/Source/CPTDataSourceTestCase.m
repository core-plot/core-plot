#import "CPTDataSourceTestCase.h"

#import "CPTExceptions.h"
#import "CPTMutablePlotRange.h"
#import "CPTScatterPlot.h"
#import "CPTUtilities.h"

static const CGFloat CPTDataSourceTestCasePlotOffset = 0.5;

/// @cond
@interface CPTDataSourceTestCase()

-(CPTMutablePlotRange *)plotRangeForData:(CPTNumberArray *)dataArray;

@end

/// @endcond

@implementation CPTDataSourceTestCase

@synthesize xData;
@synthesize yData;
@synthesize nRecords;
@dynamic xRange;
@dynamic yRange;
@synthesize plots;

-(void)setUp
{
    // check CPTDataSource conformance
    XCTAssertTrue([self conformsToProtocol:@protocol(CPTPlotDataSource)], @"CPTDataSourceTestCase should conform to <CPTPlotDataSource>");
}

-(void)tearDown
{
    self.xData = nil;
    self.yData = nil;
    [self.plots removeAllObjects];
}

-(void)buildData
{
    NSUInteger recordCount = self.nRecords;

    CPTMutableNumberArray *arr = [NSMutableArray arrayWithCapacity:recordCount];

    for ( NSUInteger i = 0; i < recordCount; i++ ) {
        [arr insertObject:@(i) atIndex:i];
    }
    self.xData = arr;

    arr = [NSMutableArray arrayWithCapacity:recordCount];
    for ( NSUInteger i = 0; i < recordCount; i++ ) {
        [arr insertObject:@( sin(2 * M_PI * (double)i / (double)recordCount) ) atIndex:i];
    }
    self.yData = arr;
}

-(void)addPlot:(CPTPlot *)newPlot
{
    if ( nil == self.plots ) {
        self.plots = [NSMutableArray array];
    }

    [self.plots addObject:newPlot];
}

-(CPTPlotRange *)xRange
{
    [self buildData];
    return [self plotRangeForData:self.xData];
}

-(CPTPlotRange *)yRange
{
    [self buildData];
    CPTMutablePlotRange *range = [self plotRangeForData:self.yData];

    if ( self.plots.count > 1 ) {
        range.lengthDecimal = CPTDecimalAdd( range.lengthDecimal, CPTDecimalFromUnsignedInteger(self.plots.count) );
    }

    return range;
}

-(CPTMutablePlotRange *)plotRangeForData:(CPTNumberArray *)dataArray
{
    double min   = [[dataArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    double max   = [[dataArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double range = max - min;

    return [CPTMutablePlotRange plotRangeWithLocation:@(min - 0.05 * range)
                                               length:@(range + 0.1 * range)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.nRecords;
}

-(CPTNumberArray *)numbersForPlot:(CPTPlot *)plot
                            field:(NSUInteger)fieldEnum
                 recordIndexRange:(NSRange)indexRange
{
    CPTNumberArray *result;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            result = [self.xData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;

        case CPTScatterPlotFieldY:
            result = [self.yData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            if ( self.plots.count > 1 ) {
                XCTAssertTrue([[self plots] containsObject:plot], @"Plot missing");
                CPTMutableNumberArray *shiftedResult = [NSMutableArray arrayWithCapacity:result.count];
                for ( NSDecimalNumber *d in result ) {
                    [shiftedResult addObject:[d decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromDouble( CPTDataSourceTestCasePlotOffset * ([self.plots indexOfObject:plot] + 1) )]]];
                }

                result = shiftedResult;
            }

            break;

        default:
            [NSException raise:CPTDataException format:@"Unexpected fieldEnum"];
    }

    return result;
}

@end
