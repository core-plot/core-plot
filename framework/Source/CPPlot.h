
#import "CPDefinitions.h"
#import "CPPlotRange.h"
#import "CPLayer.h"


@class CPPlot;
@class CPPlotSpace;


@protocol CPPlotDataSource <NSObject>

-(NSUInteger)numberOfRecords; 

@optional

// Implement one of the following
-(NSArray *)numbersForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange; 
-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index; 

-(NSRange)recordIndexRangeForPlot:(CPPlot *)plot plotRange:(CPPlotRange *)plotRect;

@end 


@interface CPPlot : CPLayer {
    id <CPPlotDataSource> dataSource;
    id <NSCopying, NSObject> identifier;
    CPPlotSpace *plotSpace;
    BOOL dataNeedsReloading;
}

@property (nonatomic, readwrite, assign) id <CPPlotDataSource> dataSource;
@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
@property (nonatomic, readwrite, assign) BOOL dataNeedsReloading;

-(void)reloadData;

-(NSArray *)decimalNumbersFromDataSourceForField:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange;
-(NSRange)recordIndexRangeForPlotRange:(CPPlotRange *)plotRange;

@end



