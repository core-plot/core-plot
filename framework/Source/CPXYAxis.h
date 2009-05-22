

#import <Foundation/Foundation.h>
#import "CPAxis.h"
#import "CPDefinitions.h"

/** 
 * Class responsible for drawing straight axis is a plotspace
 **/
@interface CPXYAxis : CPAxis {
    NSDecimal constantCoordinateValue; /*! The axis is drawn at this value on the other axis.*/
}

@property (nonatomic, readwrite, assign) NSDecimal constantCoordinateValue;

@end
