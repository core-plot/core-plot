#import "CPTMutableLineStyle.h"

/** @brief Mutable wrapper for various line drawing properties.
 *
 *  If you need to customize properties of a line style, you should use this class rather than the
 *  immutable super class.
 *
 **/

@implementation CPTMutableLineStyle

/** @property lineCap
 *  @brief The style for the endpoints of lines drawn in a graphics context. Default is <code>kCGLineCapButt</code>.
 **/
@dynamic lineCap;

/** @property lineJoin
 *  @brief The style for the joins of connected lines in a graphics context. Default is <code>kCGLineJoinMiter</code>.
 **/
@dynamic lineJoin;

/** @property miterLimit
 *  @brief The miter limit for the joins of connected lines in a graphics context. Default is 10.0.
 **/
@dynamic miterLimit;

/** @property lineWidth
 *  @brief The line width for a graphics context. Default is 1.0.
 **/
@dynamic lineWidth;

/** @property dashPattern
 *  @brief The dash-and-space pattern for the line. Default is <code>nil</code>.
 **/
@dynamic dashPattern;

/** @property patternPhase
 *  @brief The starting phase of the line dash pattern. Default is 0.0.
 **/
@dynamic patternPhase;

/** @property lineColor
 *  @brief The current stroke color in a context. Default is solid black.
 **/
@dynamic lineColor;

@end
