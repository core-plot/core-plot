
#import <Foundation/Foundation.h>

@class CPGraph;

/// @file

/// @name Theme Names
/// @{
extern NSString * const kCPDarkGradientTheme;
extern NSString * const kCPPlainWhiteTheme;
extern NSString * const kCPPlainBlackTheme;
extern NSString * const kCPStocksTheme;
/// @}

@interface CPTheme : NSObject {

}

+(CPTheme *)themeNamed:(NSString *)theme;
+(NSString *)name;

@end

@interface CPTheme(AbstractMethods)

-(CPGraph *)newGraph;

@end