
#import "CPXYGraphTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPScatterPlot.h"
#import "CPCartesianPlotSpace.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPFillStyle.h"
#import "CPPlotSymbol.h"

#import "GTMTestTimer.h"

@interface CPXYGraph (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation CPXYGraph (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)inCoder 
{
    [super gtm_unitTestEncodeState:inCoder];

}

@end

@interface CPXYGraphTests ()
- (void)buildData;
- (void)addScatterPlot;
@end

@implementation CPXYGraphTests
@synthesize graph;
@synthesize xData;
@synthesize yData;
@synthesize nRecords;

- (void)setUp
{
    self.graph = [[[CPXYGraph alloc] initWithXScaleType:CPScaleTypeLinear
                                             yScaleType:CPScaleTypeLinear]
                  autorelease];
    
    self.nRecords = 100;
    [self buildData];
}

- (void)tearDown
{
    self.graph = nil;
    self.xData = nil;
    self.yData = nil;
}

- (void)buildData
{
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:nRecords];
    for(NSUInteger i=0; i<self.nRecords; i++) {
        [arr insertObject:[NSDecimalNumber numberWithInteger:i] atIndex:i];
    }
    self.xData = arr;
    
    arr = [NSMutableArray arrayWithCapacity:nRecords];
    for(NSUInteger i=0; i<self.nRecords; i++) {
        [arr insertObject:[NSDecimalNumber numberWithFloat:sin(2*M_PI*(float)i/(float)nRecords)] atIndex:i];
    }
    self.yData = arr;
}

- (void)addScatterPlot {
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
}

- (void)testRenderScatterWithSymbol
{
    [self addScatterPlot];
    
    GTMAssertObjectImageEqualToImageNamed(self.graph, @"CPXYGraphTests-testRenderScatterWithSymbol", @"Should render a sine wave with green symbols.");
}

/**
 Verify that XYGraph with single ScatterPlot can render 1e6 points in less than 1 second.
 */
- (void)testRenderScatterTimeLimit
{
    self.nRecords = 1e6;
    [self buildData];
    
    [self addScatterPlot];
    
    //set up CGContext
    CGContextRef ctx = GTMCreateUnitTestBitmapContextOfSizeWithData(self.graph.bounds.size, NULL);
    
    GTMTestTimer *t = GTMTestTimerCreate();
    
    // render 10 times
    for(NSInteger i = 0; i<10; i++) {
        GTMTestTimerStart(t);
        [[self graph] drawInContext:ctx];
        GTMTestTimerStop(t);
    }
    
    //verify performance
    STAssertTrue(GTMTestTimerGetSeconds(t)/GTMTestTimerGetIterations(t) < 1.0, @"rendering took more than 1 second for 1e6 points");
    
    // clean up
    GTMTestTimerRelease(t);
    CFRelease(ctx);
}
    
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords 
{
    return self.nRecords;
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
