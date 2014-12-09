@interface CPTCalendarFormatter : NSNumberFormatter

@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, copy) NSDate *referenceDate;
@property (nonatomic, readwrite, copy) NSCalendar *referenceCalendar;
@property (nonatomic, readwrite, assign) NSCalendarUnit referenceCalendarUnit;

/// @name Initialization
/// @{
-(instancetype)initWithDateFormatter:(NSDateFormatter *)aDateFormatter NS_DESIGNATED_INITIALIZER;
-(instancetype)initWithCoder:(NSCoder *)decoder NS_DESIGNATED_INITIALIZER;
/// @}

@end
