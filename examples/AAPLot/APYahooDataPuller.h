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
    NSDecimalNumber *overallVolumeHigh;
    NSDecimalNumber *overallVolumeLow;

    @private
    NSString *csvString;
    NSArray *financialData; // consists of dictionaries

    BOOL loadingData;
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
@property (nonatomic, readonly, strong) NSDecimalNumber *overallVolumeHigh;
@property (nonatomic, readonly, strong) NSDecimalNumber *overallVolumeLow;

-(id)initWithTargetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate;

@end
