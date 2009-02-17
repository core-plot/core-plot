
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

+ (void)encodeCALayerStateForLayer:(CALayer*)layer inCoder:(NSCoder*)inCoder {
    [inCoder encodeBool:[layer isHidden] forKey:@"LayerIsHidden"];
    [inCoder encodeBool:[layer isDoubleSided] forKey:@"LayerIsDoublesided"];
    [inCoder encodeBool:[layer isOpaque] forKey:@"LayerIsOpaque"];
    [inCoder encodeFloat:[layer opacity] forKey:@"LayerOpacity"];
    // TODO: There is a ton more we can add here. What are we interested in?
    if ([layer gtm_shouldEncodeStateForSublayers]) {
        int i = 0;
        for (CALayer *subLayer in [layer sublayers]) {
            [inCoder encodeObject:subLayer 
                           forKey:[NSString stringWithFormat:@"CALayerSubLayer %d", i]];
            i = i + 1;
        }
    }
}
@end
