

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "CPLayer.h"

@class CPColor;

@interface CPTextLayer : CPLayer {
	NSString *text;
    NSString *fontName;
	CGFloat fontSize;
    CPColor *fontColor;
}

@property(readwrite, copy, nonatomic) NSString *text;
@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, nonatomic) CGFloat fontSize; 

// Initialization and teardown
+(NSString *)defaultFontName;

-(id)initWithString:(NSString *)newText fontSize:(float)newFontSize;

// Layout
-(void)sizeToFit;

@end
