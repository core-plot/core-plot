
#import "CPScatterPlotTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPScatterPlot.h"
#import "CPCartesianPlotSpace.h"
#import "CPUtilities.h"
#import "CPLineStyle.h"
#import "CPFillStyle.h"
#import "CPPlotSymbol.h"

#import "GTMTestTimer.h"


@implementation CPScatterPlotTests
@synthesize plot;

- (void)setUp
{
    
    CPCartesianPlotSpace *plotSpace = [[[CPCartesianPlotSpace alloc] init] autorelease];
    plotSpace.bounds = CGRectMake(0., 0., 400., 200.);
    
    self.plot = [[[CPScatterPlot alloc] init] autorelease];
    self.plot.bounds = plotSpace.bounds;
    [plotSpace addSublayer:self.plot];
    
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) 
                                                   length:CPDecimalFromInt(self.nRecords)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(-1.1) 
                                                   length:CPDecimalFromFloat(2.2)];
    
    
    self.plot.plotSpace = plotSpace;
    self.plot.identifier = @"Scatter Plot";
	self.plot.dataLineStyle.lineWidth = 1.0;
    self.plot.dataSource = self;
}

- (void)tearDown
{
    self.plot = nil;
}

- (void)testRenderScatter
{
    self.nRecords = 1e3;
    [self buildData];
    
    GTMAssertObjectImageEqualToImageNamed(self.plot, @"CPScatterPlotTests-testRenderScatter", @"Should plot sine wave");
}

/**
 Verify that CPScatterPlot can render 1e5 points in less than 1 second.
 */
- (void)testRenderScatterTimeLimit
{
    self.nRecords = 1e5;
    [self buildData];
    
    //set up CGContext
    CGContextRef ctx = GTMCreateUnitTestBitmapContextOfSizeWithData(self.plot.bounds.size, NULL);
    
    GTMTestTimer *t = GTMTestTimerCreate();
    
    // render several times
    for(NSInteger i = 0; i<3; i++) {
        GTMTestTimerStart(t);
        self.plot.dataNeedsReloading = YES;
        [self.plot drawInContext:ctx];
        GTMTestTimerStop(t);
    }
    
    //verify performance
    STAssertTrue(GTMTestTimerGetSeconds(t)/GTMTestTimerGetIterations(t) < 1.0, @"rendering took more than 1 second for 1e6 points. Avg. time = %g", GTMTestTimerGetSeconds(t)/GTMTestTimerGetIterations(t));
    
    // clean up
    GTMTestTimerRelease(t);
    CFRelease(ctx);
}

    
@end
