
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPLineStyle;
@class CPFill;

@interface CPBorderedLayer : CPLayer {
	@private
	CPLineStyle *borderLineStyle;
    CPFill *fill;
	CGFloat cornerRadius;
	CGPathRef outerBorderPath;
	CGPathRef innerBorderPath;
	BOOL masksToBorder;
}

@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;
@property (nonatomic, readwrite, assign) CGFloat cornerRadius;
@property (nonatomic, readwrite, copy) CPFill *fill;
@property (nonatomic, readwrite, assign) BOOL masksToBorder;

@end
