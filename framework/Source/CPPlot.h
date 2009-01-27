
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@class CPPlot;


@protocol CPPlotDataSource <NSObject>

-(NSUInteger)numberOfRecords; 

@optional

// Implement one of the following
-(NSData *)dataForPlot:(CPPlot *)plot field:(NSString *)fieldIdentifier recordIndexRange:(NSRange)indexRange; 
-(NSArray *)numbersForPlot:(CPPlot *)plot field:(NSString *)fieldIdentifier recordIndexRange:(NSRange)indexRange; 
-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSString *)fieldIdentifier recordIndex:(NSUInteger)index; 

@end 


@interface CPPlot : CALayer {
    id <CPPlotDataSource> dataSource;
    id <NSCopying> identifier;
}

@property (nonatomic, readwrite, assign) id <CPPlotDataSource> dataSource;
@property (nonatomic, readwrite, copy) id <NSCopying> identifier;

@end
