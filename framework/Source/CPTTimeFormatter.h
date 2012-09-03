#import <Foundation/Foundation.h>

/// @file

@interface CPTTimeFormatter : NSNumberFormatter {
    @private
    NSDateFormatter *dateFormatter;
    NSDate *referenceDate;
}

@property (nonatomic, readwrite, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, copy) NSDate *referenceDate;

/// @name Initialization
/// @{
-(id)initWithDateFormatter:(NSDateFormatter *)aDateFormatter;
/// @}

@end
