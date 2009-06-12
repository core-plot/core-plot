
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class CPColor;

@interface CPTextStyle : NSObject <NSCopying> {
    NSString *fontName;
	CGFloat fontSize;
    CPColor *color;
}

@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, assign, nonatomic) CGFloat fontSize; 
@property(readwrite, copy, nonatomic) CPColor *color;

@end

@interface NSString (CPTextStyleExtensions)

-(CGSize)sizeWithStyle:(CPTextStyle *)style;

-(void)drawAtPoint:(CGPoint)point withStyle:(CPTextStyle *)style inContext:(CGContextRef)context;

@end