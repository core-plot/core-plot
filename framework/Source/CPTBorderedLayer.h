#import "CPTAnnotationHostLayer.h"
#import <Foundation/Foundation.h>

@class CPTLineStyle;
@class CPTFill;

@interface CPTBorderedLayer : CPTAnnotationHostLayer {
	@private
	CPTLineStyle *borderLineStyle;
	CPTFill *fill;
}

@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;

@end
