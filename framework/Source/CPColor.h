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
+(CPColor *)colorWithGenericGray:(CGFloat)gray;

-(id)initWithCGColor:(CGColorRef)cgColor;

-(CPColor *)colorWithAlphaComponent:(CGFloat)alpha;

@end
