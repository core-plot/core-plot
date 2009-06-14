
#import <Foundation/Foundation.h>

@class APYahooDataPuller;

@protocol APYahooDataPullerDelegate

@optional

-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp;

@end

@interface APYahooDataPuller : NSObject {
    NSString *symbol;
    NSDate *startDate;
    NSDate *endDate;
    id delegate;
    NSDecimalNumber *overallHigh;
    NSDecimalNumber *overallLow;

	@private
    NSString *csvString;
    NSArray *financialData; // consists of APFinancialData objs

    BOOL loadingData;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, readonly, retain) NSArray *financialData;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallHigh;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallLow;

-(id)initWithSymbol:(NSString *)aSymbol startDate:(NSDate *)aStartDate endDate:(NSDate *)anEndDate;

@end
