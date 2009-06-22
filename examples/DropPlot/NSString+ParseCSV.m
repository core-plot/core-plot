#import "NSString+ParseCSV.h"


@implementation NSString (ParseCSV)

- (NSArray *)arrayByParsingCSVLine; 
{
	BOOL isRemoveWhitespace = YES;
	NSMutableArray* theArray = [NSMutableArray array];
	NSArray* theFields = [self componentsSeparatedByString:@","];
	NSCharacterSet* quotedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
	BOOL inField = NO;
	NSMutableString* theConcatenatedField = [NSMutableString string];
	unsigned int i;
	for(i = 0; i < [theFields count]; i++) {
		NSString* theField = [theFields objectAtIndex:i];
		switch(inField) {
			case NO:
				if([theField hasPrefix:@"\""] == YES && [theField hasSuffix:@"\""] == NO) { 
					inField = YES;
					[theConcatenatedField appendString:theField];
					[theConcatenatedField appendString:@","];
				} else {
					if(isRemoveWhitespace) {
						[theArray addObject:[theField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					} else {
						[theArray addObject:theField];            
					}          
				}
				break;
			case YES:
				[theConcatenatedField appendString:theField];
				if([theField hasSuffix:@"\""] == YES) {
					NSString* theField = [theConcatenatedField stringByTrimmingCharactersInSet:quotedCharacterSet];
					if(isRemoveWhitespace) {
						[theArray addObject:[theField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
					} else {
						[theArray addObject:theField];            
					}          
					[theConcatenatedField setString:@""];
					inField = NO;
				} else {
					[theConcatenatedField appendString:@","];   
				}
				break;
		}
	}
	return theArray;
	// TODO: Check this for potential memory leaks, not sure that the array is autoreleased
}

@end
