#import "CPTTestCase.h"

@class CPTLayer;

@interface CPTLayerTests : CPTTestCase {
    CPTLayer *layer;
    NSArray *positions;
}

@property (readwrite, retain) CPTLayer *layer;
@property (readwrite, retain) NSArray *positions;

@end
