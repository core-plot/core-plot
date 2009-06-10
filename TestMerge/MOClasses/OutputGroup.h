#import "_OutputGroup.h"
#import "TMOutputGroup.h"

@interface OutputGroup : _OutputGroup {}
// Custom logic goes here.

@property (readonly) NSString *referencePath;

- (NSString*)mostSpecificGTMUnitTestOutputPathInSet:(NSSet*)paths name:(NSString*)name extension:(NSString*)ext;

- (void)addReferencePathsObject:(NSString*)newPath;
@end
