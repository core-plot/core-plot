
#import "CPTestCase.h"
#import "CPPlot.h"

@interface CPDataSourceTestCase : CPTestCase <CPPlotDataSource> {
    NSArray *xData;
    NSArray *yData;
    
    NSUInteger nRecords;
}

@property (copy,readwrite) NSArray *xData;
@property (copy,readwrite) NSArray *yData;
@property (assign,readwrite) NSUInteger nRecords;

- (void)buildData;
@end
