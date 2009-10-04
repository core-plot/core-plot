#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/**	@brief Defines a layer layout manager. All methods are optional.
 **/
@protocol CPLayoutManager <NSObject>
@optional

/**	@brief Invalidates the layout of a layer.
 *	@param layer The layer that requires layout.
 *
 *	This method is called when the preferred size of the layer may have changed.
 *	The receiver should invalidate any cached state.
 **/
-(void)invalidateLayoutOfLayer:(CALayer *)layer;

/**	@brief Layout each sublayer of the given layer.
 *	@param layer The layer whose sublayers require layout.
 *
 *	The recevier should set the frame of each sublayer that requires layout.
 **/
-(void)layoutSublayersOfLayer:(CALayer *)layer;

/**	@brief Returns the preferred size of a layer in its coordinate system.
 *	@param layer The layer that requires layout.
 *	@return The preferred size of the layer.
 *	
 *	If this method is not implemented the preferred size is assumed to be the size of the bounds of <code>layer</code>.
 **/
-(CGSize)preferredSizeOfLayer:(CALayer *)layer;

/**	@brief Returns the minimum size of a layer in its coordinate system.
 *	@param layer The layer that requires layout.
 *	@return The minimum size of the layer.
 *	
 *	If this method is not implemented the minimum size is assumed to be (0, 0).
 **/
-(CGSize)minimumSizeOfLayer:(CALayer *)layer;

/**	@brief Returns the maximum size of a layer in its coordinate system.
 *	@param layer The layer that requires layout.
 *	@return The maximum size of the layer.
 *	
 *	If this method is not implemented the maximimum size is assumed to be the size of the bounds of  <code>layer</code>'s superlayer.
 **/
-(CGSize)maximumSizeOfLayer:(CALayer *)layer;

@end
