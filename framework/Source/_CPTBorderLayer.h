#import "CPTLayer.h"

@class CPTBorderedLayer;

@interface CPTBorderLayer : CPTLayer {
    @private
    CPTBorderedLayer *maskedLayer;
}

@property (nonatomic, readwrite, strong) CPTBorderedLayer *maskedLayer;

@end
