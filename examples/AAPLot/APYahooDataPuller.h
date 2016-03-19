#import "APFinancialData.h"

@class APYahooDataPuller;

typedef NSArray<CPTDictionary> *CPTFinancialDataArray;

@protocol APYahooDataPullerDelegate<NSObject>

@optional

-(void)dataPullerDidFinishFetch:(nonnull APYahooDataPuller *)dp;

@end

#pragma mark -

@interface APYahooDataPuller : NSObject

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
@property (nonatomic, readonly, strong, nonnull) NSDecimalNumber *overallVolumeHigh;
@property (nonatomic, readonly, strong, nonnull) NSDecimalNumber *overallVolumeLow;
@property (nonatomic, readonly, assign) BOOL loadingData;

-(nonnull instancetype)initWithTargetSymbol:(nonnull NSString *)aSymbol targetStartDate:(nonnull NSDate *)aStartDate targetEndDate:(nonnull NSDate *)anEndDate;

@end
