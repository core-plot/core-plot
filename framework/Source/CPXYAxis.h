

#import <Foundation/Foundation.h>
#import "CPAxis.h"
#import "CPDefinitions.h"

@interface CPXYAxis : CPAxis {
	@private
    NSDecimal constantCoordinateValue;	// TODO: NSDecimal instance variables in CALayers cause an unhandled property type encoding error
}

@property (nonatomic, readwrite) NSDecimal constantCoordinateValue;

@end
