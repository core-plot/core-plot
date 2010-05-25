
#import "CPGradientTests.h"
#import "CPGradient.h"

#import "GTMGarbageCollection.h"
#import "GTMNSObject+UnitTesting.h"

@interface CPGradient (UnitTesting)

- (CGImageRef)gtm_unitTestImage;

@end

@implementation CPGradient (UnitTesting)

- (CGImageRef)gtm_unitTestImage 
{
    CGFloat edgeLength = 200; //arbitrary edge size
    CGSize contextSize = CGSizeMake(edgeLength, edgeLength);
    CGContextRef context = GTMCreateUnitTestBitmapContextOfSizeWithData(contextSize, NULL);
    _GTMDevAssert(context, @"Couldn't create context");
    
    [self drawSwatchInRect:CGRectMake(0, 0, edgeLength, edgeLength) inContext:context];
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    CFRelease(context);
    
    return (CGImageRef)GTMCFAutorelease(imageRef);
}

@end



@implementation CPGradientTests
- (void)testDrawSwatchRendersCorrectlyForFactoryGradients
{
    NSArray *factoryMethods = [NSArray arrayWithObjects:
                               @"aquaSelectedGradient",
                               @"aquaNormalGradient",
                               @"aquaPressedGradient",
                               @"unifiedSelectedGradient",
                               @"unifiedNormalGradient",
                               @"unifiedPressedGradient",
                               @"unifiedDarkGradient",
                               @"sourceListSelectedGradient",
                               @"sourceListUnselectedGradient",
                               @"rainbowGradient",
                               @"hydrogenSpectrumGradient",
                               nil];
    
    for(NSString *factoryMethod in factoryMethods) {
        CPGradient *gradient = [[CPGradient class] performSelector:NSSelectorFromString(factoryMethod)];
        NSString *imageName =  [NSString stringWithFormat:@"CPGradientTests-testDrawSwatchRendersCorrectlyForFactoryGradients-%@", factoryMethod];
        GTMAssertObjectImageEqualToImageNamed(gradient, imageName, @"");
    }
    
}

- (void)testFillPathRendersCorrectly 
{
    //STFail(@"Implement test.");
}
@end
