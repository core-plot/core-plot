//
//  CPPlotSymbolTests.m
//  CorePlot
//

#import <Cocoa/Cocoa.h>
#import "CPPlotSymbolTests.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPScatterPlot.h"
#import "CPXYPlotSpace.h"
#import "CPUtilities.h"
#import "CPPlotSymbol.h"


@implementation CPPlotSymbolTests

@synthesize plot;

- (void)setUpPlotSpace
{
    
    CPXYPlotSpace *plotSpace = [[[CPXYPlotSpace alloc] init] autorelease];
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(-1) 
                                                   length:CPDecimalFromInt(self.nRecords+1)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromInt(-1)
                                                   length:CPDecimalFromInt(self.nRecords+1)];
    
    
    self.plot = [[[CPScatterPlot alloc] init] autorelease];
    self.plot.frame = CGRectMake(0.0, 0.0, 110.0, 110.0);
    self.plot.dataLineStyle = nil;
    self.plot.plotSpace = plotSpace;
    self.plot.dataSource = self;
}

- (void)tearDown
{
    self.plot = nil;
}

- (void)buildData
{
	NSUInteger n = self.nRecords;
	
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:n*n];
    for (NSUInteger i=0; i<n; i++) {
		for (NSUInteger j=0; j<n; j++) {
			[arr insertObject:[NSDecimalNumber numberWithUnsignedInteger:j] atIndex:i*n+j];
		}
	}
    self.xData = arr;
    
    arr = [NSMutableArray arrayWithCapacity:n*n];
    for (NSUInteger i=0; i<n; i++) {
		for (NSUInteger j=0; j<n; j++) {
 			[arr insertObject:[NSDecimalNumber numberWithUnsignedInteger:i] atIndex:i*n+j];
		}
	}
    self.yData = arr;
}

- (void)testPlotSymbols
{
	self.nRecords = 1;
    [self buildData];
	[self setUpPlotSpace];
    self.plot.identifier = @"Plot Symbols";
    
	CPPlotSymbol *plotSymbol = [[[CPPlotSymbol alloc] init] autorelease];
    plotSymbol.size = CGSizeMake(100.0, 100.0);
	
	// Create a custom path.
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, 0., 0.);
	
	CGPathAddEllipseInRect(path, NULL, CGRectMake(0., 0., 10., 10.));
	CGPathAddEllipseInRect(path, NULL, CGRectMake(1.5, 4., 3., 3.));
	CGPathAddEllipseInRect(path, NULL, CGRectMake(5.5, 4., 3., 3.));
	CGPathMoveToPoint(path, NULL, 5., 2.);
	CGPathAddArc(path, NULL, 5., 3.3, 2.8, 0., pi, TRUE);
	CGPathCloseSubpath(path);
	
	plotSymbol.customSymbolPath = path;
	CGPathRelease(path);
	
	for (NSUInteger i=CPPlotSymbolTypeNone; i<=CPPlotSymbolTypeCustom; i++) {
		plotSymbol.symbolType = i;
		self.plot.plotSymbol = plotSymbol;

		NSString *plotName = [NSString stringWithFormat:@"CPPlotSymbolTests-testSymbol%lu", (unsigned long)i];
		NSString *errorMessage = [NSString stringWithFormat:@"Should plot symbol #%lu", (unsigned long)i];
        [self.plot setNeedsDisplay];
		
		GTMAssertObjectImageEqualToImageNamed(self.plot, plotName, errorMessage);		
	}
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
	NSUInteger n = self.nRecords;
    return n*n;
}


@end
