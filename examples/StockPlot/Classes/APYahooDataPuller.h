#import "NSDictionary+APFinancialData.h"

@class APYahooDataPuller;

typedef NSArray<CPTDictionary> *CPTFinancialDataArray;

@protocol APYahooDataPullerDelegate<NSObject>

@optional

-(void)dataPullerFinancialDataDidChange:(nonnull APYahooDataPuller *)dp;
-(void)dataPuller:(nonnull APYahooDataPuller *)dp downloadDidFailWithError:(nonnull NSError *)error;

@end

#pragma mark -

@interface APYahooDataPuller : NSObject<APYahooDataPullerDelegate>

@property (nonatomic, readwrite, weak, nullable) id<APYahooDataPullerDelegate> delegate;
@property (nonatomic, readwrite, copy, nonnull) NSString *symbol;
@property (nonatomic, readwrite, strong, nonnull) NSDate *startDate;
@property (nonatomic, readwrite, strong, nonnull) NSDate *endDate;
@property (nonatomic, readwrite, copy, nonnull) NSString *targetSymbol;
@property (nonatomic, readwrite, strong, nonnull) NSDate *targetStartDate;
@property (nonatomic, readwrite, strong, nonnull) NSDate *targetEndDate;
@property (nonatomic, readonly, strong, nonnull) CPTFinancialDataArray financialData;
@property (nonatomic, readonly, strong, nonnull) NSDecimalNumber *overallHigh;
@property (nonatomic, readonly, strong, nonnull) NSDecimalNumber *overallLow;
@property (nonatomic, readonly, assign) BOOL loadingData;
@property (nonatomic, readonly, assign) BOOL staleData;

-(nonnull instancetype)initWithTargetSymbol:(nonnull NSString *)aSymbol targetStartDate:(nonnull NSDate *)aStartDate targetEndDate:(nonnull NSDate *)anEndDate;
-(void)fetchIfNeeded;
-(void)cancelDownload;

@end
