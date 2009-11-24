
#import <Foundation/Foundation.h>


@protocol CPResponder <NSObject>

/// @name Core Plot Responder Chain
/// @{
@property (nonatomic, readwrite, assign) id <CPResponder> nextResponder;
///	@}

/// @name User Interaction
/// @{
-(void)mouseOrFingerDownAtPoint:(CGPoint)interactionPoint;
-(void)mouseOrFingerUpAtPoint:(CGPoint)interactionPoint;
-(void)mouseOrFingerDraggedAtPoint:(CGPoint)interactionPoint;
-(void)mouseOrFingerCancelled;
///	@}

@end
