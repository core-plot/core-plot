/// @file

#import <TargetConditionals.h>

#if TARGET_OS_OSX

#import <AppKit/AppKit.h>

typedef NSColor CPTNativeColor; ///< Platform-native color.
typedef NSImage CPTNativeImage; ///< Platform-native image format.
typedef NSEvent CPTNativeEvent; ///< Platform-native OS event.
typedef NSFont  CPTNativeFont;  ///< Platform-native font.

#else

#import <UIKit/UIKit.h>


typedef UIColor CPTNativeColor; ///< Platform-native color.
typedef UIImage CPTNativeImage; ///< Platform-native image format.
typedef UIEvent CPTNativeEvent; ///< Platform-native OS event.
typedef UIFont  CPTNativeFont;  ///< Platform-native font.

#endif
