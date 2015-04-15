#import "APFinancialData.h"
#import "APYahooDataPuller.h"

@interface APYahooDataPuller()

@property (nonatomic, readwrite, copy) NSString *csvString;

@property (nonatomic, readwrite, strong) NSDecimalNumber *overallHigh;
@property (nonatomic, readwrite, strong) NSDecimalNumber *overallLow;
@property (nonatomic, readwrite, strong) NSDecimalNumber *overallVolumeHigh;
@property (nonatomic, readwrite, strong) NSDecimalNumber *overallVolumeLow;
@property (nonatomic, readwrite, strong) NSArray *financialData;

@property (nonatomic, readwrite, assign) BOOL loadingData;
@property (nonatomic, readwrite, strong) NSMutableData *receivedData;
@property (nonatomic, readwrite, strong) NSURLConnection *connection;

-(void)fetch;
-(NSString *)URL;
-(void)notifyPulledData;
-(void)parseCSVAndPopulate;

NSTimeInterval timeIntervalForNumberOfWeeks(double numberOfWeeks);

@end

#pragma mark -

NSTimeInterval timeIntervalForNumberOfWeeks(double numberOfWeeks)
{
    NSTimeInterval seconds = fabs(60.0 * 60.0 * 24.0 * 7.0 * numberOfWeeks);

    return seconds;
}

@implementation APYahooDataPuller

@synthesize symbol;
@synthesize startDate;
@synthesize endDate;
@synthesize targetStartDate;
@synthesize targetEndDate;
@synthesize targetSymbol;
@synthesize overallLow;
@synthesize overallHigh;
@synthesize overallVolumeHigh;
@synthesize overallVolumeLow;
@synthesize csvString;
@synthesize financialData;

@synthesize receivedData;
@synthesize connection;
@synthesize loadingData;

@synthesize delegate;

-(void)setDelegate:(id)aDelegate
{
    if ( delegate != aDelegate ) {
        delegate = aDelegate;
        if ( self.financialData.count > 0 ) {
            [self notifyPulledData]; //loads cached data onto UI
        }
    }
}

-(NSDictionary *)plistRep
{
    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];

    rep[@"symbol"]            = [self symbol];
    rep[@"startDate"]         = [self startDate];
    rep[@"endDate"]           = [self endDate];
    rep[@"overallHigh"]       = [self overallHigh];
    rep[@"overallLow"]        = [self overallLow];
    rep[@"overallVolumeHigh"] = [self overallVolumeHigh];
    rep[@"overallVolumeLow"]  = [self overallVolumeLow];
    rep[@"financalData"]      = [self financialData];
    return [NSDictionary dictionaryWithDictionary:rep];
}

-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag
{
    NSLog(@"writeToFile:%@", path);
    BOOL success = [[self plistRep] writeToFile:path atomically:flag];
    return success;
}

-(id)initWithDictionary:(NSDictionary *)aDict targetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate
{
    self = [super init];
    if ( self != nil ) {
        self.symbol        = aDict[@"symbol"];
        self.startDate     = aDict[@"startDate"];
        self.overallLow    = [NSDecimalNumber decimalNumberWithDecimal:[aDict[@"overallLow"] decimalValue]];
        self.overallHigh   = [NSDecimalNumber decimalNumberWithDecimal:[aDict[@"overallHigh"] decimalValue]];
        self.endDate       = aDict[@"endDate"];
        self.financialData = aDict[@"financalData"];

        self.targetSymbol    = aSymbol;
        self.targetStartDate = aStartDate;
        self.targetEndDate   = anEndDate;
        self.csvString       = @"";
        [self performSelector:@selector(fetch) withObject:nil afterDelay:0.01];
    }
    return self;
}

-(NSString *)pathForSymbol:(NSString *)aSymbol
{
    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *docPath            = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];

    return docPath;
}

-(NSString *)faultTolerantPathForSymbol:(NSString *)aSymbol
{
    NSString *docPath = [self pathForSymbol:aSymbol];

    if ( ![[NSFileManager defaultManager] fileExistsAtPath:docPath] ) {
        //if there isn't one in the user's documents directory, see if we ship with this data
        docPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    }
    return docPath;
}

//Always returns *something*
-(NSDictionary *)dictionaryForSymbol:(NSString *)aSymbol
{
    NSString *path                      = [self faultTolerantPathForSymbol:aSymbol];
    NSMutableDictionary *localPlistDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    return localPlistDict;
}

-(id)initWithTargetSymbol:(NSString *)aSymbol targetStartDate:(NSDate *)aStartDate targetEndDate:(NSDate *)anEndDate
{
    NSDictionary *cachedDictionary = [self dictionaryForSymbol:aSymbol];

    if ( nil != cachedDictionary ) {
        return [self initWithDictionary:cachedDictionary targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
    }

    NSMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];
    rep[@"symbol"]       = aSymbol;
    rep[@"startDate"]    = aStartDate;
    rep[@"endDate"]      = anEndDate;
    rep[@"overallHigh"]  = [NSDecimalNumber notANumber];
    rep[@"overallLow"]   = [NSDecimalNumber notANumber];
    rep[@"financalData"] = @[];
    return [self initWithDictionary:rep targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
}

-(id)init
{
    NSTimeInterval secondsAgo = -timeIntervalForNumberOfWeeks(14.0); //12 weeks ago
    NSDate *start             = [NSDate dateWithTimeIntervalSinceNow:secondsAgo];

    NSDate *end = [NSDate date];

    return [self initWithTargetSymbol:@"GOOG" targetStartDate:start targetEndDate:end];
}

-(void)dealloc
{
    delegate = nil;
}

// http://www.goldb.org/ystockquote.html
-(NSString *)URL
{
    unsigned int unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear;

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *compsStart = [gregorian components:unitFlags fromDate:self.targetStartDate];
    NSDateComponents *compsEnd   = [gregorian components:unitFlags fromDate:self.targetEndDate];

    NSString *url = [NSString stringWithFormat:@"http://ichart.yahoo.com/table.csv?s=%@&", [self targetSymbol]];

    url = [url stringByAppendingFormat:@"a=%ld&", (long)[compsStart month] - 1];
    url = [url stringByAppendingFormat:@"b=%ld&", (long)[compsStart day]];
    url = [url stringByAppendingFormat:@"c=%ld&", (long)[compsStart year]];

    url = [url stringByAppendingFormat:@"d=%ld&", (long)[compsEnd month] - 1];
    url = [url stringByAppendingFormat:@"e=%ld&", (long)[compsEnd day]];
    url = [url stringByAppendingFormat:@"f=%ld&", (long)[compsEnd year]];
    url = [url stringByAppendingString:@"g=d&"];

    url = [url stringByAppendingString:@"ignore=.csv"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

-(void)notifyPulledData
{
    id theDelegate = self.delegate;

    if ( [theDelegate respondsToSelector:@selector(dataPullerDidFinishFetch:)] ) {
        [theDelegate performSelector:@selector(dataPullerDidFinishFetch:) withObject:self];
    }
}

#pragma mark -
#pragma mark Downloading of data

-(BOOL)shouldDownload
{
    BOOL shouldDownload = YES;

    return shouldDownload;
}

-(void)fetch
{
    if ( self.loadingData ) {
        return;
    }

    if ( [self shouldDownload] ) {
        self.loadingData = YES;
        NSString *urlString = [self URL];
        NSLog(@"URL = %@", urlString);
        NSURL *url               = [NSURL URLWithString:urlString];
        NSURLRequest *theRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];

        // create the connection with the request
        // and start loading the data
        self.connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        if ( self.connection ) {
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
    if ( self.loadingData ) {
        [self.connection cancel];
        self.loadingData = NO;

        self.receivedData = nil;
        self.connection   = nil;
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.loadingData  = NO;
    self.receivedData = nil;
    self.connection   = nil;
    NSLog(@"err = %@", [error localizedDescription]);
    //TODO:report err
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.loadingData = NO;
    self.connection  = nil;

    NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    self.csvString = csv;

    self.receivedData = nil;
    [self parseCSVAndPopulate];

    //see if we need to write to file
    NSDictionary *dictionaryForSymbol = [self dictionaryForSymbol:self.symbol];
    if ( ![[self symbol] isEqualToString:dictionaryForSymbol[@"symbol"]] ||
         ([[self startDate] compare:dictionaryForSymbol[@"startDate"]] != NSOrderedSame) ||
         ([[self endDate] compare:dictionaryForSymbol[@"endDate"]] != NSOrderedSame) ) {
        [self writeToFile:[self pathForSymbol:self.symbol] atomically:YES];
    }
    else {
        NSLog(@"Not writing to file -- No Need, its data is fresh.");
    }
}

-(void)parseCSVAndPopulate
{
    NSArray *csvLines              = [self.csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSMutableArray *newFinancials  = [NSMutableArray arrayWithCapacity:[csvLines count]];
    NSDictionary *currentFinancial = nil;
    NSString *line                 = nil;

    self.overallHigh       = [NSDecimalNumber notANumber];
    self.overallLow        = [NSDecimalNumber notANumber];
    self.overallVolumeHigh = [NSDecimalNumber notANumber];
    self.overallVolumeLow  = [NSDecimalNumber notANumber];

    for ( NSUInteger i = 1; i < [csvLines count] - 1; i++ ) {
        line             = (NSString *)csvLines[i];
        currentFinancial = [NSDictionary dictionaryWithCSVLine:line];
        [newFinancials addObject:currentFinancial];

        NSDecimalNumber *high   = currentFinancial[@"high"];
        NSDecimalNumber *low    = currentFinancial[@"low"];
        NSDecimalNumber *volume = currentFinancial[@"volume"];

        if ( [self.overallHigh isEqual:[NSDecimalNumber notANumber]] ) {
            self.overallHigh = high;
        }

        if ( [self.overallLow isEqual:[NSDecimalNumber notANumber]] ) {
            self.overallLow = low;
        }

        if ( [low compare:self.overallLow] == NSOrderedAscending ) {
            self.overallLow = low;
        }
        if ( [high compare:self.overallHigh] == NSOrderedDescending ) {
            self.overallHigh = high;
        }

        if ( [self.overallVolumeHigh isEqual:[NSDecimalNumber notANumber]] ) {
            self.overallVolumeHigh = volume;
        }

        if ( [self.overallVolumeLow isEqual:[NSDecimalNumber notANumber]] ) {
            self.overallVolumeLow = volume;
        }

        if ( [volume compare:self.overallVolumeLow] == NSOrderedAscending ) {
            self.overallVolumeLow = volume;
        }

        if ( [volume compare:self.overallVolumeHigh] == NSOrderedDescending ) {
            self.overallVolumeHigh = volume;
        }
    }
    self.startDate = self.targetStartDate;
    self.endDate   = self.targetEndDate;
    self.symbol    = self.targetSymbol;

    [self setFinancialData:[NSArray arrayWithArray:newFinancials]];
    [self notifyPulledData];
}

@end
