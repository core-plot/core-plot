#import <Foundation/Foundation.h>
#import "CPAnnotationHostLayer.h"

@class CPLineStyle;
@class CPFill;

@interface CPBorderedLayer : CPAnnotationHostLayer {
@private
	CPLineStyle *borderLineStyle;
    CPFill *fill;
}

@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPFill *fill;

@end
