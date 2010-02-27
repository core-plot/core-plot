
#import <Foundation/Foundation.h>


@protocol CPResponder <NSObject>

/// @name User Interaction
/// @{
-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint;
-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint;
-(BOOL)pointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint;
-(BOOL)pointingDeviceCancelledEvent:(id)event;
///	@}

@end
