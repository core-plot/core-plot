
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef NSImage CPNativeImage;

typedef struct _CPContextNode {
	NSGraphicsContext *context;
	struct _CPContextNode *nextNode;
} CPContextNode;
