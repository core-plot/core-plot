
#import <Foundation/Foundation.h>


@protocol CPResponder <NSObject>

/// @name Core Plot Responder Chain
/// @{
@property (nonatomic, readwrite, assign) id <CPResponder> nextResponder;
///	@}

/// @name User Interaction
/// @{
-(void)pointingDeviceDownAtPoint:(CGPoint)interactionPoint;
-(void)pointingDeviceUpAtPoint:(CGPoint)interactionPoint;
-(void)pointingDeviceDraggedAtPoint:(CGPoint)interactionPoint;
-(void)pointingDeviceCancelled;
///	@}

@end
