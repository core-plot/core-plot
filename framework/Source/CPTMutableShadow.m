#import "CPTMutableShadow.h"

/** @brief Mutable wrapper for various shadow drawing properties.
 *
 *  If you need to customize properties of a shadow, you should use this class rather than the
 *  immutable super class.
 *
 **/
@implementation CPTMutableShadow

/** @property shadowOffset
 *  @brief The horizontal and vertical offset values, specified using the width and height fields
 *	of the CGSize data type. The offsets are not affected by custom transformations. Positive values extend
 *	up and to the right. Default is <code>CGSizeZero</code>.
 **/
@dynamic shadowOffset;

/** @property shadowBlurRadius
 *  @brief The blur radius, measured in the default user coordinate space. A value of 0.0 (the default) indicates no blur,
 *	while larger values produce correspondingly larger blurring. This value must not be negative.
 **/
@dynamic shadowBlurRadius;

/** @property shadowColor
 *  @brief The shadow color. If <code>nil</code> (the default), the shadow will not be drawn.
 **/
@dynamic shadowColor;

@end
