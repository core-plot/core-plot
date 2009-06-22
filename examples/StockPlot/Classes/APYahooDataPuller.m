
#import "APYahooDataPuller.h"
#import "NSDictionary+APFinancalData.h"

NSTimeInterval timeIntervalForNumberOfWeeks(float numberOfWeeks)
{
    NSTimeInterval seconds = fabs(60.0 * 60.0 * 24.0 * 7.0 * numberOfWeeks);
    return seconds;
}

@interface APYahooDataPuller ()

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, readwrite, assign) BOOL loadingData;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallHigh;
@property (nonatomic, readwrite, retain) NSDecimalNumber *overallLow;
@property (nonatomic, readwrite, retain) NSArray *financialData;

-(NSString *)URL;
-(void)notifyFinancesChanged;
-(void)populateWithString:(NSString *)csvString;

@end

@implementation APYahooDataPuller

@synthesize symbol;
@synthesize startDate;
@synthesize endDate;
@synthesize targetStartDate;
@synthesize targetEndDate;
@synthesize targetSymbol;
@synthesize overallLow;
@synthesize overallHigh;

@synthesize receivedData;
@synthesize connection;
@synthesize loadingData;

-(id)delegate 
{
    return delegate;
}

-(void)setDelegate:(id)aDelegate
{
    delegate = aDelegate;
}

- (NSArray *)financialData
{
    //NSLog(@"in -financialData, returned financialData = %@", financialData);
    
    return financialData; 
}

//convert any NSNumber in financial line to NSDecimalNumber
-(NSDictionary *)sanitizedFinancialLine:(NSDictionary *)theFinancialLine
{
    NSMutableDictionary *aFinancialLine = [NSMutableDictionary dictionaryWithDictionary:theFinancialLine];
//    NSArray *keys = [NSArray arrayWithObjects:@"adjClose", @"close", @"high", @"low", @"open", @"volume", nil];
    for (id key in [aFinancialLine allKeys]) {
        id something = [aFinancialLine objectForKey:key];
        if ([something respondsToSelector:@selector(decimalValue)]) {
            something = [NSDecimalNumber decimalNumberWithDecimal:[(NSNumber *)something decimalValue]];
            [aFinancialLine setObject:something forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:aFinancialLine];
}

- (void)setFinancialData:(NSArray *)aFinancialData
{
    //NSLog(@"in -setFinancialData:, old value of financialData: %@, changed to: %@", financialData, aFinancialData);
    
    if (financialData != aFinancialData)
    {
        NSMutableArray *mutableFinancialData = [aFinancialData mutableCopy];
        NSDictionary *financialLine = nil;
        NSUInteger i = 0, count = [mutableFinancialData count];
        for (i = 0; i < count; i++) {
            financialLine = (NSDictionary *) [mutableFinancialData objectAtIndex:i];
            financialLine = [self sanitizedFinancialLine:financialLine];
            [mutableFinancialData replaceObjectAtIndex:i withObject:financialLine];
        }
        
        [financialData release];
        financialData = [[NSArray alloc] initWithArray:mutableFinancialData];
        [mutableFinancialData release];
        if(0 < [financialData count])
            [self notifyFinancesChanged];
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

-(id)initWithDictionary:(NSDictionary *)aDict targetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate
{
    self = [super init];
    if (self != nil) {
		self.symbol = [aDict objectForKey:@"symbol"];
		self.startDate = [aDict objectForKey:@"startDate"];
        self.overallLow = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallLow"] decimalValue]];
        self.overallHigh = [NSDecimalNumber decimalNumberWithDecimal:[[aDict objectForKey:@"overallHigh"] decimalValue]];
        self.endDate = [aDict objectForKey:@"endDate"];
        self.financialData = [aDict objectForKey:@"financalData"];
        
        self.targetSymbol = aSymbol;
        self.targetStartDate = aStartDate;
        self.targetEndDate = anEndDate;
    }
    return self;
}


-(NSString *)pathForSymbol:(NSString *)aSymbol
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *docPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    return docPath;
}

-(NSString *)faultTolerantPathForSymbol:(NSString *)aSymbol
{
    NSString *docPath = [self pathForSymbol:aSymbol];;
    if (![[NSFileManager defaultManager] fileExistsAtPath:docPath]) {
        //if there isn't one in the user's documents directory, see if we ship with this data
        docPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    }
    return docPath;
}

//Always returns *something*
-(NSDictionary *)dictionaryForSymbol:(NSString *)aSymbol
{
    NSString *path = [self faultTolerantPathForSymbol:aSymbol];
    NSMutableDictionary *localPlistDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    return localPlistDict;
}

-(id)initWithTargetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate
{
    NSDictionary *cachedDictionary = [self dictionaryForSymbol:aSymbol];
    if (nil != cachedDictionary)
    {
        return [self initWithDictionary:cachedDictionary targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
    }
    
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];
    [rep setObject:aSymbol forKey:@"symbol"];
    [rep setObject:aStartDate forKey:@"startDate"];
    [rep setObject:anEndDate forKey:@"endDate"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallHigh"];
    [rep setObject:[NSDecimalNumber notANumber] forKey:@"overallLow"];
    [rep setObject:[NSArray array] forKey:@"financalData"];
    return [self initWithDictionary:rep targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
}

-(id)init
{
    NSTimeInterval secondsAgo = -timeIntervalForNumberOfWeeks(14.0f); //12 weeks ago
    NSDate *start = [NSDate dateWithTimeIntervalSinceNow:secondsAgo]; 
    
    NSDate *end = [NSDate date];
    return [self initWithTargetSymbol:@"AAPL" targetStartDate:start targetEndDate:end];
}

-(void)dealloc
{
    [symbol release];
    [startDate release];
    [endDate release];
    [financialData release];
    
    symbol = nil;
    startDate = nil;
    endDate = nil;
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
    
    NSDateComponents *compsStart = [gregorian components:unitFlags fromDate:targetStartDate];
    NSDateComponents *compsEnd = [gregorian components:unitFlags fromDate:targetEndDate];
    
    [gregorian release];
    
    NSString *url = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@&", [self targetSymbol]];
    url = [url stringByAppendingFormat:@"a=%d&", [compsStart month]-1];
    url = [url stringByAppendingFormat:@"b=%d&", [compsStart day]];
    url = [url stringByAppendingFormat:@"c=%d&", [compsStart year]];
    
    url = [url stringByAppendingFormat:@"d=%d&", [compsEnd month]-1];
    url = [url stringByAppendingFormat:@"e=%d&", [compsEnd day]];
    url = [url stringByAppendingFormat:@"f=%d&", [compsEnd year]];
    url = [url stringByAppendingString:@"g=d&"];
    
    url = [url stringByAppendingString:@"ignore=.csv"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

-(void)notifyFinancesChanged
{
    if (delegate && [delegate respondsToSelector:@selector(dataPullerFinancialDataDidChange:)]) {
        [delegate performSelector:@selector(dataPullerFinancialDataDidChange:) withObject:self];
    }
}

#pragma mark -
#pragma mark Downloading of data

-(BOOL)staleData
{
    NSTimeInterval twelveHours = 60.0f * 60.f * 12.0f;

    return (0 >= self.financialData.count ||
            ![[self targetSymbol] isEqualToString:[self symbol]] ||
            [[self targetStartDate] timeIntervalSinceDate:[self startDate]] > twelveHours ||
            [[self targetEndDate] timeIntervalSinceDate:[self endDate]] > twelveHours);
}


-(void)fetchIfNeeded
{
    if ( self.loadingData ) return;
    
    //Check to see if cached data is stale
    if ([self staleData])
    {
        self.loadingData = YES;
        NSString *urlString = [self URL];
        NSLog(@"Fetching URL %@", urlString);
        NSURL *url = [NSURL URLWithString:urlString];
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
    NSLog(@"err = %@", [error localizedDescription]);
    self.connection = nil;
    if(delegate && [delegate respondsToSelector:@selector(dataPuller:downloadDidFailWithError:)])
    {
        [delegate performSelector:@selector(dataPuller:downloadDidFailWithError:) withObject:self withObject:error];
    }
}


-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.loadingData = NO;
    self.connection = nil;    
	
    NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    [self populateWithString:csv];
    
    self.receivedData = nil;
    [self writeToFile:[self pathForSymbol:self.symbol] atomically:YES];
}

-(void)populateWithString:(NSString *)csvString;
{
    NSArray *csvLines = [csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *newFinancials = [NSMutableArray arrayWithCapacity:[csvLines count]];
    NSDictionary *currentFinancial = nil;
    NSString *line = nil;
    
    self.overallHigh = [NSDecimalNumber notANumber];
    self.overallLow = [NSDecimalNumber notANumber];
    
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
    self.startDate = self.targetStartDate;
    self.endDate = self.targetEndDate;
    self.symbol = self.targetSymbol;
    
    [self setFinancialData:[NSArray arrayWithArray:newFinancials]];
}

@end
