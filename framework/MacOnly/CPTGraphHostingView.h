#import <Cocoa/Cocoa.h>

@class CPTGraph;

@interface CPTGraphHostingView : NSView

/// @name Hosted graph
/// @{
@property (nonatomic, readwrite, strong) CPTGraph *hostedGraph;
/// @}

/// @name Printing
/// @{
@property (nonatomic, readwrite, assign) NSRect printRect;
/// @}

/// @name Cursors
/// @{
@property (nonatomic, readwrite, strong) NSCursor *closedHandCursor;
@property (nonatomic, readwrite, strong) NSCursor *openHandCursor;
/// @}

/// @name User Interaction
/// @{
@property (nonatomic, readwrite, assign) BOOL allowPinchScaling;
/// @}

@end
