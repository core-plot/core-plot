

#import "CPMutableLineStyle.h"


/** @brief Mutable wrapper for various line drawing properties.
 *
 *  If you need to customize properties of a line, you should use this class rather than the 
 *  immutable super class.
 *
 **/

@implementation CPMutableLineStyle

/** @property lineCap
 *  @brief The style for the endpoints of lines drawn in a graphics context.
 **/
@dynamic lineCap;

/** @property lineJoin
 *  @brief The style for the joins of connected lines in a graphics context.
 **/
@dynamic lineJoin;

/** @property miterLimit
 *  @brief The miter limit for the joins of connected lines in a graphics context.
 **/
@dynamic miterLimit;

/** @property lineWidth
 *  @brief The line width for a graphics context.
 **/
@dynamic lineWidth;

/** @property dashPattern
 *  @brief The dash-and-space pattern for the line.
 **/
@dynamic dashPattern;

/** @property patternPhase
 *  @brief The starting phase of the line dash pattern.
 **/
@dynamic patternPhase;

/** @property lineColor
 *  @brief The current stroke color in a context.
 **/
@dynamic lineColor;

@end
