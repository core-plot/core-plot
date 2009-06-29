#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CPColor : NSObject <NSCopying, NSCoding> {
    CGColorRef cgColor;
}

@property (nonatomic, readonly, assign) CGColorRef cgColor;

+(CPColor *)clearColor; 
+(CPColor *)whiteColor; 
+(CPColor *)blackColor; 
+(CPColor *)redColor;
+(CPColor *)greenColor;
+(CPColor *)blueColor;
+(CPColor *)darkGrayColor;
+(CPColor *)lightGrayColor;

+(CPColor *)colorWithCGColor:(CGColorRef)newCGColor;
+(CPColor *)colorWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+(CPColor *)colorWithGenericGray:(CGFloat)gray;

-(id)initWithCGColor:(CGColorRef)cgColor;
-(id)initWithComponentRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

-(CPColor *)colorWithAlphaComponent:(CGFloat)alpha;

@end
