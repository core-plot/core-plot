
#import "CPTestCase.h"
#import "GTMNSObject+UnitTesting.h"

@implementation CPTestCase
- (void)invokeTest {
    //set the saveTo directory to the $BUILT_PRODUCTS_DIR/CorePlot-UnitTest-Output
    NSString *saveToPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"BUILT_PRODUCTS_DIR"];
    if(saveToPath != nil) {
        saveToPath = [saveToPath stringByAppendingPathComponent:@"CorePlot-UnitTest-Output"];
        if(![[NSFileManager defaultManager] fileExistsAtPath:saveToPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:saveToPath attributes:nil];
        }
        
        [NSObject gtm_setUnitTestSaveToDirectory:saveToPath];
    }
    
    [super invokeTest];
}
@end
