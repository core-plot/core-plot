/// @file

#import <TargetConditionals.h>

#if TARGET_OS_OSX

#pragma mark macOS
#pragma mark -

#import <AppKit/AppKit.h>

/**
 *  @brief Enumeration of paragraph alignments.
 **/
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= 101200)
typedef NS_ENUM (NSInteger, CPTTextAlignment) {
    CPTTextAlignmentLeft      = NSTextAlignmentLeft,      ///< Left alignment.
    CPTTextAlignmentCenter    = NSTextAlignmentCenter,    ///< Center alignment.
    CPTTextAlignmentRight     = NSTextAlignmentRight,     ///< Right alignment.
    CPTTextAlignmentJustified = NSTextAlignmentJustified, ///< Justified alignment.
    CPTTextAlignmentNatural   = NSTextAlignmentNatural    ///< Natural alignment of the text's script.
};
#else
typedef NS_ENUM (NSInteger, CPTTextAlignment) {
    CPTTextAlignmentLeft      = NSLeftTextAlignment,      ///< Left alignment.
    CPTTextAlignmentCenter    = NSCenterTextAlignment,    ///< Center alignment.
    CPTTextAlignmentRight     = NSRightTextAlignment,     ///< Right alignment.
    CPTTextAlignmentJustified = NSJustifiedTextAlignment, ///< Justified alignment.
    CPTTextAlignmentNatural   = NSNaturalTextAlignment    ///< Natural alignment of the text's script.
};
#endif

#else

#pragma mark - iOS, tvOS, Mac Catalyst
#pragma mark -

#import <UIKit/UIKit.h>

/// @file

/**
 *  @brief Enumeration of paragraph alignments.
 **/
typedef NS_ENUM (NSInteger, CPTTextAlignment) {
    CPTTextAlignmentLeft      = NSTextAlignmentLeft,      ///< Left alignment.
    CPTTextAlignmentCenter    = NSTextAlignmentCenter,    ///< Center alignment.
    CPTTextAlignmentRight     = NSTextAlignmentRight,     ///< Right alignment.
    CPTTextAlignmentJustified = NSTextAlignmentJustified, ///< Justified alignment.
    CPTTextAlignmentNatural   = NSTextAlignmentNatural    ///< Natural alignment of the text's script.
};

#endif
