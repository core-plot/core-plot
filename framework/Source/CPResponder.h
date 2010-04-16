
#import <Foundation/Foundation.h>

/**	@brief The basis of all event processing in Core Plot.
 **/
@protocol CPResponder <NSObject>

/// @name User Interaction
/// @{

/**	@brief Informs the receiver that the user has pressed the mouse button (Mac OS) or touched the screen (iPhone OS).
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 **/
-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint;

/**	@brief Informs the receiver that the user has released the mouse button (Mac OS) or lifted their finger off the screen (iPhone OS).
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 **/
-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint;

/**	@brief Informs the receiver that the user has moved the mouse with the button pressed (Mac OS) or moved their finger while touching the screen (iPhone OS).
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 **/
-(BOOL)pointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint;

/**	@brief Informs the receiver that tracking of mouse moves (Mac OS) or touches (iPhone OS) has been cancelled for any reason.
 *	@param event The OS event.
 **/
-(BOOL)pointingDeviceCancelledEvent:(id)event;
///	@}

@end
