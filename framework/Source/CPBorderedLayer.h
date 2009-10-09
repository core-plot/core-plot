
#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPMasking.h"

@class CPLineStyle;
@class CPFill;

@interface CPBorderedLayer : CPLayer <CPMasking> {
	CPLineStyle *borderLineStyle;
    CPFill *fill;
	CGFloat cornerRadius;
    CGPathRef maskingPath;
}

@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;
@property (nonatomic, readwrite, assign) CGFloat cornerRadius;
@property (nonatomic, readwrite, copy) CPFill *fill;

@end
