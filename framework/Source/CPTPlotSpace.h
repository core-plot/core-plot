#import "CPTDefinitions.h"
#import "CPTResponder.h"

@class CPTLayer;
@class CPTPlotRange;
@class CPTGraph;
@class CPTPlotSpace;

/// @name Plot Space
/// @{

/** @brief Plot space coordinate change notification.
 *
 *  This notification is posted to the default notification center whenever the mapping between
 *  the plot space coordinate system and drawing coordinates changes.
 *  @ingroup notification
 **/
extern NSString *const CPTPlotSpaceCoordinateMappingDidChangeNotification;

/** @brief The <code>userInfo</code> dictionary key used by the CPTPlotSpaceCoordinateMappingDidChangeNotification
 *  to indicate the plot coordinate affected by the mapping change.
 *
 *  The value associated with this key is the CPTCoordinate affected by the change wrapped in an instance of NSNumber.
 *  @ingroup notification
 **/
extern NSString *const CPTPlotSpaceCoordinateKey;

/** @brief The <code>userInfo</code> dictionary key used by the CPTPlotSpaceCoordinateMappingDidChangeNotification
 *  to indicate whether the mapping change is a scroll movement or other change.
 *
 *  The value associated with this key is a boolean value wrapped in an instance of NSNumber. The value
 *  is @YES if the plot space change represents a horizontal or vertical translation, @NO otherwise.
 *  @ingroup notification
 **/
extern NSString *const CPTPlotSpaceScrollingKey;

/** @brief The <code>userInfo</code> dictionary key used by the CPTPlotSpaceCoordinateMappingDidChangeNotification
 *  to indicate the displacement offset for scrolling changes in drawing coordinates.
 *
 *  The value associated with this key is the displacement offset wrapped in an instance of NSNumber.
 *  @ingroup notification
 **/
extern NSString *const CPTPlotSpaceDisplacementKey;

/// @}

/**
 *  @brief Plot space delegate.
 **/
@protocol CPTPlotSpaceDelegate<NSObject>

@optional

/// @name Scaling
/// @{

/** @brief @optional Informs the receiver that it should uniformly scale (e.g., in response to a pinch gesture).
 *  @param space The plot space.
 *  @param interactionScale The scaling factor.
 *  @param interactionPoint The coordinates of the scaling centroid.
 *  @return @YES if the gesture should be handled by the plot space, and @NO if not.
 *  In either case, the delegate may choose to take extra actions, or handle the scaling itself.
 **/
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint;

/// @}

/// @name Scrolling
/// @{

/** @brief @optional Notifies that plot space is going to scroll.
 *  @param space The plot space.
 *  @param proposedDisplacementVector The proposed amount by which the plot space will shift.
 *  @return The displacement actually applied.
 **/
-(CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)proposedDisplacementVector;

/// @}

/// @name Plot Range Changes
/// @{

/** @brief @optional Notifies that plot space is going to change a plot range.
 *  @param space The plot space.
 *  @param newRange The proposed new plot range.
 *  @param coordinate The coordinate of the range.
 *  @return The new plot range to be used.
 **/
-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate;

/** @brief @optional Notifies that plot space has changed a plot range.
 *  @param space The plot space.
 *  @param coordinate The coordinate of the range.
 **/
-(void)plotSpace:(CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate;

/// @}

/// @name User Interaction
/// @{

/** @brief @optional Notifies that plot space intercepted a device down event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param point The point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point;

/** @brief @optional Notifies that plot space intercepted a device dragged event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param point The point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point;

/** @brief @optional Notifies that plot space intercepted a device cancelled event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(CPTNativeEvent *)event;

/** @brief @optional Notifies that plot space intercepted a device up event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param point The point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

/** @brief @optional Notifies that plot space intercepted a scroll wheel event.
 *  @param space The plot space.
 *  @param event The native event.
 *  @param fromPoint The The starting point in the host view.
 *  @param toPoint The The ending point in the host view.
 *  @return Whether the plot space should handle the event or not.
 *  In either case, the delegate may choose to take extra actions, or handle the event itself.
 **/
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandleScrollWheelEvent:(CPTNativeEvent *)event fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;
#endif

/// @}

@end

#pragma mark -

@interface CPTPlotSpace : NSObject<CPTResponder, NSCoding>

@property (nonatomic, readwrite, copy) id<NSCopying, NSCoding, NSObject> identifier;
@property (nonatomic, readwrite) BOOL allowsUserInteraction;
@property (nonatomic, readonly) BOOL isDragging;
@property (nonatomic, readwrite, cpt_weak_property) __cpt_weak CPTGraph *graph;
@property (nonatomic, readwrite, cpt_weak_property) __cpt_weak id<CPTPlotSpaceDelegate> delegate;

@property (nonatomic, readonly) NSUInteger numberOfCoordinates;

/// @name Categorical Data
/// @{
-(void)addCategory:(NSString *)category forCoordinate:(CPTCoordinate)coordinate;
-(void)removeCategory:(NSString *)category forCoordinate:(CPTCoordinate)coordinate;
-(void)insertCategory:(NSString *)category forCoordinate:(CPTCoordinate)coordinate atIndex:(NSUInteger)idx;
-(void)setCategories:(NSArray *)newCategories forCoordinate:(CPTCoordinate)coordinate;
-(void)removeAllCategories;

-(NSArray *)categoriesForCoordinate:(CPTCoordinate)coordinate;
-(NSString *)categoryForCoordinate:(CPTCoordinate)coordinate atIndex:(NSUInteger)idx;
-(NSUInteger)indexOfCategory:(NSString *)category forCoordinate:(CPTCoordinate)coordinate;
/// @}

@end

#pragma mark -

/** @category CPTPlotSpace(AbstractMethods)
 *  @brief CPTPlotSpace abstract methods—must be overridden by subclasses
 **/
@interface CPTPlotSpace(AbstractMethods)

/// @name Coordinate Space Conversions
/// @{
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count;
-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count;

-(void)plotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point;
-(void)doublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count forPlotAreaViewPoint:(CGPoint)point;

-(CGPoint)plotAreaViewPointForEvent:(CPTNativeEvent *)event;

-(void)plotPoint:(NSDecimal *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(CPTNativeEvent *)event;
-(void)doublePrecisionPlotPoint:(double *)plotPoint numberOfCoordinates:(NSUInteger)count forEvent:(CPTNativeEvent *)event;
/// @}

/// @name Coordinate Range
/// @{
-(void)setPlotRange:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate;
-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate;
/// @}

/// @name Scale Types
/// @{
-(void)setScaleType:(CPTScaleType)newType forCoordinate:(CPTCoordinate)coordinate;
-(CPTScaleType)scaleTypeForCoordinate:(CPTCoordinate)coordinate;
/// @}

/// @name Adjusting Ranges
/// @{
-(void)scaleToFitPlots:(NSArray *)plots;
-(void)scaleToFitPlots:(NSArray *)plots forCoordinate:(CPTCoordinate)coordinate;
-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint;
/// @}

@end
