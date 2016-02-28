#import "_CPTCatmullRomInterpolation.h"

#import "CPTDefinitions.h"
#import "tgmath.h"

/// @cond
@interface _CPTCatmullRomInterpolation()

+(void)interpolate:(nonnull CPTValueArray *)points forIndex:(NSUInteger)index withPointsPerSegment:(NSUInteger)pointsPerSegment andType:(CPTCatmullRomType)curveType intoPath:(CGMutablePathRef)dataLinePath;

CGFloat interpolate(const CGFloat *__nonnull const p, const CGFloat *__nonnull const time, CGFloat t);

@end

/// @endcond

#pragma mark -

/** @internal
 *  @brief Creates Catmull-Rom spline path for drawing curved scatter plot lines.
 *  @see See the [Wikipedia article](https://en.wikipedia.org/wiki/Centripetal_Catmull–Rom_spline) on Catmull-Rom splines for details.
 **/
@implementation _CPTCatmullRomInterpolation

/** @internal
 *  @brief Creates a Catmull-Rom spline path through the given view points in the given index range.
 *  @param viewPoints A c-style array of CGPoint structures representing view points.
 *  @param indexRange The range of indices into the @par{viewPoints} array to use when creating the spline path.
 *  @param granularity The number of smoothed points to interpolate between each view point.
 *  @return A Catmull-Rom spline path through the given view points in the given index range.
 **/
+(CGMutablePathRef)newPathForViewPoints:(const CGPoint *)viewPoints indexRange:(NSRange)indexRange withGranularity:(NSUInteger)granularity
{
    // Based on code from this post: http://stackoverflow.com/questions/9489736/catmull-rom-curve-with-no-cusps-and-no-self-intersections
    CGMutablePathRef dataLinePath = CGPathCreateMutable();

    if ( indexRange.length > 2 ) {
        if ( granularity < 3 ) {
            CGPoint viewPoint = viewPoints[indexRange.location];
            CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);

            for ( NSUInteger i = indexRange.location + 1; i < NSMaxRange(indexRange); i++ ) {
                viewPoint = viewPoints[i];
                CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
            }
        }
        else {
            CPTMutableValueArray *vertices = [[NSMutableArray alloc] init];

            NSUInteger rangeEnd = NSMaxRange(indexRange);

            for ( NSUInteger i = indexRange.location; i < rangeEnd; i++ ) {
                NSValue *pointValue = [[NSValue alloc] initWithBytes:&viewPoints[i] objCType:@encode(CGPoint)];
                [vertices addObject:pointValue];
            }

            // start point
            CGPoint pt1 = viewPoints[indexRange.location + 0];
            CGPoint pt2 = viewPoints[indexRange.location + 1];

            CGFloat dx = pt2.x - pt1.x;
            CGFloat dy = pt2.y - pt1.y;

            CGFloat x1 = pt1.x - dx;
            CGFloat y1 = pt1.y - dy;

            CGPoint start = CGPointMake(x1, y1);

            // end point
            pt2 = viewPoints[rangeEnd - 1];
            pt1 = viewPoints[rangeEnd - 2];

            dx = pt2.x - pt1.x;
            dy = pt2.y - pt1.y;

            x1 = pt2.x + dx;
            y1 = pt2.y + dy;

            CGPoint end = CGPointMake(x1, y1);

            NSValue *startPointValue = [[NSValue alloc] initWithBytes:&start objCType:@encode(CGPoint)];
            [vertices insertObject:startPointValue atIndex:0];

            NSValue *endPointValue = [[NSValue alloc] initWithBytes:&end objCType:@encode(CGPoint)];
            [vertices addObject:endPointValue];

            for ( NSUInteger i = 0; i < (vertices.count - 3); i++ ) {
                [self interpolate:vertices forIndex:i withPointsPerSegment:granularity andType:CPTCatmullRomTypeCentripetal intoPath:dataLinePath];
            }
        }
    }
    else if ( indexRange.length == 2 ) {
        // only two data points; just drawn a line between them
        CGPoint start = viewPoints[indexRange.location];
        CGPoint end   = viewPoints[NSMaxRange(indexRange) - 1];

        CGPathMoveToPoint(dataLinePath, NULL, start.x, start.y);
        CGPathAddLineToPoint(dataLinePath, NULL, end.x, end.y);
    }

    return dataLinePath;
}

/** @internal
 *  @brief Computes the interpolated spline value at the given control point.
 *  @param p A four (4) element array of data values.
 *  @param time A four (4) element array of knot positions.
 *  @param t The control parameter.
 *  @return The interpolated value.
 **/
CGFloat interpolate(const CGFloat *__nonnull const p, const CGFloat *__nonnull const time, CGFloat t)
{
    CGFloat L01  = p[0] * (time[1] - t) / (time[1] - time[0]) + p[1] * (t - time[0]) / (time[1] - time[0]);
    CGFloat L12  = p[1] * (time[2] - t) / (time[2] - time[1]) + p[2] * (t - time[1]) / (time[2] - time[1]);
    CGFloat L23  = p[2] * (time[3] - t) / (time[3] - time[2]) + p[3] * (t - time[2]) / (time[3] - time[2]);
    CGFloat L012 = L01 * (time[2] - t) / (time[2] - time[0]) + L12 * (t - time[0]) / (time[2] - time[0]);
    CGFloat L123 = L12 * (time[3] - t) / (time[3] - time[1]) + L23 * (t - time[1]) / (time[3] - time[1]);
    CGFloat C12  = L012 * (time[2] - t) / (time[2] - time[1]) + L123 * (t - time[1]) / (time[2] - time[1]);

    return C12;
}

/** @internal
 *  @brief
 *  @param points A c-style array of CGPoint structures representing view points.
 *  @param index The starting index of the group of control points.
 *  @param pointsPerSegment The number of smoothed points to interpolate between each view point.
 *  @param curveType The type of knot parameterization.
 *  @param dataLinePath The path to receive the spline segments.
 **/
+(void)interpolate:(CPTValueArray *)points forIndex:(NSUInteger)index withPointsPerSegment:(NSUInteger)pointsPerSegment andType:(CPTCatmullRomType)curveType intoPath:(CGMutablePathRef)dataLinePath
{
    CGFloat x[4];
    CGFloat y[4];
    CGFloat time[4];

    for ( NSUInteger i = 0; i < 4; i++ ) {
        CGPoint point;
        [points[index + i] getValue:&point];

        x[i] = point.x;
        y[i] = point.y;

        time[i] = i;
    }

    if ( curveType != CPTCatmullRomTypeUniform ) {
        CGFloat total = 0.0;

        for ( NSUInteger i = 1; i < 4; i++ ) {
            CGFloat dx = x[i] - x[i - 1];
            CGFloat dy = y[i] - y[i - 1];

            if ( curveType == CPTCatmullRomTypeCentripetal ) {
                total += pow(dx * dx + dy * dy, 0.25);
            }
            else {
                total += pow(dx * dx + dy * dy, 0.5);
            }
            time[i] = total;
        }
    }

    CGFloat tstart = time[1];
    CGFloat tend   = time[2];

    NSUInteger segments = pointsPerSegment - 1;

    if ( index == 0 ) {
        CGPoint point1;
        [points[index + 1] getValue:&point1];

        CGPathMoveToPoint(dataLinePath, NULL, point1.x, point1.y);
    }

    for ( NSUInteger i = 1; i < segments; i++ ) {
        CGFloat t = tstart + ( i * (tend - tstart) ) / segments;

        CGFloat xi = interpolate(x, time, t);
        CGFloat yi = interpolate(y, time, t);

        CGPathAddLineToPoint(dataLinePath, NULL, xi, yi);
    }

    CGPoint point2;
    [points[index + 2] getValue:&point2];

    CGPathAddLineToPoint(dataLinePath, NULL, point2.x, point2.y);
}

@end
