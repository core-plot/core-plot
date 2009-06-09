//
//  CPYahooDataPuller.m
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright 2009 Sounds Broken inc.. All rights reserved.
//

#import "CPYahooDataPuller.h"


@implementation CPFinancialData

- (void)dealloc
{
    [date release];
    [open release];
    [high release];
    [low release];
    [close release];
    [volume release];
    [adjClose release];
    
    date = nil;
    open = nil;
    high = nil;
    low = nil;
    close = nil;
    volume = nil;
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
@property(nonatomic, retain)NSArray *financialData; 

@end

@interface CPYahooDataPuller (PrivateAPI)

@end

@implementation CPYahooDataPuller


- (void)dealloc
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
    [super dealloc];
}

@synthesize symbol;
@synthesize startDate;
@synthesize endDate;
@synthesize csvString;
@synthesize financialData; //consists of CPFinancialData objs

@end
