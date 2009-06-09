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
    NSUInteger *volume;
    NSDecimalNumber *adjClose;
}

@property(nonatomic, retain)NSDate *date;
@property(nonatomic, retain)NSDecimalNumber *open;
@property(nonatomic, retain)NSDecimalNumber *high;
@property(nonatomic, retain)NSDecimalNumber *low;
@property(nonatomic, retain)NSDecimalNumber *close;
@property(nonatomic, retain)NSUInteger *volume;
@property(nonatomic, retain)NSDecimalNumber *adjClose;

//Designated init
- (id)initWithCSVLine:(NSString*)csvLine;

@end


@interface CPYahooDataPuller : NSObject {
    NSString *symbol;
    
    NSDate *startDate;
    NSDate *endDate;
    
@private
    NSString *csvString;
    NSArray *financialData; //consists of CPFinancialData objs
}

@property(nonatomic, copy)NSString *symbol;
@property(nonatomic, retain)NSDate *startDate;
@property(nonatomic, retain)NSDate *endDate;
@property(nonatomic, readonly)NSArray *financialData;

//Designated init.
- (id)initWithSymbol:(NSString*)aSymbol startDate:(NSDate*)aStartDate endDate:(NSDate*)anEndDate;

@end
