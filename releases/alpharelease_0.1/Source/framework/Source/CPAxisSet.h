#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPLineStyle;

@interface CPAxisSet : CPLayer {
	@private
    NSArray *axes;
	CPLineStyle *borderLineStyle;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, copy) CPLineStyle *borderLineStyle;

-(void)relabelAxes;

@end
