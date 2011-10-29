#import "CPTTimeFormatter.h"
#import "CPTTimeFormatterTests.h"

@implementation CPTTimeFormatterTests

#pragma mark -
#pragma mark NSCoding

-(void)testKeyedArchivingRoundTrip
{
	NSDate *refDate				   = [NSDate dateWithNaturalLanguageString:@"12:00 Oct 29, 2009"];
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];

	dateFormatter.dateStyle = kCFDateFormatterShortStyle;

	CPTTimeFormatter *timeFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
	timeFormatter.referenceDate = refDate;

	CPTTimeFormatter *newTimeFormatter = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:timeFormatter]];

	STAssertEqualObjects(timeFormatter.dateFormatter.dateFormat, newTimeFormatter.dateFormatter.dateFormat, @"Date formatter not equal");
	STAssertEqualObjects(timeFormatter.referenceDate, newTimeFormatter.referenceDate, @"Reference date not equal");
}

@end
