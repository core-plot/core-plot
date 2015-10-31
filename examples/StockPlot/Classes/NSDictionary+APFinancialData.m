#import "NSDictionary+APFinancialData.h"

@interface NSDateFormatter(yahooCSVDateFormatter)

+(NSDateFormatter *)yahooCSVDateFormatter;

@end

@implementation NSDateFormatter(yahooCSVDateFormatter)

+(NSDateFormatter *)yahooCSVDateFormatter
{
    static NSDateFormatter *df       = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    });

    return df;
}

@end

@implementation NSDictionary(APFinancialData)

+(CPTDictionary *)dictionaryWithCSVLine:(NSString *)csvLine
{
    CPTStringArray *csvChunks = [csvLine componentsSeparatedByString:@","];

    CPTMutableDictionary *csvDict = [NSMutableDictionary dictionaryWithCapacity:7];

    // Date,Open,High,Low,Close,Volume,Adj Close
    // 2009-06-08,143.82,144.23,139.43,143.85,33255400,143.85
    NSDate *theDate = [[NSDateFormatter yahooCSVDateFormatter] dateFromString:csvChunks[0]];

    csvDict[@"date"] = theDate;
    NSDecimalNumber *theOpen = [NSDecimalNumber decimalNumberWithString:csvChunks[1]];
    csvDict[@"open"] = theOpen;
    NSDecimalNumber *theHigh = [NSDecimalNumber decimalNumberWithString:csvChunks[2]];
    csvDict[@"high"] = theHigh;
    NSDecimalNumber *theLow = [NSDecimalNumber decimalNumberWithString:csvChunks[3]];
    csvDict[@"low"] = theLow;
    NSDecimalNumber *theClose = [NSDecimalNumber decimalNumberWithString:csvChunks[4]];
    csvDict[@"close"] = theClose;
    NSDecimalNumber *theVolume = [NSDecimalNumber decimalNumberWithString:csvChunks[5]];
    csvDict[@"volume"] = theVolume;
    NSDecimalNumber *theAdjClose = [NSDecimalNumber decimalNumberWithString:csvChunks[6]];
    csvDict[@"adjClose"] = theAdjClose;

    //non-mutable autoreleased dict
    return [NSDictionary dictionaryWithDictionary:csvDict];
}

@end
