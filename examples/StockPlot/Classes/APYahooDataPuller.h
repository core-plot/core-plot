#import <Foundation/Foundation.h>

@class APYahooDataPuller;

@protocol APYahooDataPullerDelegate

@optional

-(void)dataPullerFinancialDataDidChange:(APYahooDataPuller *)dp;
-(void)dataPuller:(APYahooDataPuller *)dp downloadDidFailWithError:(NSError *)error;

@end

@interface APYahooDataPuller : NSObject {
    NSString *symbol;
    NSDate *startDate;
    NSDate *endDate;

    NSDate *targetStartDate;
    NSDate *targetEndDate;
    NSString *targetSymbol;

    id delegate;
    NSDecimalNumber *overallHigh;
    NSDecimalNumber *overallLow;
    BOOL loadingData;
    BOOL staleData;

    @private
    NSArray *financialData; // consists of dictionaries

    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, copy) NSString *targetSymbol;
@property (nonatomic, strong) NSDate *targetStartDate;
@property (nonatomic, strong) NSDate *targetEndDate;
@property (nonatomic, readonly, strong) NSArray *financialData;
@property (nonatomic, readonly, strong) NSDecimalNumber *overallHigh;
@property (nonatomic, readonly, strong) NSDecimalNumber *overallLow;
@property (nonatomic, readonly, assign) BOOL loadingData;
@property (nonatomic, readonly, assign) BOOL staleData;

-(id)initWithTargetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate;
-(void)fetchIfNeeded;
-(void)cancelDownload;

@end
