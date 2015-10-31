#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>

@interface NSString(ParseCSV)

-(CPTStringArray *)arrayByParsingCSVLine;

@end
