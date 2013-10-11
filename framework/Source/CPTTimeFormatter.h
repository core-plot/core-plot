/// @file

@interface CPTTimeFormatter : NSNumberFormatter

@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, copy) NSDate *referenceDate;

/// @name Initialization
/// @{
-(instancetype)initWithDateFormatter:(NSDateFormatter *)aDateFormatter;
/// @}

@end
