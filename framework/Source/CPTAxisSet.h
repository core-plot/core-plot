#import "CPTLayer.h"
#import <Foundation/Foundation.h>

@class CPTLineStyle;

@interface CPTAxisSet : CPTLayer {
	@private
	NSArray *axes;
	CPTLineStyle *borderLineStyle;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;

///	@name Labels
///	@{
-(void)relabelAxes;
///	@}

@end
