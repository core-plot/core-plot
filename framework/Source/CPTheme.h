
#import <Foundation/Foundation.h>

extern NSString * const kCPDarkGradientTheme;
extern NSString * const kCPPlainWhiteTheme;
extern NSString * const kCPPlainBlackTheme;
extern NSString * const kCPStocksTheme;

@interface CPTheme : NSObject {

}

+(CPTheme *)themeNamed:(NSString *)theme;
+(NSString *)name;

-(id)newGraph;

@end
