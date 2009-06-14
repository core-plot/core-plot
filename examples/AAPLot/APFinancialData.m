
#import "APFinancialData.h"
#import "NSDateFormatterExtensions.h"

@interface APFinancialData ()

-(void)populateWithCSV:(NSString *)csvLine;

@end

@implementation APFinancialData

@synthesize date;
@synthesize open;
@synthesize high;
@synthesize low;
@synthesize close;
@synthesize volume;
@synthesize adjClose;

-(id)initWithCSVLine:(NSString*)csvLine;
{
    self = [super init];
    if (self != nil) {
        [self populateWithCSV:csvLine];
    }
    return self;
}

-(id)init
{
    return [self initWithCSVLine:@""];
}

-(void)dealloc
{
    [date release];
    [open release];
    [high release];
    [low release];
    [close release];
    [adjClose release];
    
    date = nil;
    open = nil;
    high = nil;
    low = nil;
    close = nil;
    adjClose = nil;
    [super dealloc];
}

-(void)populateWithCSV:(NSString *)csvLine
{
    // TODO: parse individual csv line here;
    NSArray *csvChunks = [csvLine componentsSeparatedByString:@","];
    
	// Date,Open,High,Low,Close,Volume,Adj Close
    // 2009-06-08,143.82,144.23,139.43,143.85,33255400,143.85
    NSDate *theDate = [[NSDateFormatter csvDateFormatter] dateFromString:(NSString *)[csvChunks objectAtIndex:0]];
    [self setDate:theDate];
    NSDecimalNumber *theOpen = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:1]];
    [self setOpen:theOpen];
    NSDecimalNumber *theHigh = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:2]];
    [self setHigh:theHigh];
    NSDecimalNumber *theLow = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:3]];
    [self setLow:theLow];    
    NSDecimalNumber *theClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:4]];
    [self setClose:theClose];
    NSDecimalNumber *theVolume = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:5]];
    [self setVolume:[theVolume intValue]];
    NSDecimalNumber *theAdjClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:6]];
    [self setAdjClose:theAdjClose];
}

-(NSString *)description
{
    NSString *outStr = [super description];
    outStr = [outStr stringByAppendingFormat:@"\nDate = %@\n", [self date]];
    outStr = [outStr stringByAppendingFormat:@"Open = %@\n", [self open]];
    outStr = [outStr stringByAppendingFormat:@"High = %@\n", [self high]];
    outStr = [outStr stringByAppendingFormat:@"Low = %@\n", [self low]];
    outStr = [outStr stringByAppendingFormat:@"Close = %@\n", [self close]];
    outStr = [outStr stringByAppendingFormat:@"Volume = %d\n", [self volume]];
    outStr = [outStr stringByAppendingFormat:@"AdjClose = %@\n", [self adjClose]];
    return outStr;
}

@end
