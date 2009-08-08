
#import <Foundation/Foundation.h>

///	@file

@interface CPTimeFormatter : NSNumberFormatter {
	NSDateFormatter *dateFormatter;
    NSDate *referenceDate;
}

@property (nonatomic, readwrite, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, readwrite, copy) NSDate *referenceDate;

-(id)initWithDateFormatter:(NSDateFormatter *)aDateFormatter;

@end
