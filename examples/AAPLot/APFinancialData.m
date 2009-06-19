
#import "APFinancialData.h"
#import "NSDateFormatterExtensions.h"

@implementation NSDictionary (APFinancialData)  


+(id)dictionaryWithCSVLine:(NSString*)csvLine;
{
    NSArray *csvChunks = [csvLine componentsSeparatedByString:@","];
    
    NSMutableDictionary *csvDict = [NSMutableDictionary dictionaryWithCapacity:7];
    
	// Date,Open,High,Low,Close,Volume,Adj Close
    // 2009-06-08,143.82,144.23,139.43,143.85,33255400,143.85
    NSDate *theDate = [[NSDateFormatter csvDateFormatter] dateFromString:(NSString *)[csvChunks objectAtIndex:0]];
    [csvDict setObject:theDate forKey:@"date"];
    NSDecimalNumber *theOpen = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:1]];
    [csvDict setObject:theOpen forKey:@"open"];
    NSDecimalNumber *theHigh = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:2]];
    [csvDict setObject:theHigh forKey:@"high"];
    NSDecimalNumber *theLow = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:3]];
    [csvDict setObject:theLow forKey:@"low"];    
    NSDecimalNumber *theClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:4]];
    [csvDict setObject:theClose forKey:@"close"];
    NSDecimalNumber *theVolume = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:5]];
    [csvDict setObject:theVolume forKey:@"volume"];
    NSDecimalNumber *theAdjClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:6]];
    [csvDict setObject:theAdjClose forKey:@"adjClose"];
    
    //non-mutable autoreleased dict
    return [NSDictionary dictionaryWithDictionary:csvDict];
}

@end
