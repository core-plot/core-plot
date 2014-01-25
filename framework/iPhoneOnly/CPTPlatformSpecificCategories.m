#import "CPTPlatformSpecificCategories.h"

#import "CPTPlatformSpecificFunctions.h"

#pragma mark CPTColor

@implementation CPTColor(CPTPlatformSpecificColorExtensions)

/** @property uiColor
 *  @brief Gets the color value as a UIColor.
 **/
@dynamic uiColor;

-(UIColor *)uiColor
{
    return [UIColor colorWithCGColor:self.cgColor];
}

@end

#pragma mark - CPTLayer

@implementation CPTLayer(CPTPlatformSpecificLayerExtensions)

/** @brief Gets an image of the layer contents.
 *  @return A native image representation of the layer content.
 **/
-(CPTNativeImage *)imageOfLayer
{
    CGSize boundsSize = self.bounds.size;

    if ( UIGraphicsBeginImageContextWithOptions ) {
        UIGraphicsBeginImageContextWithOptions(boundsSize, self.opaque, (CGFloat)0.0);
    }
    else {
        UIGraphicsBeginImageContext(boundsSize);
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetAllowsAntialiasing(context, true);

    CGContextTranslateCTM(context, (CGFloat)0.0, boundsSize.height);
    CGContextScaleCTM(context, (CGFloat)1.0, (CGFloat) - 1.0);

    [self layoutAndRenderInContext:context];
    CPTNativeImage *layerImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextSetAllowsAntialiasing(context, false);

    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();

    return layerImage;
}

@end

#pragma mark - NSNumber

@implementation NSNumber(CPTPlatformSpecificNumberExtensions)

/** @brief Returns a Boolean value that indicates whether the receiver is less than another given number.
 *  @param other The other number to compare to the receiver.
 *  @return @YES if the receiver is less than other, otherwise @NO.
 **/
-(BOOL)isLessThan:(NSNumber *)other
{
    return [self compare:other] == NSOrderedAscending;
}

/** @brief Returns a Boolean value that indicates whether the receiver is less than or equal to another given number.
 *  @param other The other number to compare to the receiver.
 *  @return @YES if the receiver is less than or equal to other, otherwise @NO.
 **/
-(BOOL)isLessThanOrEqualTo:(NSNumber *)other
{
    return [self compare:other] == NSOrderedSame || [self compare:other] == NSOrderedAscending;
}

/** @brief Returns a Boolean value that indicates whether the receiver is greater than another given number.
 *  @param other The other number to compare to the receiver.
 *  @return @YES if the receiver is greater than other, otherwise @NO.
 **/
-(BOOL)isGreaterThan:(NSNumber *)other
{
    return [self compare:other] == NSOrderedDescending;
}

/** @brief Returns a Boolean value that indicates whether the receiver is greater than or equal to another given number.
 *  @param other The other number to compare to the receiver.
 *  @return @YES if the receiver is greater than or equal to other, otherwise @NO.
 **/
-(BOOL)isGreaterThanOrEqualTo:(NSNumber *)other
{
    return [self compare:other] == NSOrderedSame || [self compare:other] == NSOrderedDescending;
}

@end

#pragma mark - NSAttributedString

@implementation NSAttributedString(CPTPlatformSpecificAttributedStringExtensions)

/** @brief Draws the styled text into the given graphics context.
 *  @param rect The bounding rectangle in which to draw the text.
 *  @param context The graphics context to draw into.
 *  @since Available on iOS 6.0 and later. Does nothing on earlier versions.
 **/
-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context
{
    if ( [self respondsToSelector:@selector(drawInRect:)] ) {
        CPTPushCGContext(context);

        [self drawWithRect:rect
                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine
                   context:nil];

        CPTPopCGContext();
    }
}

@end
