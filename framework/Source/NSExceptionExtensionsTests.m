#import "NSExceptionExtensionsTests.h"
#import "NSExceptionExtensions.h"

@implementation NSExceptionExtensionsTests

- (void)testRaiseGenericFormatRaisesExceptionWithFormat
{
    NSString *expectedReason = @"reason %d";
    STAssertThrowsSpecificNamed([NSException raiseGenericFormat:@""], NSException, NSGenericException, @"");
    
    @try {
        [NSException raiseGenericFormat:expectedReason, 2];
    }
    @catch (NSException * e) {
		STAssertEqualObjects([e reason], @"reason 2", @"");
    }
}

@end
