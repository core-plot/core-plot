
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPLineStyle;

@interface CPBorderedLayer : CPLayer {
	CPLineStyle *borderLineStyle;
	CGFloat cornerRadius;
}

@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;
@property (nonatomic, readwrite, assign) CGFloat cornerRadius;

@end
