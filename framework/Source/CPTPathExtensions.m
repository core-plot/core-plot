#import "CPTPathExtensions.h"

#import "CPTDefinitions.h"

/** @brief Creates a rectangular path with rounded corners.
 *
 *  @param rect The bounding rectangle for the path.
 *  @param cornerRadius The radius of the rounded corners.
 *  @return The new path. Caller is responsible for releasing this.
 **/
CGPathRef CreateRoundedRectPath(CGRect rect, CGFloat cornerRadius)
{
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGPathAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.

    CGFloat minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
    CGFloat minY = CGRectGetMinY(rect), midY = CGRectGetMidY(rect), maxY = CGRectGetMaxY(rect);

    CGMutablePathRef path = CGPathCreateMutable();

    if ( cornerRadius > CPTFloat(0.0) ) {
        cornerRadius = MIN( MIN( cornerRadius, rect.size.width * CPTFloat(0.5) ), rect.size.height * CPTFloat(0.5) );

        CGPathMoveToPoint(path, NULL, minX, midY);
        CGPathAddArcToPoint(path, NULL, minX, minY, midX, minY, cornerRadius);
        CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, midY, cornerRadius);
        CGPathAddArcToPoint(path, NULL, maxX, maxY, midX, maxY, cornerRadius);
        CGPathAddArcToPoint(path, NULL, minX, maxY, minX, midY, cornerRadius);
        CGPathCloseSubpath(path);
    }
    else {
        CGPathAddRect(path, NULL, rect);
    }

    return path;
}

/** @brief Adds a rectangular path with rounded corners to a graphics context.
 *
 *  @param context The graphics context.
 *  @param rect The bounding rectangle for the path.
 *  @param cornerRadius The radius of the rounded corners.
 **/
void AddRoundedRectPath(CGContextRef context, CGRect rect, CGFloat cornerRadius)
{
    CGPathRef path = CreateRoundedRectPath(rect, cornerRadius);

    CGContextAddPath(context, path);
    CGPathRelease(path);
}
