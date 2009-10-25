
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

///	@file

typedef NSImage CPNativeImage;	///< Platform-native image format.

/**	@brief Node in a linked list of graphics contexts.
 **/
typedef struct _CPContextNode {
	NSGraphicsContext *context;			///< The graphics context.
	struct _CPContextNode *nextNode;	///< Pointer to the next node in the list.
} CPContextNode;
