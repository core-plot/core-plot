#import "CPTDataSourceTestCase.h"
#import "CPTExceptions.h"
#import "CPTMutablePlotRange.h"
#import "CPTScatterPlot.h"
#import "CPTUtilities.h"

const CGFloat CPTDataSourceTestCasePlotOffset = 0.5;

/// @cond
@interface CPTDataSourceTestCase()

-(CPTMutablePlotRange *)plotRangeForData:(NSArray *)dataArray;

@end

/// @endcond

@implementation CPTDataSourceTestCase

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
    //check CPTDataSource conformance
    STAssertTrue([self conformsToProtocol:@protocol(CPTPlotDataSource)], @"CPTDataSourceTestCase should conform to <CPTPlotDataSource>");
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

    for ( NSUInteger i = 0; i < self.nRecords; i++ ) {
        [arr insertObject:[NSDecimalNumber numberWithUnsignedInteger:i] atIndex:i];
    }
    self.xData = arr;

    arr = [NSMutableArray arrayWithCapacity:self.nRecords];
    for ( NSUInteger i = 0; i < self.nRecords; i++ ) {
        [arr insertObject:[NSDecimalNumber numberWithDouble:sin(2 * M_PI * (double)i / (double)nRecords)] atIndex:i];
    }
    self.yData = arr;
}

-(void)addPlot:(CPTPlot *)newPlot
{
    if ( nil == self.plots ) {
        self.plots = [NSMutableArray array];
    }

    [[self plots] addObject:newPlot];
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
        range.length = CPTDecimalAdd( [range length], CPTDecimalFromDouble(self.plots.count) );
    }

    return range;
}

-(CPTMutablePlotRange *)plotRangeForData:(NSArray *)dataArray
{
    double min   = [[dataArray valueForKeyPath:@"@min.doubleValue"] doubleValue];
    double max   = [[dataArray valueForKeyPath:@"@max.doubleValue"] doubleValue];
    double range = max - min;

    return [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromDouble(min - 0.05 * range)
                                               length:CPTDecimalFromDouble(range + 0.1 * range)];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.nRecords;
}

-(NSArray *)numbersForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
          recordIndexRange:(NSRange)indexRange
{
    NSArray *result;

    switch ( fieldEnum ) {
        case CPTScatterPlotFieldX:
            result = [[self xData] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;

        case CPTScatterPlotFieldY:
            result = [[self yData] objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            if ( self.plots.count > 1 ) {
                STAssertTrue([[self plots] containsObject:plot], @"Plot missing");
                NSMutableArray *shiftedResult = [NSMutableArray arrayWithCapacity:result.count];
                for ( NSDecimalNumber *d in result ) {
                    [shiftedResult addObject:[d decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromDouble( CPTDataSourceTestCasePlotOffset * ([[self plots] indexOfObject:plot] + 1) )]]];
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
