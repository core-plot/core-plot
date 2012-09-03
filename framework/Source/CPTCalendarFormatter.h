#import <Foundation/Foundation.h>

@interface CPTCalendarFormatter : NSNumberFormatter {
    @private
    NSDateFormatter *dateFormatter;
    NSDate *referenceDate;
    NSCalendar *referenceCalendar;
    NSCalendarUnit referenceCalendarUnit;
}

@property (nonatomic, readwrite, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, copy) NSDate *referenceDate;
@property (nonatomic, readwrite, copy) NSCalendar *referenceCalendar;
@property (nonatomic, readwrite, assign) NSCalendarUnit referenceCalendarUnit;

/// @name Initialization
/// @{
-(id)initWithDateFormatter:(NSDateFormatter *)aDateFormatter;
/// @}

@end
