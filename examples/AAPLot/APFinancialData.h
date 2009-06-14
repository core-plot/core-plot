
#import <Foundation/Foundation.h>

@interface APFinancialData : NSObject
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

-(id)initWithCSVLine:(NSString*)csvLine;

@end
