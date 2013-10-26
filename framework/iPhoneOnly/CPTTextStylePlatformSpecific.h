/// @file

/**
 *  @brief Enumeration of paragraph alignments.
 **/
typedef enum  _CPTTextAlignment {
    CPTTextAlignmentLeft      = NSTextAlignmentLeft,      ///< Left alignment.
    CPTTextAlignmentCenter    = NSTextAlignmentCenter,    ///< Center alignment.
    CPTTextAlignmentRight     = NSTextAlignmentRight,     ///< Right alignment.
    CPTTextAlignmentJustified = NSTextAlignmentJustified, ///< Justified alignment.
    CPTTextAlignmentNatural   = NSTextAlignmentNatural    ///< Natural alignment of the text's script.
}
CPTTextAlignment;

// @cond
// for iOS SDK compatibility
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
@interface NSString(CPTTextStylePlatformSpecificExtensions)

-(CGSize)sizeWithAttributes:(NSDictionary *)attrs;

@end
#else
#endif
#endif

/// @endcond
