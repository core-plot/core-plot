#import <Foundation/Foundation.h>
#import "CPTLayer.h"

@class CPTLineStyle;

@interface CPTAxisSet : CPTLayer {
	@private
    NSArray *axes;
	CPTLineStyle *borderLineStyle;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;

-(void)relabelAxes;

@end
