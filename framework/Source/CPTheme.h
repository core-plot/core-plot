
#import <Foundation/Foundation.h>

extern NSString * const kCPDarkGradientTheme;

@interface CPTheme : NSObject {

}

+(CPTheme *)themeNamed:(NSString *)theme;
+(NSString *)name;

-(id)newGraph;

@end
