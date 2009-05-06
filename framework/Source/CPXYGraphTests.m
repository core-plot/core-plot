
#import "CPXYGraphTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPScatterPlot.h"
#import "CPCartesianPlotSpace.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPFillStyle.h"
#import "CPPlotSymbol.h"

@interface CPXYGraph (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation CPXYGraph (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder 
{
    [super gtm_unitTestEncodeState:inCoder];

}

@end

@implementation CPXYGraphTests
@synthesize graph;
@synthesize xData;
@synthesize yData;

- (void)setUp
{
    self.graph = [[[CPXYGraph alloc] initWithXScaleType:CPScaleTypeLinear
                                             yScaleType:CPScaleTypeLinear]
                  autorelease];
    
    NSUInteger nRecords = 100;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:nRecords];
    for(NSUInteger i=0; i<nRecords; i++) {
        [arr insertObject:[NSDecimalNumber numberWithInteger:i] atIndex:i];
    }
    self.xData = arr;
    
    arr = [NSMutableArray arrayWithCapacity:nRecords];
    for(NSUInteger i=0; i<nRecords; i++) {
        [arr insertObject:[NSDecimalNumber numberWithFloat:sin(2*M_PI*(float)i/(float)nRecords)] atIndex:i];
    }
    self.yData = arr;
}

- (void)tearDown
{
    self.graph = nil;
    self.xData = nil;
    self.yData = nil;
}

- (void)testRenderScatterWithSymbol
{
    self.graph.bounds = CGRectMake(0., 0., 400., 200.);
    
    CPCartesianPlotSpace *plotSpace = (CPCartesianPlotSpace*)[[self graph] defaultPlotSpace];
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) 
                                                   length:CPDecimalFromInt(100.)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.1) 
                                                   length:CPDecimalFromFloat(2.2)];
    
    CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 0.1;
    dataSourceLinePlot.dataSource = self;
    
    // Add plot symbols
	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	CGColorRef greenColor = CPNewCGColorFromNSColor([NSColor greenColor]);
	greenCirclePlotSymbol.fillColor = greenColor;
    greenCirclePlotSymbol.size = CGSizeMake(1.0, 1.0);
    dataSourceLinePlot.defaultPlotSymbol = greenCirclePlotSymbol;
	CGColorRelease(greenColor);
    
    [[self graph] addPlot:dataSourceLinePlot];
    
    GTMAssertObjectImageEqualToImageNamed(self.graph, @"CPXYGraphTests-testRenderScatterWithSymbol", @"Should render a sine wave with green symbols.");
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords 
{
    NSParameterAssert(self.xData.count == self.yData.count);
    
    return self.xData.count;
}

-(NSNumber *)numberForPlot:(CPPlot *)plot 
                     field:(NSUInteger)fieldEnum 
               recordIndex:(NSUInteger)index 
{
    
    NSNumber *result;
    
    switch(fieldEnum) {
        case CPScatterPlotFieldX:
            result = [[self xData] objectAtIndex:index];
            break;
        case CPScatterPlotFieldY:
            result = [[self yData] objectAtIndex:index];
            if([[[self graph] allPlots] count] > 1) {
                result = [NSDecimalNumber decimalNumberWithDecimal:[result decimalValue]];
                result = [(NSDecimalNumber*)result decimalNumberByAdding:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInteger:[[[self graph] allPlots] indexOfObject:plot]] decimalValue]]];
            }
            break;
        default:
            [NSException raise:CPDataException format:@"Unexpected fieldEnum"];
    }
    
    return result;
}

@end
