#import <Foundation/Foundation.h>

@class APYahooDataPuller;

@protocol APYahooDataPullerDelegate

@optional

-(void)dataPullerDidFinishFetch:(APYahooDataPuller *)dp;

@end

@interface APYahooDataPuller : NSObject

@property (nonatomic, readwrite, weak) id delegate;
@property (nonatomic, readwrite, copy) NSString *symbol;
@property (nonatomic, readwrite, strong) NSDate *startDate;
@property (nonatomic, readwrite, strong) NSDate *endDate;
@property (nonatomic, readwrite, copy) NSString *targetSymbol;
@property (nonatomic, readwrite, strong) NSDate *targetStartDate;
@property (nonatomic, readwrite, strong) NSDate *targetEndDate;
@property (nonatomic, readonly, strong) NSArray *financialData;
@property (nonatomic, readonly, strong) NSDecimalNumber *overallHigh;
@property (nonatomic, readonly, strong) NSDecimalNumber *overallLow;
@property (nonatomic, readonly, strong) NSDecimalNumber *overallVolumeHigh;
@property (nonatomic, readonly, strong) NSDecimalNumber *overallVolumeLow;

-(id)initWithTargetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate;

@end
