
#import "GTMSenTestCase.h"
#import "GTMNSObject+UnitTesting.h"
#import "GTMCALayer+UnitTesting.h"
#import "GTMAppKit+UnitTesting.h"

@interface CPTestCase : GTMTestCase {

}

/**
 Encode base stae for a CALayer.
 
 Code taken from GTMCALayer+UnitTesting::gtm_unitTestEncodeState:. Unit tests
 may want to define categories on CALayers adding additional encoded state. These
 overriden gtm_unitTestEncodeState methods may call +[CPTestCase encodeCALayerStateForLayer:]
 to encode the standard state.
 
 @param layer CALayer whos state is to be encoded.
 @param inCoder State encoder. (must be GTMUnitTestingKeyedCoder)
 */
+ (void)encodeCALayerStateForLayer:(CALayer*)layer inCoder:(NSCoder*)inCoder;
@end
