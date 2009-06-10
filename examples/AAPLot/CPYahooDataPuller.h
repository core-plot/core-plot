//
//  CPYahooDataPuller.h
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright 2009 Sounds Broken inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPFinancialData : NSObject
{
    NSDate *date;
    NSDecimalNumber *open;
    NSDecimalNumber *high;
    NSDecimalNumber *low;
    NSDecimalNumber *close;
    NSUInteger volume;
    NSDecimalNumber *adjClose;
}

@property(nonatomic, retain)NSDate *date;
@property(nonatomic, retain)NSDecimalNumber *open;
@property(nonatomic, retain)NSDecimalNumber *high;
@property(nonatomic, retain)NSDecimalNumber *low;
@property(nonatomic, retain)NSDecimalNumber *close;
@property(nonatomic, assign)NSUInteger volume;
@property(nonatomic, retain)NSDecimalNumber *adjClose;

//Designated init
- (id)initWithCSVLine:(NSString*)csvLine;

@end

@interface CPYahooDataPuller : NSObject {
    NSString *symbol;
    
    NSDate *startDate;
    NSDate *endDate;
    id delegate;
@private
    NSString *csvString;
    NSArray *financialData; //consists of CPFinancialData objs

    //BOOL hostIsReachable;
    BOOL loadingData;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property(nonatomic, assign)id delegate;
@property(nonatomic, copy)NSString *symbol;
@property(nonatomic, retain)NSDate *startDate;
@property(nonatomic, retain)NSDate *endDate;
@property(nonatomic, readonly, retain)NSArray *financialData;

//Designated init.
- (id)initWithSymbol:(NSString*)aSymbol startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate;

@end

@protocol CPYahooDataPullerDelegate

@optional

-(void)dataPullerDidFinishFetch:(CPYahooDataPuller *)dp;

@end
