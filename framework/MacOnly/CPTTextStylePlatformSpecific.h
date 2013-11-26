/// @file

/**
 *  @brief Enumeration of paragraph alignments.
 **/
typedef NS_ENUM (NSInteger, CPTTextAlignment) {
    CPTTextAlignmentLeft      = NSLeftTextAlignment,      ///< Left alignment.
    CPTTextAlignmentCenter    = NSCenterTextAlignment,    ///< Center alignment.
    CPTTextAlignmentRight     = NSRightTextAlignment,     ///< Right alignment.
    CPTTextAlignmentJustified = NSJustifiedTextAlignment, ///< Justified alignment.
    CPTTextAlignmentNatural   = NSNaturalTextAlignment    ///< Natural alignment of the text's script.
};
