#import "CPTLayer.h"

@class CPTBorderedLayer;

@interface CPTBorderLayer : CPTLayer {
    @private
    CPTBorderedLayer *maskedLayer;
}

@property (nonatomic, readwrite, retain) CPTBorderedLayer *maskedLayer;

@end
