

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLayer.h"

@interface CPTextLayer : CPLayer {
	NSString *text;
    NSString *fontName;
	CGFloat fontSize;
	CGColorRef fontColor;
}

@property(readwrite, copy, nonatomic) NSString *text;
@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, nonatomic) CGFloat fontSize;

// Cached colors
+(CGColorRef)blackColor; 

// Initialization and teardown
-(id)initWithString:(NSString *)newText fontSize:(float)newFontSize;

// Layout
-(void)sizeToFit;

@end
