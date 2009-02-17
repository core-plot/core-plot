
#import "CPTestCase.h"
#import "GTMNSObject+UnitTesting.h"

@implementation CPTestCase
- (void)invokeTest {
//    //set the saveTo directory to the $BUILT_PRODUCTS_DIR/CorePlot-UnitTest-Output
//    NSString *saveToPath = [[[NSProcessInfo processInfo] environment] objectForKey:@"BUILT_PRODUCTS_DIRECTORY"];
//    if(saveToPath != nil) {
//        saveToPath = [saveToPath stringByAppendingPathComponent:@"CorePlot-UnitTest-Output"];
//        [self gtm_setUnitTestSaveToDirectory:saveToPath];
//    }
    
    [super invokeTest];
}
@end
