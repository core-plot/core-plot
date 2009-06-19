
#import "APYahooDataPuller.h"
#import "APFinancialData.h"

@interface APYahooDataPuller ()

@property (nonatomic, copy) NSString *csvString;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL loadingData;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallHigh;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallLow;
@property (nonatomic, readwrite, retain) NSArray *financialData;

-(void)fetch;
-(NSString *)URL;
-(void)notifyPulledData;
-(void)parseCSVAndPopulate;
-(void)download;

@end

@implementation APYahooDataPuller

@synthesize symbol;
@synthesize startDate;
@synthesize endDate;
@synthesize overallLow;
@synthesize overallHigh;
@synthesize csvString;
@synthesize financialData;

@synthesize receivedData;
@synthesize connection;
@synthesize loadingData;

-(id)delegate 
{
    return delegate;
}

-(void)setDelegate:(id)aDelegate
{
    if(delegate != aDelegate)
    {
        delegate = aDelegate;
        if([self.financialData count] > 0)
            [self notifyPulledData]; //loads cached data onto UI
    }
}

- (NSDictionary *)plistRep
{
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];
    [rep setObject:[self symbol] forKey:@"symbol"];
    [rep setObject:[self startDate] forKey:@"startDate"];
    [rep setObject:[self endDate] forKey:@"endDate"];
    [rep setObject:[self overallHigh] forKey:@"overallHigh"];
    [rep setObject:[self overallLow] forKey:@"overallLow"];
    [rep setObject:[self financialData] forKey:@"financalData"];
    return [NSDictionary dictionaryWithDictionary:rep];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
{
    NSLog(@"writeToFile:%@", path);
    BOOL success = [[self plistRep] writeToFile:path atomically:flag];
    return success;
}

-(id)initWithDictionary:(NSDictionary *)aDict;
{
    self = [super init];
    if (self != nil) {
		self.symbol = [aDict objectForKey:@"symbol"];
		self.startDate = [aDict objectForKey:@"startDate"];
        self.overallLow = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallLow"] decimalValue]];
        self.overallHigh = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallHigh"] decimalValue]];
        self.endDate = [aDict objectForKey:@"endDate"];
        self.financialData = [aDict objectForKey:@"financalData"];
		self.csvString = @"";
        [self performSelector:@selector(fetch) withObject:nil afterDelay:0.0];
    }
    return self;
}

-(NSString *)pathForSymbol:(NSString *)aSymbol
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *localPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    return localPath;
}

-(NSDictionary *)dictionaryForSymbol:(NSString *)aSymbol
{
    NSString *path = [self pathForSymbol:aSymbol];
    NSMutableDictionary *localPlistDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    return localPlistDict;
}

-(id)initWithSymbol:(NSString*)aSymbol startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate;
{
    NSDictionary *cachedDictionary = [self dictionaryForSymbol:aSymbol];
    if (nil != cachedDictionary)
    {
        return [self initWithDictionary:cachedDictionary];
    }
    
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];
    [rep setObject:aSymbol forKey:@"symbol"];
    [rep setObject:aStartDate forKey:@"startDate"];
    [rep setObject:anEndDate forKey:@"endDate"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallHigh"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallLow"];
    [rep setObject:[NSArray array] forKey:@"financalData"];
    return [self initWithDictionary:rep];
}

-(id)init
{
    float weeksAgo = 12.0f;// how many weeks ago.
    NSTimeInterval secondsAgo = -fabs(60.0 * 60.0 * 24.0 * 7.0 * weeksAgo);
    NSDate *start = [NSDate dateWithTimeIntervalSinceNow:secondsAgo]; 
    NSDate *end = [NSDate date]; // now
    return [self initWithSymbol:@"AAPL" startDate:start endDate:end];
}

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

// http://www.goldb.org/ystockquote.html
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
    if (delegate && [delegate respondsToSelector:@selector(dataPullerDidFinishFetch:)]) {
        [delegate performSelector:@selector(dataPullerDidFinishFetch:) withObject:self];
    }
}

-(void)fetch
{
    NSString *url = [self URL];
    NSLog(@"url == %@", url);
    [self download];
}

#pragma mark -
#pragma mark Downloading of data

-(BOOL)shouldDownload
{    
    BOOL shouldDownload = YES; 
    return shouldDownload;
}

-(void)download
{
    if ( self.loadingData ) return;
    
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
        if (self.connection) {
            self.receivedData = [NSMutableData data];
        } 
		else {
            //TODO: Inform the user that the download could not be started
            self.loadingData = NO;
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    [self.receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [self.receivedData setLength:0];
}

-(void)cancelDownload
{
    if (self.loadingData) {
        [self.connection cancel];
        self.loadingData = NO;
        
        self.receivedData = nil;
        self.connection = nil;
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.loadingData = NO;
    self.receivedData = nil;
    self.connection = nil;
    
    //TODO:report err
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.loadingData = NO;
	self.connection = nil;    
	
	NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    self.csvString = csv;
    [csv release];
	
    self.receivedData = nil;
    [self parseCSVAndPopulate];
    [self writeToFile:[self pathForSymbol:self.symbol] atomically:YES];
}

-(void)parseCSVAndPopulate;
{
    NSArray *csvLines = [self.csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *newFinancials = [NSMutableArray arrayWithCapacity:[csvLines count]];
    NSDictionary *currentFinancial = nil;
    NSString *line = nil;
    for (NSUInteger i=1; i<[csvLines count]-1; i++) {
        line = (NSString *)[csvLines objectAtIndex:i];
        currentFinancial = [NSDictionary dictionaryWithCSVLine:line];
        [newFinancials addObject:currentFinancial];
        
        NSDecimalNumber *high = [currentFinancial objectForKey:@"high"];
        NSDecimalNumber *low = [currentFinancial objectForKey:@"low"];
        
        if ( [self.overallHigh isEqual:[NSDecimalNumber notANumber]] ) {
            self.overallHigh = high;
        }
        
		if ( [self.overallLow isEqual:[NSDecimalNumber notANumber]] ) {
            self.overallLow = low;
        }
		
        if ( [low compare:self.overallLow] == NSOrderedAscending )  {
            self.overallLow = low;
        }
        if ( [high compare:self.overallHigh] == NSOrderedDescending ) {
            self.overallHigh = high;
        }
                
    }
    [self setFinancialData:[NSArray arrayWithArray:newFinancials]];
    [self notifyPulledData];
}

@end
