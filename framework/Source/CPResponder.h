
#import <Foundation/Foundation.h>


@protocol CPResponder <NSObject>

/// @name User Interaction
/// @{
-(BOOL)pointingDeviceDownAtPoint:(CGPoint)interactionPoint;
-(BOOL)pointingDeviceUpAtPoint:(CGPoint)interactionPoint;
-(BOOL)pointingDeviceDraggedAtPoint:(CGPoint)interactionPoint;
-(BOOL)pointingDeviceCancelled;
///	@}

@end
