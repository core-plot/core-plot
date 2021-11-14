#import "CPTTestCase.h"

@class CPTXYGraph;
@class CPTXYPlotSpace;

@interface CPTXYPlotSpaceTests : CPTTestCase

@property (nonatomic, readwrite, strong, nullable) CPTXYGraph *graph;
@property (nonatomic, readonly, strong, nullable) CPTXYPlotSpace *plotSpace;

@end
