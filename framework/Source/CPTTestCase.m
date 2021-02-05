#import "CPTTestCase.h"

@implementation CPTTestCase

-(nullable id)archiveRoundTrip:(nonnull id)object
{
    return [self archiveRoundTrip:object toClass:[object class]];
}

-(nullable id)archiveRoundTrip:(nonnull id)object toClass:(nonnull Class)archiveClass
{
    const BOOL secure = ![archiveClass isSubclassOfClass:[NSNumberFormatter class]];

    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:secure];

    [archiver encodeObject:object forKey:@"test"];
    [archiver finishEncoding];

    NSData *archiveData = [archiver encodedData];

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:archiveData error:NULL];

    unarchiver.requiresSecureCoding = secure;

    return [unarchiver decodeObjectOfClass:archiveClass forKey:@"test"];
}

@end
