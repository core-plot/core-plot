#import "APFinancialData.h"
#import "APYahooDataPuller.h"

@interface APYahooDataPuller()

@property (nonatomic, readwrite, copy, nonnull) NSString *csvString;

@property (nonatomic, readwrite, strong, nonnull) NSDecimalNumber *overallHigh;
@property (nonatomic, readwrite, strong, nonnull) NSDecimalNumber *overallLow;
@property (nonatomic, readwrite, strong, nonnull) NSDecimalNumber *overallVolumeHigh;
@property (nonatomic, readwrite, strong, nonnull) NSDecimalNumber *overallVolumeLow;
@property (nonatomic, readwrite, strong, nonnull) CPTFinancialDataArray *financialData;

@property (nonatomic, readwrite, assign) BOOL loadingData;
@property (nonatomic, readwrite, strong, nullable) NSMutableData *receivedData;
@property (nonatomic, readwrite, strong, nullable) NSURLConnection *connection;

-(nonnull instancetype)initWithDictionary:(nonnull CPTDictionary *)aDict targetSymbol:(nonnull NSString *)aSymbol targetStartDate:(nonnull NSDate *)aStartDate targetEndDate:(nonnull NSDate *)anEndDate;

-(nonnull CPTDictionary *)plistRep;
-(BOOL)writeToFile:(nonnull NSString *)path atomically:(BOOL)flag;
-(void)fetch;
-(BOOL)shouldDownload;
-(nonnull NSString *)pathForSymbol:(nonnull NSString *)aSymbol;
-(nonnull NSString *)faultTolerantPathForSymbol:(nonnull NSString *)aSymbol;
-(nonnull CPTDictionary *)dictionaryForSymbol:(nonnull NSString *)aSymbol;
-(nonnull NSString *)URL;
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

-(void)setDelegate:(id<APYahooDataPullerDelegate>)aDelegate
{
    if ( delegate != aDelegate ) {
        delegate = aDelegate;
        if ( self.financialData.count > 0 ) {
            [self notifyPulledData]; // loads cached data onto UI
        }
    }
}

-(nonnull CPTDictionary *)plistRep
{
    CPTMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];

    rep[@"symbol"]            = self.symbol;
    rep[@"startDate"]         = self.startDate;
    rep[@"endDate"]           = self.endDate;
    rep[@"overallHigh"]       = self.overallHigh;
    rep[@"overallLow"]        = self.overallLow;
    rep[@"overallVolumeHigh"] = self.overallVolumeHigh;
    rep[@"overallVolumeLow"]  = self.overallVolumeLow;
    rep[@"financialData"]     = self.financialData;

    return [NSDictionary dictionaryWithDictionary:rep];
}

-(BOOL)writeToFile:(nonnull NSString *)path atomically:(BOOL)flag
{
    NSLog(@"writeToFile:%@", path);
    BOOL success = [[self plistRep] writeToFile:path atomically:flag];
    return success;
}

-(nonnull instancetype)initWithDictionary:(nonnull CPTDictionary *)aDict targetSymbol:(nonnull NSString *)aSymbol targetStartDate:(nonnull NSDate *)aStartDate targetEndDate:(nonnull NSDate *)anEndDate
{
    self = [super init];
    if ( self != nil ) {
        NSString *theSymbol = aDict[@"symbol"];
        self.symbol = theSymbol ? theSymbol : @"";
        NSDate *theStartDate = aDict[@"startDate"];
        self.startDate = theStartDate ? theStartDate : [NSDate date];
        NSDate *theEndDate = aDict[@"endDate"];
        self.endDate = theEndDate ? theEndDate : [NSDate date];
        NSNumber *low = aDict[@"overallLow"];
        self.overallLow = low ? [NSDecimalNumber decimalNumberWithDecimal:low.decimalValue] : [NSDecimalNumber notANumber];
        NSNumber *high = aDict[@"overallHigh"];
        self.overallHigh = high ? [NSDecimalNumber decimalNumberWithDecimal:high.decimalValue] : [NSDecimalNumber notANumber];
        NSNumber *volumeLow = aDict[@"overallVolumeLow"];
        self.overallVolumeLow = low ? [NSDecimalNumber decimalNumberWithDecimal:volumeLow.decimalValue] : [NSDecimalNumber notANumber];
        NSNumber *volumeHigh = aDict[@"overallVolumeHigh"];
        self.overallVolumeHigh = high ? [NSDecimalNumber decimalNumberWithDecimal:volumeHigh.decimalValue] : [NSDecimalNumber notANumber];
        CPTFinancialDataArray *dataArray = aDict[@"financialData"];
        self.financialData = dataArray ? dataArray : [[NSArray alloc] init];

        self.targetSymbol    = aSymbol;
        self.targetStartDate = aStartDate;
        self.targetEndDate   = anEndDate;
        self.csvString       = @"";

        [self performSelector:@selector(fetch) withObject:nil afterDelay:0.01];
    }
    return self;
}

-(nonnull NSString *)pathForSymbol:(nonnull NSString *)aSymbol
{
    CPTStringArray *paths        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *docPath            = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];

    return docPath;
}

-(nonnull NSString *)faultTolerantPathForSymbol:(nonnull NSString *)aSymbol
{
    NSString *docPath = [self pathForSymbol:aSymbol];

    if ( ![[NSFileManager defaultManager] fileExistsAtPath:docPath] ) {
        // if there isn't one in the user's documents directory, see if we ship with this data
        docPath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", aSymbol]];
    }
    return docPath;
}

// Always returns *something*
-(nonnull CPTDictionary *)dictionaryForSymbol:(nonnull NSString *)aSymbol
{
    NSString *path = [self faultTolerantPathForSymbol:aSymbol];

    CPTMutableDictionary *localPlistDict = [NSMutableDictionary dictionaryWithContentsOfFile:path];

    return localPlistDict;
}

-(nonnull instancetype)initWithTargetSymbol:(nonnull NSString *)aSymbol targetStartDate:(nonnull NSDate *)aStartDate targetEndDate:(nonnull NSDate *)anEndDate
{
    CPTDictionary *cachedDictionary = [self dictionaryForSymbol:aSymbol];

    if ( nil != cachedDictionary ) {
        return [self initWithDictionary:cachedDictionary targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
    }

    CPTMutableDictionary *rep = [NSMutableDictionary dictionaryWithCapacity:7];
    rep[@"symbol"]            = aSymbol;
    rep[@"startDate"]         = aStartDate;
    rep[@"endDate"]           = anEndDate;
    rep[@"overallHigh"]       = [NSDecimalNumber notANumber];
    rep[@"overallLow"]        = [NSDecimalNumber notANumber];
    rep[@"overallVolumeHigh"] = [NSDecimalNumber notANumber];
    rep[@"overallVolumeLow"]  = [NSDecimalNumber notANumber];
    rep[@"financialData"]     = @[];

    return [self initWithDictionary:rep targetSymbol:aSymbol targetStartDate:aStartDate targetEndDate:anEndDate];
}

-(nonnull instancetype)init
{
    NSTimeInterval secondsAgo = -timeIntervalForNumberOfWeeks(14.0); // 12 weeks ago
    NSDate *start             = [NSDate dateWithTimeIntervalSinceNow:secondsAgo];

    NSDate *end = [NSDate date];

    return [self initWithTargetSymbol:@"GOOG" targetStartDate:start targetEndDate:end];
}

-(void)dealloc
{
    delegate = nil;
}

// http://www.goldb.org/ystockquote.html
-(nonnull NSString *)URL
{
    NSUInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear;

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSString *url = [NSString stringWithFormat:@"https://ichart.yahoo.com/table.csv?s=%@&", self.targetSymbol];

    NSDate *tStartDate = self.targetStartDate;

    if ( tStartDate ) {
        NSDateComponents *compsStart = [gregorian components:unitFlags fromDate:tStartDate];

        url = [url stringByAppendingFormat:@"a=%ld&", (long)compsStart.month - 1];
        url = [url stringByAppendingFormat:@"b=%ld&", (long)compsStart.day];
        url = [url stringByAppendingFormat:@"c=%ld&", (long)compsStart.year];
    }

    NSDate *tEndDate = self.targetEndDate;
    if ( tEndDate ) {
        NSDateComponents *compsEnd = [gregorian components:unitFlags fromDate:tEndDate];

        url = [url stringByAppendingFormat:@"d=%ld&", (long)compsEnd.month - 1];
        url = [url stringByAppendingFormat:@"e=%ld&", (long)compsEnd.day];
        url = [url stringByAppendingFormat:@"f=%ld&", (long)compsEnd.year];
    }

    url = [url stringByAppendingString:@"g=d&"];

    url = [url stringByAppendingString:@"ignore=.csv"];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    return url;
}

-(void)notifyPulledData
{
    id<APYahooDataPullerDelegate> theDelegate = self.delegate;

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
            // TODO: Inform the user that the download could not be started
            self.loadingData = NO;
        }
    }
}

-(void)connection:(nonnull NSURLConnection *)connection didReceiveData:(nonnull NSData *)data
{
    // append the new data to the receivedData
    [self.receivedData appendData:data];
}

-(void)connection:(nonnull NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    self.receivedData.length = 0;
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

-(void)connection:(nonnull NSURLConnection *)connection didFailWithError:(nonnull NSError *)error
{
    self.loadingData  = NO;
    self.receivedData = nil;
    self.connection   = nil;
    NSLog(@"err = %@", error.localizedDescription);
    // TODO:report err
}

-(void)connectionDidFinishLoading:(nonnull NSURLConnection *)connection
{
    self.loadingData = NO;
    self.connection  = nil;

    NSMutableData *data = self.receivedData;
    if ( data ) {
        NSString *csv = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.csvString = csv;
    }
    else {
        self.csvString = @"";
    }

    self.receivedData = nil;
    [self parseCSVAndPopulate];

    // see if we need to write to file
    CPTDictionary *dictionaryForSymbol = [self dictionaryForSymbol:self.symbol];

    BOOL sameSymbol      = NO;
    NSString *dictSymbol = dictionaryForSymbol[@"symbol"];
    if ( dictSymbol ) {
        sameSymbol = [self.symbol isEqualToString:dictSymbol];
    }

    BOOL sameStart    = NO;
    NSDate *dictStart = dictionaryForSymbol[@"startDate"];
    if ( dictStart ) {
        sameStart = ([self.startDate compare:dictStart] != NSOrderedSame);
    }

    BOOL sameEnd    = NO;
    NSDate *dictEnd = dictionaryForSymbol[@"endDate"];
    if ( dictEnd ) {
        sameEnd = ([self.startDate compare:dictEnd] != NSOrderedSame);
    }

    if ( !sameSymbol || !sameStart || !sameEnd ) {
        [self writeToFile:[self pathForSymbol:self.symbol] atomically:YES];
    }
    else {
        NSLog(@"Not writing to file -- No Need, its data is fresh.");
    }
}

-(void)parseCSVAndPopulate
{
    CPTStringArray *csvLines = [self.csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    NSMutableArray<NSDictionary *> *newFinancials = [NSMutableArray arrayWithCapacity:csvLines.count];
    CPTDictionary *currentFinancial               = nil;
    NSString *line                                = nil;

    self.overallHigh       = [NSDecimalNumber notANumber];
    self.overallLow        = [NSDecimalNumber notANumber];
    self.overallVolumeHigh = [NSDecimalNumber notANumber];
    self.overallVolumeLow  = [NSDecimalNumber notANumber];

    for ( NSUInteger i = 1; i < csvLines.count - 1; i++ ) {
        line             = csvLines[i];
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

    self.financialData = [NSArray arrayWithArray:newFinancials];
    [self notifyPulledData];
}

@end
