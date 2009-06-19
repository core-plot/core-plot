
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
    
    NSDate *targetStartDate;
    NSDate *targetEndDate;
    NSString *targetSymbol;
    
    id delegate;
    NSDecimalNumber *overallHigh;
    NSDecimalNumber *overallLow;

	@private
    NSString *csvString;
    NSArray *financialData; // consists of dictionaries

    BOOL loadingData;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, copy) NSString *targetSymbol;
@property (nonatomic, retain) NSDate *targetStartDate;
@property (nonatomic, retain) NSDate *targetEndDate;
@property (nonatomic, readonly, retain) NSArray *financialData;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallHigh;
@property (nonatomic, readonly, retain) NSDecimalNumber *overallLow;

-(id)initWithTargetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate;

@end
