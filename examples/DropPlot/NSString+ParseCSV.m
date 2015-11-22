#import "NSString+ParseCSV.h"

@implementation NSString(ParseCSV)

-(CPTStringArray *)arrayByParsingCSVLine
{
    BOOL isRemoveWhitespace = YES;

    CPTMutableStringArray *theArray       = [NSMutableArray array];
    CPTStringArray *theFields             = [self componentsSeparatedByString:@","];
    NSCharacterSet *quotedCharacterSet    = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    NSMutableString *theConcatenatedField = [NSMutableString string];

    BOOL inField = NO;

    for ( NSUInteger i = 0; i < theFields.count; i++ ) {
        NSString *theField = theFields[i];
        switch ( inField ) {
            case NO:
                if ( ([theField hasPrefix:@"\""] == YES) && ([theField hasSuffix:@"\""] == NO) ) {
                    inField = YES;
                    [theConcatenatedField appendString:theField];
                    [theConcatenatedField appendString:@","];
                }
                else {
                    if ( isRemoveWhitespace ) {
                        [theArray addObject:[theField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    }
                    else {
                        [theArray addObject:theField];
                    }
                }
                break;

            case YES:
                [theConcatenatedField appendString:theField];
                if ( [theField hasSuffix:@"\""] == YES ) {
                    NSString *field = [theConcatenatedField stringByTrimmingCharactersInSet:quotedCharacterSet];
                    if ( isRemoveWhitespace ) {
                        [theArray addObject:[field stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                    }
                    else {
                        [theArray addObject:field];
                    }
                    [theConcatenatedField setString:@""];
                    inField = NO;
                }
                else {
                    [theConcatenatedField appendString:@","];
                }
                break;
        }
    }
    return theArray;
    // TODO: Check this for potential memory leaks, not sure that the array is autoreleased
}

@end
