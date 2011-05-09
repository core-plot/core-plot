
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

///	@file

typedef NSImage CPTNativeImage;	///< Platform-native image format.

/**	@brief Node in a linked list of graphics contexts.
 **/
typedef struct _CPTContextNode {
	NSGraphicsContext *context;			///< The graphics context.
	struct _CPTContextNode *nextNode;	///< Pointer to the next node in the list.
} CPTContextNode;
