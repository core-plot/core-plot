#import "CPXYPlotSpaceTests.h"
#import "CPXYGraph.h"
#import "CPXYPlotSpace.h"
#import "CPExceptions.h"
#import "CPPlotRange.h"
#import "CPUtilities.h"

@interface CPXYPlotSpace(testingAdditions)

-(CPPlotRange *)constrainRange:(CPPlotRange *)existingRange toGlobalRange:(CPPlotRange *)globalRange;

@end

#pragma mark -

@implementation CPXYPlotSpaceTests

@synthesize graph;

-(void)setUp 
{
    self.graph = [[(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 50.0)] autorelease];
	self.graph.paddingLeft = 0.0;
	self.graph.paddingRight = 0.0;
	self.graph.paddingTop = 0.0;
	self.graph.paddingBottom = 0.0;
	
	[self.graph layoutIfNeeded];
}

-(void)tearDown
{
	self.graph = nil;
}

-(void)testViewPointForPlotPoint
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
                                                        length:CPDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
                                                        length:CPDecimalFromDouble(10.0)];
    
    NSDecimal plotPoint[2];
	plotPoint[CPCoordinateX] = CPDecimalFromDouble(5.0);
	plotPoint[CPCoordinateY] = CPDecimalFromDouble(5.0);
    
    CGPoint viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)25.0, (CGFloat)0.01, @"");
    
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
                                                        length:CPDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
                                                        length:CPDecimalFromDouble(5.0)];
    
    viewPoint = [plotSpace plotAreaViewPointForPlotPoint:plotPoint];
    
    STAssertEqualsWithAccuracy(viewPoint.x, (CGFloat)50.0, (CGFloat)0.01, @"");
    STAssertEqualsWithAccuracy(viewPoint.y, (CGFloat)50.0, (CGFloat)0.01, @"");
}

-(void)testPlotPointForViewPoint 
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
                                                        length:CPDecimalFromDouble(10.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
                                                        length:CPDecimalFromDouble(10.0)];
        
    NSDecimal plotPoint[2];
    CGPoint viewPoint = CGPointMake(50.0, 25.0);
    NSString *errMessage;
	
	[plotSpace plotPoint:plotPoint forPlotAreaViewPoint:viewPoint];
	
	errMessage = [NSString stringWithFormat:@"plotPoint[CPCoordinateX] was %@", NSDecimalString(&plotPoint[CPCoordinateX], nil)];
	STAssertTrue(CPDecimalEquals(plotPoint[CPCoordinateX], CPDecimalFromDouble(5.0)), errMessage);
	errMessage = [NSString stringWithFormat:@"plotPoint[CPCoordinateY] was %@", NSDecimalString(&plotPoint[CPCoordinateY], nil)];
	STAssertTrue(CPDecimalEquals(plotPoint[CPCoordinateY], CPDecimalFromDouble(5.0)), errMessage);
}

-(void)testConstrainNilRanges
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	
	STAssertEqualObjects([plotSpace constrainRange:plotSpace.xRange toGlobalRange:nil], plotSpace.xRange, @"Constrain to nil global range should return original range.");
	STAssertNil([plotSpace constrainRange:nil toGlobalRange:plotSpace.xRange], @"Constrain nil range should return nil.");
}

-(void)testConstrainRanges1
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	
	CPPlotRange *existingRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(2.0) 
															 length:CPDecimalFromDouble(5.0)];
	CPPlotRange *globalRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
														   length:CPDecimalFromDouble(10.0)];
	CPPlotRange *expectedRange = existingRange;
	
	CPPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
	NSString *errMessage = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange, nil];
	STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

-(void)testConstrainRanges2
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	
	CPPlotRange *existingRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
															 length:CPDecimalFromDouble(10.0)];
	CPPlotRange *globalRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
														   length:CPDecimalFromDouble(5.0)];
	CPPlotRange *expectedRange = globalRange;
	
	CPPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
	NSString *errMessage = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange, nil];
	STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

-(void)testConstrainRanges3
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	
	CPPlotRange *existingRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(-1.0) 
															 length:CPDecimalFromDouble(8.0)];
	CPPlotRange *globalRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
														   length:CPDecimalFromDouble(10.0)];
	CPPlotRange *expectedRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
														   length:CPDecimalFromDouble(8.0)];
	
	CPPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
	NSString *errMessage = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange, nil];
	STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

-(void)testConstrainRanges4
{
	CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)self.graph.defaultPlotSpace;
	
	CPPlotRange *existingRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(3.0) 
															 length:CPDecimalFromDouble(8.0)];
	CPPlotRange *globalRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(0.0) 
														   length:CPDecimalFromDouble(10.0)];
	CPPlotRange *expectedRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromDouble(2.0) 
															 length:CPDecimalFromDouble(8.0)];
	
	CPPlotRange *constrainedRange = [plotSpace constrainRange:existingRange toGlobalRange:globalRange];
	NSString *errMessage = [NSString stringWithFormat:@"constrainedRange was %@, expected %@", constrainedRange, expectedRange, nil];
	STAssertTrue([constrainedRange isEqualToRange:expectedRange], errMessage);
}

@end
