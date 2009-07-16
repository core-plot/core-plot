
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
	Class graphClass;
}

+(NSArray *)themeClasses;
+(CPTheme *)themeNamed:(NSString *)theme;
+(NSString *)name;

@property (nonatomic, assign) Class graphClass;

+(Class)requiredGraphSubclass;

@end

@interface CPTheme(AbstractMethods)

-(id)newGraph;

@end