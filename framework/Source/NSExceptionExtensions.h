#import <Cocoa/Cocoa.h>


@interface NSException (CPExtensions)
+ (void)raiseGenericFormat:(NSString*)fmt,...;
@end
