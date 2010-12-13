#import <Foundation/Foundation.h>
#import "CPTextStyle.h"

@class CPColor;

@interface CPMutableTextStyle : CPTextStyle {

}

@property(readwrite, copy, nonatomic) NSString *fontName;
@property(readwrite, assign, nonatomic) CGFloat fontSize; 
@property(readwrite, copy, nonatomic) CPColor *color;

@end

