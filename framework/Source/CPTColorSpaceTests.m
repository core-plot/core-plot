#import "CPTColorSpace.h"
#import "CPTColorSpaceTests.h"

@implementation CPTColorSpaceTests

#pragma mark -
#pragma mark NSCoding

-(void)testKeyedArchivingRoundTrip
{
	CPTColorSpace *colorSpace = [CPTColorSpace genericRGBSpace];

	CPTColorSpace *newColorSpace = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:colorSpace]];

	CFDataRef iccProfile	= CGColorSpaceCopyICCProfile(colorSpace.cgColorSpace);
	CFDataRef newIccProfile = CGColorSpaceCopyICCProfile(newColorSpace.cgColorSpace);

	STAssertTrue([(NSData *) iccProfile isEqualToData:(NSData *)newIccProfile], @"Color spaces not equal");

	CFRelease(iccProfile);
	CFRelease(newIccProfile);
}

@end
