#import <Foundation/Foundation.h>

@interface NSException(CPExtensions)

+(void)raiseGenericFormat:(NSString*)fmt,...;

@end
