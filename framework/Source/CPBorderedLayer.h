
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPLineStyle;
@class CPFill;

@interface CPBorderedLayer : CPLayer {
	CPLineStyle *borderLineStyle;
    CPFill *fill;
	CGFloat cornerRadius;
}

@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;
@property (nonatomic, readwrite, assign) CGFloat cornerRadius;
@property (nonatomic, readwrite, copy) CPFill *fill;

@end
