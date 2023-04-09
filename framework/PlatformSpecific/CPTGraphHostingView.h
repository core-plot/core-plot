#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTDefinitions.h>
#else
#import "CPTDefinitions.h"
#endif

@class CPTGraph;

#if TARGET_OS_OSX

#pragma mark macOS
#pragma mark -

@interface CPTGraphHostingView : NSView<NSCoding, NSSecureCoding>

/// @name Hosted Graph
/// @{
@property (nonatomic, readwrite, strong, nullable) CPTGraph *hostedGraph;
/// @}

/// @name Printing
/// @{
@property (nonatomic, readwrite, assign) NSRect printRect;
/// @}

/// @name Cursors
/// @{
@property (nonatomic, readwrite, strong, nullable) NSCursor *closedHandCursor;
@property (nonatomic, readwrite, strong, nullable) NSCursor *openHandCursor;
/// @}

/// @name User Interaction
/// @{
@property (nonatomic, readwrite, assign) BOOL allowPinchScaling;
/// @}

@end

#else

#pragma mark - iOS, tvOS, Mac Catalyst
#pragma mark -

@interface CPTGraphHostingView : UIView<NSCoding, NSSecureCoding>

/// @name Hosted Graph
/// @{
@property (nonatomic, readwrite, strong, nullable) CPTGraph *hostedGraph;
/// @}

/// @name Layer Structure
/// @{
@property (nonatomic, readwrite, assign) BOOL collapsesLayers;
/// @}

/// @name User Interaction
/// @{
@property (nonatomic, readwrite, assign) BOOL allowPinchScaling;
/// @}

@end

#endif
