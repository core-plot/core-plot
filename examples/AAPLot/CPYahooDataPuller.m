//
//  CPYahooDataPuller.m
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright 2009 Sounds Broken inc.. All rights reserved.
//

#import "CPYahooDataPuller.h"

static NSDateFormatter *csvDateFormatter()
{
    static NSDateFormatter *df;
    if(!df)
    {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    return df;
}

@interface CPFinancialData (PrivateAPI)

- (void)populateWithCSV:(NSString *)csvLine;

@end


@implementation CPFinancialData

- (void)dealloc
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

@synthesize date;
@synthesize open;
@synthesize high;
@synthesize low;
@synthesize close;
@synthesize volume;
@synthesize adjClose;

- (void)populateWithCSV:(NSString *)csvLine
{
    //TODO: parse individual csv line here;
    NSArray *csvChunks = [csvLine componentsSeparatedByString:@","];
    //Date,Open,High,Low,Close,Volume,Adj Close
    //2009-06-08,143.82,144.23,139.43,143.85,33255400,143.85
    NSDate *theDate = [csvDateFormatter() dateFromString:(NSString *)[csvChunks objectAtIndex:0]];
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
    //NSLog(@"%@", self);
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


//Designated init
- (id)initWithCSVLine:(NSString*)csvLine;
{
    self = [super init];
    if (self != nil) {
        [self populateWithCSV:csvLine];
    }
    return self;
}

- (id) init
{
    return [self initWithCSVLine:@""];
}

@end

@interface CPYahooDataPuller ()

@property(nonatomic, copy)NSString *csvString;
@property(nonatomic, readwrite, retain)NSArray *financialData; 
@property(nonatomic, readwrite, retain)NSDecimalNumber *overallHigh;
@property(nonatomic, readwrite, retain)NSDecimalNumber *overallLow;
//@property(nonatomic, assign)BOOL hostIsReachable;
@property(nonatomic, retain)NSMutableData *receivedData;
@property(nonatomic, retain)NSURLConnection *connection;
@property(nonatomic, assign)BOOL loadingData;

@end

@interface CPYahooDataPuller (PrivateAPI)

-(void)fetch;
-(NSString *)URL;
-(void)notifyPulledData;
-(void)parseCSVAndPopulate;
-(void)download;

@end

@implementation CPYahooDataPuller

-(void)dealloc
{
    [symbol release];
    [startDate release];
    [endDate release];
    [csvString release];
    [financialData release];
    
    symbol = nil;
    startDate = nil;
    endDate = nil;
    csvString = nil;
    financialData = nil;
    
    delegate = nil;
    [super dealloc];
}

@synthesize symbol;
@synthesize startDate;
@synthesize endDate;
@synthesize overallLow;
@synthesize overallHigh;
@synthesize csvString;
@synthesize financialData;
@synthesize delegate;

@synthesize receivedData;
@synthesize connection;
@synthesize loadingData;

//Designated init.
- (id)initWithSymbol:(NSString*)aSymbol startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate;
{
    self = [super init];
    if (self != nil) {
        [self setSymbol:aSymbol];
        [self setStartDate:aStartDate];
        [self setOverallLow:[NSDecimalNumber notANumber]];
        [self setOverallHigh:[NSDecimalNumber notANumber]];
        [self setEndDate:anEndDate];
        [self setFinancialData:[NSArray array]];
        [self setCsvString:@""];
        [self performSelector:@selector(fetch) withObject:nil afterDelay:0.01];
    }
    return self;
}

- (id)init
{
    NSDate *start = [NSDate dateWithTimeIntervalSinceNow:-(60 * 60 * 24 * 14)]; // two weeks ago.
    NSDate *end = [NSDate date]; // now
    return [self initWithSymbol:@"AAPL" startDate:start endDate:end];
}

//http://www.goldb.org/ystockquote.html
-(NSString *)URL;
{
    
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit | NSYearCalendarUnit;
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *compsStart = [gregorian components:unitFlags fromDate:startDate];
    NSDateComponents *compsEnd = [gregorian components:unitFlags fromDate:endDate];
    
    [gregorian release];
    
    NSString *url = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@&", [self symbol]];
    url = [url stringByAppendingFormat:@"a=%d&", [compsStart month]-1];
    url = [url stringByAppendingFormat:@"b=%d&", [compsStart day]];
    url = [url stringByAppendingFormat:@"c=%d&", [compsStart year]];
    
    url = [url stringByAppendingFormat:@"d=%d&", [compsEnd month]-1];
    url = [url stringByAppendingFormat:@"e=%d&", [compsEnd day]];
    url = [url stringByAppendingFormat:@"f=%d&", [compsEnd year]];
    url = [url stringByAppendingString:@"g=d&"];

    url = [url stringByAppendingString:@"ignore=.csv"];
    
    return url;
}

-(void)notifyPulledData
{
    if(delegate && [delegate respondsToSelector:@selector(dataPullerDidFinishFetch:)])
    {
        [delegate performSelector:@selector(dataPullerDidFinishFetch:) withObject:self];
    }
}

-(void)fetch
{
    NSString *url = [self URL];
    NSLog(@"url == %@", url);
    //TODO: go talk to the internetz
    [self download];
}

#pragma mark Downloading of data
//    [self updateHostandNetworkStatus]; should be called before this to be accurate
- (BOOL)shouldDownload
{    
    // default to allow
    BOOL shouldDownload = YES; 
    //    if (delegate && [self.delegate respondsToSelector:@selector(dataPullerShouldDownloadRemoteData:)])
    //    {
    //        shouldDownload = [delegate dataPullerShouldDownloadRemoteData:self];
    //    }
    return shouldDownload;
}

- (void)download
{
    if (self.loadingData)
        return;
    //if host status is up and if it's okay to download.
    
    if ([self shouldDownload])
    {                
        self.loadingData = YES;
        NSURL *url = [NSURL URLWithString:[self URL]];
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        
        // create the connection with the request
        // and start loading the data
        self.connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        if (self.connection) 
        {
            self.receivedData = [NSMutableData data];
        } else {
            //TODO: Inform the user that the download could not be started
            self.loadingData = NO;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [self.receivedData setLength:0];
}

- (void)cancelDownload
{
    if (self.loadingData)
    {
        [self.connection cancel];
        self.loadingData = NO;
        
        // release the connection and receivedData
        self.receivedData = nil;
        self.connection = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.loadingData = NO;
    // release the connection and receivedData
    self.receivedData = nil;
    self.connection = nil;
    //inform delegate of the failure
    //TODO:report err
}

// Check the contends of the data downloaded for plist and, if it's valid, updates the GRPlistModel (_model)
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.loadingData = NO;
    
    // release the connection
    self.connection = nil;    
    
    //We need to make sure that we are only sending UTF8 - encoded plists.
    NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    
    self.csvString = csv;
    [csv release];
    self.receivedData = nil;
    [self parseCSVAndPopulate];
}

-(void)parseCSVAndPopulate;
{
    NSArray *csvLines = [self.csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *newFinancials = [NSMutableArray arrayWithCapacity:[csvLines count]];
    CPFinancialData *currentFinancial = nil;
    NSString *line = nil;
    for (NSUInteger i=1; i<[csvLines count]-1; i++) {
        line = (NSString *)[csvLines objectAtIndex:i];
        currentFinancial = [[CPFinancialData alloc] initWithCSVLine:line];
        [newFinancials addObject:currentFinancial];
        
        NSDecimalNumber *high = [currentFinancial high];
        NSDecimalNumber *low = [currentFinancial low];
        
        if([self.overallHigh isEqualTo:[NSDecimalNumber notANumber]])
        {
            self.overallHigh = high;
        }
        if([self.overallLow isEqualTo:[NSDecimalNumber notANumber]])
        {
            self.overallLow = low;
        }
        if([low compare:self.overallLow] == NSOrderedAscending)
        {
            self.overallLow = low;
        }
        if([high compare:self.overallHigh] == NSOrderedDescending)
        {
            self.overallHigh = high;
        }
        
        [currentFinancial release];
        
    }
    [self setFinancialData:[NSArray arrayWithArray:newFinancials]];
    [self notifyPulledData];
}

@end
