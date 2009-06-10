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

-(id)initWithCGColor:(CGColorRef)cgColor;

-(CPColor *)colorWithAlphaComponent:(CGFloat)alpha;

@end
