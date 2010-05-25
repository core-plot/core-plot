#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPLineStyle;
@class CPFill;

@interface CPBorderedLayer : CPLayer {
@private
	CPLineStyle *borderLineStyle;
    CPFill *fill;
}

@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPFill *fill;

@end
