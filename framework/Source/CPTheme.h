
#import <Foundation/Foundation.h>

@class CPGraph;

@interface CPTheme : NSObject {

}

+(CPTheme *)themeNamed:(NSString *)theme;
+(NSString *)name;

-(id)newGraph;

@end
