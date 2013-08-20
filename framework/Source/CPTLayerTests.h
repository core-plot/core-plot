#import "CPTTestCase.h"

@class CPTLayer;

@interface CPTLayerTests : CPTTestCase {
    CPTLayer *layer;
    NSArray *positions;
}

@property (readwrite, strong) CPTLayer *layer;
@property (readwrite, strong) NSArray *positions;

@end
