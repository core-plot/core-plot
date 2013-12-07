#import "CPTAnnotationHostLayer.h"

#import "CPTAnnotation.h"
#import "CPTExceptions.h"

/// @cond
@interface CPTAnnotationHostLayer()

@property (nonatomic, readwrite, retain) NSMutableArray *mutableAnnotations;

@end

/// @endcond

#pragma mark -

/** @brief A container layer for annotations.
 *
 *  Annotations (CPTAnnotation) can be added to and removed from an annotation layer.
 *  The host layer automatically handles the annotation layout.
 **/
@implementation CPTAnnotationHostLayer

/** @property NSArray *annotations
 *  @brief An array of annotations attached to this layer.
 **/
@dynamic annotations;

@synthesize mutableAnnotations;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTAnnotationHostLayer object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have an empty
 *  @ref annotations array.
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTAnnotationHostLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        mutableAnnotations = [[NSMutableArray alloc] init];
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTAnnotationHostLayer *theLayer = (CPTAnnotationHostLayer *)layer;

        mutableAnnotations = [theLayer->mutableAnnotations retain];
    }
    return self;
}

-(void)dealloc
{
    [mutableAnnotations release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.mutableAnnotations forKey:@"CPTAnnotationHostLayer.mutableAnnotations"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        mutableAnnotations = [[coder decodeObjectForKey:@"CPTAnnotationHostLayer.mutableAnnotations"] mutableCopy];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Annotations

-(NSArray *)annotations
{
    return [[self.mutableAnnotations copy] autorelease];
}

/**
 *  @brief Adds an annotation to the receiver.
 **/
-(void)addAnnotation:(CPTAnnotation *)annotation
{
    if ( annotation ) {
        NSMutableArray *annotationArray = self.mutableAnnotations;
        if ( ![annotationArray containsObject:annotation] ) {
            [annotationArray addObject:annotation];
        }
        annotation.annotationHostLayer = self;
        [annotation positionContentLayer];
    }
}

/**
 *  @brief Removes an annotation from the receiver.
 **/
-(void)removeAnnotation:(CPTAnnotation *)annotation
{
    if ( [self.mutableAnnotations containsObject:annotation] ) {
        annotation.annotationHostLayer = nil;
        [self.mutableAnnotations removeObject:annotation];
    }
    else {
        [NSException raise:CPTException format:@"Tried to remove CPTAnnotation from %@. Host layer was %@.", self, annotation.annotationHostLayer];
    }
}

/**
 *  @brief Removes all annotations from the receiver.
 **/
-(void)removeAllAnnotations
{
    NSMutableArray *allAnnotations = self.mutableAnnotations;

    for ( CPTAnnotation *annotation in allAnnotations ) {
        annotation.annotationHostLayer = nil;
    }
    [allAnnotations removeAllObjects];
}

#pragma mark -
#pragma mark Layout

/// @cond

-(NSSet *)sublayersExcludedFromAutomaticLayout
{
    NSMutableArray *annotations = self.mutableAnnotations;

    if ( annotations.count > 0 ) {
        NSMutableSet *excludedSublayers = [[[super sublayersExcludedFromAutomaticLayout] mutableCopy] autorelease];

        if ( !excludedSublayers ) {
            excludedSublayers = [NSMutableSet set];
        }

        for ( CPTAnnotation *annotation in annotations ) {
            CALayer *content = annotation.contentLayer;
            if ( content ) {
                [excludedSublayers addObject:content];
            }
        }

        return excludedSublayers;
    }
    else {
        return [super sublayersExcludedFromAutomaticLayout];
    }
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    [self.mutableAnnotations makeObjectsPerformSelector:@selector(positionContentLayer)];
}

/// @endcond

#pragma mark -
#pragma mark Event Handling

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly touched the screen. @endif
 *
 *
 *  The event is passed in turn to each annotation layer that contains the interaction point.
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    for ( CPTAnnotation *annotation in self.annotations ) {
        CPTLayer *content = annotation.contentLayer;
        if ( content ) {
            if ( CGRectContainsPoint(content.frame, interactionPoint) ) {
                BOOL handled = [content pointingDeviceDownEvent:event atPoint:interactionPoint];
                if ( handled ) {
                    return YES;
                }
            }
        }
    }

    return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
}

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly released the mouse button. @endif
 *  @if iOSOnly lifted their finger off the screen. @endif
 *
 *
 *  The event is passed in turn to each annotation layer that contains the interaction point.
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    for ( CPTAnnotation *annotation in self.annotations ) {
        CPTLayer *content = annotation.contentLayer;
        if ( content ) {
            if ( CGRectContainsPoint(content.frame, interactionPoint) ) {
                BOOL handled = [content pointingDeviceUpEvent:event atPoint:interactionPoint];
                if ( handled ) {
                    return YES;
                }
            }
        }
    }

    return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
}

/**
 *  @brief Informs the receiver that the user has moved
 *  @if MacOnly the mouse with the button pressed. @endif
 *  @if iOSOnly their finger while touching the screen. @endif
 *
 *
 *  The event is passed in turn to each annotation layer that contains the interaction point.
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    for ( CPTAnnotation *annotation in self.annotations ) {
        CPTLayer *content = annotation.contentLayer;
        if ( content ) {
            if ( CGRectContainsPoint(content.frame, interactionPoint) ) {
                BOOL handled = [content pointingDeviceDraggedEvent:event atPoint:interactionPoint];
                if ( handled ) {
                    return YES;
                }
            }
        }
    }

    return [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];
}

/**
 *  @brief Informs the receiver that tracking of
 *  @if MacOnly mouse moves @endif
 *  @if iOSOnly touches @endif
 *  has been cancelled for any reason.
 *
 *
 *  The event is passed in turn to each annotation layer.
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES.
 *
 *  @param event The OS event.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    for ( CPTAnnotation *annotation in self.annotations ) {
        CPTLayer *content = annotation.contentLayer;
        if ( content ) {
            BOOL handled = [content pointingDeviceCancelledEvent:event];
            if ( handled ) {
                return YES;
            }
        }
    }

    return [super pointingDeviceCancelledEvent:event];
}

/// @}

@end
