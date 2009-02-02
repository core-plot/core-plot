
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPDefinitions.h"


@class CPPlot;
@class CPPlotSpace;


@protocol CPPlotDataSource <NSObject>

-(NSUInteger)numberOfRecords; 

@optional

// Implement one of the following
-(NSData *)dataForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange; 
-(NSArray *)numbersForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange; 
-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index; 

-(NSIndexSet *)recordIndexesInPlotRange:(CPPlotRange)plotRect;

@end 


@interface CPPlot : CALayer {
    id <CPPlotDataSource> dataSource;
    id <NSCopying, NSObject> identifier;
    CPPlotSpace *plotSpace;
}

@property (nonatomic, readwrite, assign) id <CPPlotDataSource> dataSource;
@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;

@end
