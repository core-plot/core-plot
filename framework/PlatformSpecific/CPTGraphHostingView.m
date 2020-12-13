#import "CPTGraphHostingView.h"

#import "CPTGraph.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotSpace.h"

#if TARGET_OS_OSX

#pragma mark macOS
#pragma mark -

/// @cond

static void *CPTGraphHostingViewKVOContext = (void *)&CPTGraphHostingViewKVOContext;

@interface CPTGraphHostingView()

@property (nonatomic, readwrite) NSPoint locationInWindow;
@property (nonatomic, readwrite) CGPoint scrollOffset;

-(void)plotSpaceAdded:(nonnull NSNotification *)notification;
-(void)plotSpaceRemoved:(nonnull NSNotification *)notification;
-(void)plotAreaBoundsChanged;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A container view for displaying a CPTGraph.
 **/
@implementation CPTGraphHostingView

/** @property nullable CPTGraph *hostedGraph
 *  @brief The CPTGraph hosted inside this view.
 **/
@synthesize hostedGraph;

/** @property NSRect printRect
 *  @brief The bounding rectangle used when printing this view. Default is NSZeroRect.
 *
 *  If NSZeroRect (the default), the frame rectangle of the view is used instead.
 **/
@synthesize printRect;

/** @property nullable NSCursor *closedHandCursor
 *  @brief The cursor displayed when the user is actively dragging any plot space.
 **/
@synthesize closedHandCursor;

/** @property nullable NSCursor *openHandCursor
 *  @brief The cursor displayed when the mouse pointer is over a plot area mapped to a plot space that allows user interaction, but not actively being dragged.
 **/
@synthesize openHandCursor;

/** @property BOOL allowPinchScaling
 *  @brief Whether a pinch gesture will trigger plot space scaling. Default is @YES.
 **/
@synthesize allowPinchScaling;

@synthesize locationInWindow;
@synthesize scrollOffset;

/// @cond

-(void)commonInit
{
    self.hostedGraph = nil;
    self.printRect   = NSZeroRect;

    self.closedHandCursor  = [NSCursor closedHandCursor];
    self.openHandCursor    = [NSCursor openHandCursor];
    self.allowPinchScaling = YES;

    self.locationInWindow = NSZeroPoint;
    self.scrollOffset     = CGPointZero;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ( [[self class] instancesRespondToSelector:@selector(effectiveAppearance)] ) {
        [self addObserver:self
               forKeyPath:@"effectiveAppearance"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                  context:CPTGraphHostingViewKVOContext];
    }
#pragma clang diagnostic pop

    if ( !self.superview.wantsLayer ) {
        self.layer = [self makeBackingLayer];
    }
}

-(nonnull instancetype)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

-(nonnull CALayer *)makeBackingLayer
{
    return [[CPTLayer alloc] initWithFrame:NSRectToCGRect(self.bounds)];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [hostedGraph removeObserver:self forKeyPath:@"plotAreaFrame" context:CPTGraphHostingViewKVOContext];
    [hostedGraph.plotAreaFrame removeObserver:self forKeyPath:@"plotArea" context:CPTGraphHostingViewKVOContext];

    for ( CPTPlotSpace *space in hostedGraph.allPlotSpaces ) {
        [space removeObserver:self forKeyPath:@"isDragging" context:CPTGraphHostingViewKVOContext];
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ( [[self class] instancesRespondToSelector:@selector(effectiveAppearance)] ) {
        [self removeObserver:self forKeyPath:@"effectiveAppearance" context:CPTGraphHostingViewKVOContext];
    }
#pragma clang diagnostic pop

    [hostedGraph removeFromSuperlayer];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.hostedGraph forKey:@"CPTLayerHostingView.hostedGraph"];
    [coder encodeRect:self.printRect forKey:@"CPTLayerHostingView.printRect"];
    [coder encodeObject:self.closedHandCursor forKey:@"CPTLayerHostingView.closedHandCursor"];
    [coder encodeObject:self.openHandCursor forKey:@"CPTLayerHostingView.openHandCursor"];
    [coder encodeBool:self.allowPinchScaling forKey:@"CPTLayerHostingView.allowPinchScaling"];

    // No need to archive these properties:
    // locationInWindow
    // scrollOffset
}

-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];

        self.hostedGraph = [coder decodeObjectOfClass:[CPTGraph class]
                                               forKey:@"CPTLayerHostingView.hostedGraph"]; // setup layers
        self.printRect        = [coder decodeRectForKey:@"CPTLayerHostingView.printRect"];
        self.closedHandCursor = [coder decodeObjectOfClass:[NSCursor class]
                                                    forKey:@"CPTLayerHostingView.closedHandCursor"];
        self.openHandCursor = [coder decodeObjectOfClass:[NSCursor class]
                                                  forKey:@"CPTLayerHostingView.openHandCursor"];

        if ( [coder containsValueForKey:@"CPTLayerHostingView.allowPinchScaling"] ) {
            self.allowPinchScaling = [coder decodeBoolForKey:@"CPTLayerHostingView.allowPinchScaling"];
        }
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)drawRect:(NSRect __unused)dirtyRect
{
    if ( self.hostedGraph ) {
        if ( ![NSGraphicsContext currentContextDrawingToScreen] ) {
            [self viewDidChangeBackingProperties];

            NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];

            [graphicsContext saveGraphicsState];

            CGRect sourceRect      = NSRectToCGRect(self.frame);
            CGRect destinationRect = NSRectToCGRect(self.printRect);
            if ( CGRectEqualToRect(destinationRect, CGRectZero)) {
                destinationRect = sourceRect;
            }

            // scale the view isotropically so that it fits on the printed page
            CGFloat widthScale  = (sourceRect.size.width != CPTFloat(0.0)) ? destinationRect.size.width / sourceRect.size.width : CPTFloat(1.0);
            CGFloat heightScale = (sourceRect.size.height != CPTFloat(0.0)) ? destinationRect.size.height / sourceRect.size.height : CPTFloat(1.0);
            CGFloat scale       = MIN(widthScale, heightScale);

            // position the view so that its centered on the printed page
            CGPoint offset = destinationRect.origin;
            offset.x += ((destinationRect.size.width - (sourceRect.size.width * scale)) / CPTFloat(2.0));
            offset.y += ((destinationRect.size.height - (sourceRect.size.height * scale)) / CPTFloat(2.0));

            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy:offset.x yBy:offset.y];
            [transform scaleBy:scale];
            [transform concat];

            // render CPTLayers recursively into the graphics context used for printing
            // (thanks to Brad for the tip: https://stackoverflow.com/a/2791305/132867 )
            CGContextRef context = graphicsContext.graphicsPort;
            [self.hostedGraph recursivelyRenderInContext:context];

            [graphicsContext restoreGraphicsState];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Printing

/// @cond

-(BOOL)knowsPageRange:(nonnull NSRangePointer)rangePointer
{
    rangePointer->location = 1;
    rangePointer->length   = 1;

    return YES;
}

-(NSRect)rectForPage:(NSInteger __unused)pageNumber
{
    return self.printRect;
}

/// @endcond

#pragma mark -
#pragma mark Mouse handling

/// @cond

-(BOOL)acceptsFirstMouse:(nullable NSEvent *__unused)theEvent
{
    return YES;
}

-(void)mouseDown:(nonnull NSEvent *)theEvent
{
    [super mouseDown:theEvent];

    CPTGraph *theGraph = self.hostedGraph;
    BOOL handled       = NO;

    if ( theGraph ) {
        CGPoint pointOfMouseDown   = NSPointToCGPoint([self convertPoint:theEvent.locationInWindow fromView:nil]);
        CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDown toLayer:theGraph];
        handled = [theGraph pointingDeviceDownEvent:theEvent atPoint:pointInHostedGraph];
    }

    if ( !handled ) {
        [self.nextResponder mouseDown:theEvent];
    }
}

-(void)mouseDragged:(nonnull NSEvent *)theEvent
{
    CPTGraph *theGraph = self.hostedGraph;
    BOOL handled       = NO;

    if ( theGraph ) {
        CGPoint pointOfMouseDrag   = NSPointToCGPoint([self convertPoint:theEvent.locationInWindow fromView:nil]);
        CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDrag toLayer:theGraph];
        handled = [theGraph pointingDeviceDraggedEvent:theEvent atPoint:pointInHostedGraph];
    }

    if ( !handled ) {
        [self.nextResponder mouseDragged:theEvent];
    }
}

-(void)mouseUp:(nonnull NSEvent *)theEvent
{
    CPTGraph *theGraph = self.hostedGraph;
    BOOL handled       = NO;

    if ( theGraph ) {
        CGPoint pointOfMouseUp     = NSPointToCGPoint([self convertPoint:theEvent.locationInWindow fromView:nil]);
        CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseUp toLayer:theGraph];
        handled = [theGraph pointingDeviceUpEvent:theEvent atPoint:pointInHostedGraph];
    }

    if ( !handled ) {
        [self.nextResponder mouseUp:theEvent];
    }
}

/// @endcond

#pragma mark -
#pragma mark Trackpad handling

/// @cond

-(void)magnifyWithEvent:(nonnull NSEvent *)event
{
    CPTGraph *theGraph = self.hostedGraph;
    BOOL handled       = NO;

    if ( theGraph && self.allowPinchScaling ) {
        CGPoint pointOfMagnification = NSPointToCGPoint([self convertPoint:event.locationInWindow fromView:nil]);
        CGPoint pointInHostedGraph   = [self.layer convertPoint:pointOfMagnification toLayer:theGraph];
        CGPoint pointInPlotArea      = [theGraph convertPoint:pointInHostedGraph toLayer:theGraph.plotAreaFrame.plotArea];

        CGFloat scale = event.magnification + CPTFloat(1.0);

        for ( CPTPlotSpace *space in theGraph.allPlotSpaces ) {
            if ( space.allowsUserInteraction ) {
                [space scaleBy:scale aboutPoint:pointInPlotArea];
                handled = YES;
            }
        }
    }

    if ( !handled ) {
        [self.nextResponder magnifyWithEvent:event];
    }
}

-(void)scrollWheel:(nonnull NSEvent *)theEvent
{
    CPTGraph *theGraph = self.hostedGraph;
    BOOL handled       = NO;

    if ( theGraph ) {
        switch ( theEvent.phase ) {
            case NSEventPhaseBegan: // Trackpad with no momentum scrolling. Fingers moved on trackpad.
            {
                self.locationInWindow = theEvent.locationInWindow;
                self.scrollOffset     = CGPointZero;

                CGPoint pointOfMouseDown   = NSPointToCGPoint([self convertPoint:self.locationInWindow fromView:nil]);
                CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDown toLayer:theGraph];
                handled = [theGraph pointingDeviceDownEvent:theEvent atPoint:pointInHostedGraph];
            }
            // Fall through

            case NSEventPhaseChanged:
            {
                CGPoint offset = self.scrollOffset;
                offset.x         += theEvent.scrollingDeltaX;
                offset.y         -= theEvent.scrollingDeltaY;
                self.scrollOffset = offset;

                NSPoint scrolledPointOfMouse = self.locationInWindow;
                scrolledPointOfMouse.x += offset.x;
                scrolledPointOfMouse.y += offset.y;

                CGPoint pointOfMouseDrag   = NSPointToCGPoint([self convertPoint:scrolledPointOfMouse fromView:nil]);
                CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDrag toLayer:theGraph];
                handled = handled || [theGraph pointingDeviceDraggedEvent:theEvent atPoint:pointInHostedGraph];
            }
            break;

            case NSEventPhaseEnded:
            {
                CGPoint offset = self.scrollOffset;

                NSPoint scrolledPointOfMouse = self.locationInWindow;
                scrolledPointOfMouse.x += offset.x;
                scrolledPointOfMouse.y += offset.y;

                CGPoint pointOfMouseUp     = NSPointToCGPoint([self convertPoint:scrolledPointOfMouse fromView:nil]);
                CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseUp toLayer:theGraph];
                handled = [theGraph pointingDeviceUpEvent:theEvent atPoint:pointInHostedGraph];
            }
            break;

            case NSEventPhaseNone:
                if ( theEvent.momentumPhase == NSEventPhaseNone ) {
                    // Mouse wheel
                    CGPoint startLocation      = theEvent.locationInWindow;
                    CGPoint pointOfMouse       = NSPointToCGPoint([self convertPoint:startLocation fromView:nil]);
                    CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouse toLayer:theGraph];

                    CGPoint scrolledLocationInWindow = startLocation;
                    if ( theEvent.hasPreciseScrollingDeltas ) {
                        scrolledLocationInWindow.x += theEvent.scrollingDeltaX;
                        scrolledLocationInWindow.y -= theEvent.scrollingDeltaY;
                    }
                    else {
                        scrolledLocationInWindow.x += theEvent.scrollingDeltaX * CPTFloat(10.0);
                        scrolledLocationInWindow.y -= theEvent.scrollingDeltaY * CPTFloat(10.0);
                    }
                    CGPoint scrolledPointOfMouse       = NSPointToCGPoint([self convertPoint:scrolledLocationInWindow fromView:nil]);
                    CGPoint scrolledPointInHostedGraph = [self.layer convertPoint:scrolledPointOfMouse toLayer:theGraph];

                    handled = [theGraph scrollWheelEvent:theEvent fromPoint:pointInHostedGraph toPoint:scrolledPointInHostedGraph];
                }
                break;

            default:
                break;
        }
    }

    if ( !handled ) {
        [self.nextResponder scrollWheel:theEvent];
    }
}

/// @endcond

#pragma mark -
#pragma mark HiDPI display support

/// @cond

-(void)viewDidChangeBackingProperties
{
    [super viewDidChangeBackingProperties];

    NSWindow *myWindow = self.window;

    if ( myWindow ) {
        self.layer.contentsScale = myWindow.backingScaleFactor;
    }
    else {
        self.layer.contentsScale = CPTFloat(1.0);
    }
}

/// @endcond

#pragma mark -
#pragma mark Cursor management

/// @cond

-(void)resetCursorRects
{
    [super resetCursorRects];

    CPTGraph *theGraph    = self.hostedGraph;
    CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;

    NSCursor *closedCursor = self.closedHandCursor;
    NSCursor *openCursor   = self.openHandCursor;

    if ( plotArea && (closedCursor || openCursor)) {
        BOOL allowsInteraction = NO;
        BOOL isDragging        = NO;

        for ( CPTPlotSpace *space in theGraph.allPlotSpaces ) {
            allowsInteraction = allowsInteraction || space.allowsUserInteraction;
            isDragging        = isDragging || space.isDragging;
        }

        if ( allowsInteraction ) {
            NSCursor *cursor = isDragging ? closedCursor : openCursor;

            if ( cursor ) {
                CGRect plotAreaBounds = [self.layer convertRect:plotArea.bounds fromLayer:plotArea];

                [self addCursorRect:NSRectFromCGRect(plotAreaBounds)
                             cursor:cursor];
            }
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Notifications

/// @cond

/** @internal
 *  @brief Adds a KVO observer to a new plot space added to the hosted graph.
 **/
-(void)plotSpaceAdded:(nonnull NSNotification *)notification
{
    CPTDictionary *userInfo = notification.userInfo;
    CPTPlotSpace *space     = userInfo[CPTGraphPlotSpaceNotificationKey];

    [space addObserver:self
            forKeyPath:@"isDragging"
               options:NSKeyValueObservingOptionNew
               context:CPTGraphHostingViewKVOContext];
}

/** @internal
 *  @brief Removes the KVO observer from a plot space removed from the hosted graph.
 **/
-(void)plotSpaceRemoved:(nonnull NSNotification *)notification
{
    CPTDictionary *userInfo = notification.userInfo;
    CPTPlotSpace *space     = userInfo[CPTGraphPlotSpaceNotificationKey];

    [space removeObserver:self forKeyPath:@"isDragging" context:CPTGraphHostingViewKVOContext];
    [self.window invalidateCursorRectsForView:self];
}

/** @internal
 *  @brief Updates the cursor rect when the plot area is resized.
 **/
-(void)plotAreaBoundsChanged
{
    [self.window invalidateCursorRectsForView:self];
}

-(void)viewWillMoveToSuperview:(nullable NSView *)newSuperview
{
    if ( self.superview.wantsLayer != newSuperview.wantsLayer ) {
        self.wantsLayer = NO;
        self.layer      = nil;

        if ( newSuperview.wantsLayer ) {
            self.wantsLayer = YES;
        }
        else {
            self.layer      = [self makeBackingLayer];
            self.wantsLayer = YES;
        }

        CPTGraph *theGraph = self.hostedGraph;
        if ( theGraph ) {
            [self.layer addSublayer:theGraph];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark KVO Methods

/// @cond

-(void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable CPTDictionary *)change context:(nullable void *)context
{
    if ( context == CPTGraphHostingViewKVOContext ) {
        CPTGraph *theGraph = self.hostedGraph;

        if ( [keyPath isEqualToString:@"isDragging"] && [object isKindOfClass:[CPTPlotSpace class]] ) {
            [self.window invalidateCursorRectsForView:self];
        }
        else if ( [keyPath isEqualToString:@"plotAreaFrame"] && (object == theGraph)) {
            CPTPlotAreaFrame *oldPlotAreaFrame = change[NSKeyValueChangeOldKey];
            CPTPlotAreaFrame *newPlotAreaFrame = change[NSKeyValueChangeNewKey];

            if ( oldPlotAreaFrame ) {
                [oldPlotAreaFrame removeObserver:self forKeyPath:@"plotArea" context:CPTGraphHostingViewKVOContext];
            }

            if ( newPlotAreaFrame ) {
                [newPlotAreaFrame addObserver:self
                                   forKeyPath:@"plotArea"
                                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                                      context:CPTGraphHostingViewKVOContext];
            }
        }
        else if ( [keyPath isEqualToString:@"plotArea"] && (object == theGraph.plotAreaFrame)) {
            CPTPlotArea *oldPlotArea = change[NSKeyValueChangeOldKey];
            CPTPlotArea *newPlotArea = change[NSKeyValueChangeNewKey];

            if ( oldPlotArea ) {
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:CPTLayerBoundsDidChangeNotification
                                                              object:oldPlotArea];
            }

            if ( newPlotArea ) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(plotAreaBoundsChanged)
                                                             name:CPTLayerBoundsDidChangeNotification
                                                           object:newPlotArea];
            }
        }
        else if ( [keyPath isEqualToString:@"effectiveAppearance"] && (object == self)) {
            [self.hostedGraph setNeedsDisplayAllLayers];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setHostedGraph:(nullable CPTGraph *)newGraph
{
    NSParameterAssert((newGraph == nil) || [newGraph isKindOfClass:[CPTGraph class]]);

    if ( newGraph != hostedGraph ) {
        self.wantsLayer = YES;

        if ( hostedGraph ) {
            [hostedGraph removeFromSuperlayer];
            hostedGraph.hostingView = nil;

            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTGraphDidAddPlotSpaceNotification object:hostedGraph];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTGraphDidRemovePlotSpaceNotification object:hostedGraph];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:CPTLayerBoundsDidChangeNotification object:hostedGraph.plotAreaFrame.plotArea];

            [hostedGraph removeObserver:self forKeyPath:@"plotAreaFrame" context:CPTGraphHostingViewKVOContext];
            [hostedGraph.plotAreaFrame removeObserver:self forKeyPath:@"plotArea" context:CPTGraphHostingViewKVOContext];

            for ( CPTPlotSpace *space in hostedGraph.allPlotSpaces ) {
                [space removeObserver:self forKeyPath:@"isDragging" context:CPTGraphHostingViewKVOContext];
            }
        }

        hostedGraph = newGraph;

        if ( newGraph ) {
            CPTGraph *theGraph = newGraph;

            newGraph.hostingView = self;

            [self viewDidChangeBackingProperties];
            [self.layer addSublayer:theGraph];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(plotSpaceAdded:)
                                                         name:CPTGraphDidAddPlotSpaceNotification
                                                       object:theGraph];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(plotSpaceRemoved:)
                                                         name:CPTGraphDidRemovePlotSpaceNotification
                                                       object:theGraph];

            [theGraph addObserver:self
                       forKeyPath:@"plotAreaFrame"
                          options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                          context:CPTGraphHostingViewKVOContext];

            for ( CPTPlotSpace *space in newGraph.allPlotSpaces ) {
                [space addObserver:self
                        forKeyPath:@"isDragging"
                           options:NSKeyValueObservingOptionNew
                           context:CPTGraphHostingViewKVOContext];
            }
        }
    }
}

-(void)setClosedHandCursor:(nullable NSCursor *)newCursor
{
    if ( newCursor != closedHandCursor ) {
        closedHandCursor = newCursor;

        [self.window invalidateCursorRectsForView:self];
    }
}

-(void)setOpenHandCursor:(nullable NSCursor *)newCursor
{
    if ( newCursor != openHandCursor ) {
        openHandCursor = newCursor;

        [self.window invalidateCursorRectsForView:self];
    }
}

/// @endcond

@end

#else

#pragma mark - iOS, tvOS, Mac Catalyst
#pragma mark -

#import "NSNumberExtensions.h"

/// @cond
@interface CPTGraphHostingView()

#if (TARGET_OS_SIMULATOR || TARGET_OS_IPHONE || TARGET_OS_MACCATALYST) && !TARGET_OS_TV
@property (nonatomic, readwrite, nullable, cpt_weak_property) UIPinchGestureRecognizer *pinchGestureRecognizer;

-(void)handlePinchGesture:(nonnull UIPinchGestureRecognizer *)aPinchGestureRecognizer;
#endif

-(void)graphNeedsRedraw:(nonnull NSNotification *)notification;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A container view for displaying a CPTGraph.
 **/
@implementation CPTGraphHostingView

/** @property nullable CPTGraph *hostedGraph
 *  @brief The CPTLayer hosted inside this view.
 **/
@synthesize hostedGraph;

/** @property BOOL collapsesLayers
 *  @brief Whether view draws all graph layers into a single layer.
 *  Collapsing layers may improve performance in some cases.
 **/
@synthesize collapsesLayers;

/** @property BOOL allowPinchScaling
 *  @brief Whether a pinch will trigger plot space scaling.
 *  Default is @YES. This causes gesture recognizers to be added to identify pinches.
 **/
@synthesize allowPinchScaling;

/// @cond

#if (TARGET_OS_SIMULATOR || TARGET_OS_IPHONE || TARGET_OS_MACCATALYST) && !TARGET_OS_TV

/** @internal
 *  @property nullable UIPinchGestureRecognizer *pinchGestureRecognizer
 *  @brief The pinch gesture recognizer for this view.
 *  @since Not available on tvOS.
 **/
@synthesize pinchGestureRecognizer;
#endif

/// @endcond

#pragma mark -
#pragma mark init/dealloc

/// @cond

+(nonnull Class)layerClass
{
    return [CALayer class];
}

-(void)commonInit
{
    self.hostedGraph     = nil;
    self.collapsesLayers = NO;

    self.backgroundColor = [UIColor clearColor];

    self.allowPinchScaling = YES;

    // This undoes the normal coordinate space inversion that UIViews apply to their layers
    self.layer.sublayerTransform = CATransform3DMakeScale(CPTFloat(1.0), CPTFloat(-1.0), CPTFloat(1.0));
}

-(nonnull instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    [self commonInit];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeBool:self.collapsesLayers forKey:@"CPTGraphHostingView.collapsesLayers"];
    [coder encodeObject:self.hostedGraph forKey:@"CPTGraphHostingView.hostedGraph"];
    [coder encodeBool:self.allowPinchScaling forKey:@"CPTGraphHostingView.allowPinchScaling"];

    // No need to archive these properties:
    // pinchGestureRecognizer
}

-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];

        collapsesLayers  = [coder decodeBoolForKey:@"CPTGraphHostingView.collapsesLayers"];
        self.hostedGraph = [coder decodeObjectOfClass:[CPTGraph class]
                                               forKey:@"CPTGraphHostingView.hostedGraph"]; // setup layers

        if ( [coder containsValueForKey:@"CPTGraphHostingView.allowPinchScaling"] ) {
            self.allowPinchScaling = [coder decodeBoolForKey:@"CPTGraphHostingView.allowPinchScaling"]; // set gesture recognizer if needed
        }
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

#pragma mark -
#pragma mark Touch handling

/// @cond

-(void)touchesBegan:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    BOOL handled = NO;

    // Ignore pinch or other multitouch gestures
    if ( [event allTouches].count == 1 ) {
        CPTGraph *theHostedGraph = self.hostedGraph;
        UIEvent *theEvent        = event;

        theHostedGraph.frame = self.bounds;
        [theHostedGraph layoutIfNeeded];

        CGPoint pointOfTouch = [[[theEvent touchesForView:self] anyObject] locationInView:self];

        if ( self.collapsesLayers ) {
            pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
        }
        else {
            pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:theHostedGraph];
        }
        handled = [theHostedGraph pointingDeviceDownEvent:theEvent atPoint:pointOfTouch];
    }

    if ( !handled ) {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    BOOL handled = NO;

    if ( event ) {
        CPTGraph *theHostedGraph = self.hostedGraph;
        UIEvent *theEvent        = event;

        theHostedGraph.frame = self.bounds;
        [theHostedGraph layoutIfNeeded];

        CGPoint pointOfTouch = [[[theEvent touchesForView:self] anyObject] locationInView:self];

        if ( self.collapsesLayers ) {
            pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
        }
        else {
            pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:theHostedGraph];
        }
        handled = [theHostedGraph pointingDeviceDraggedEvent:theEvent atPoint:pointOfTouch];
    }
    if ( !handled ) {
        [super touchesMoved:touches withEvent:event];
    }
}

-(void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    BOOL handled = NO;

    if ( event ) {
        CPTGraph *theHostedGraph = self.hostedGraph;
        UIEvent *theEvent        = event;

        theHostedGraph.frame = self.bounds;
        [theHostedGraph layoutIfNeeded];

        CGPoint pointOfTouch = [[[theEvent touchesForView:self] anyObject] locationInView:self];

        if ( self.collapsesLayers ) {
            pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
        }
        else {
            pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:theHostedGraph];
        }
        handled = [theHostedGraph pointingDeviceUpEvent:theEvent atPoint:pointOfTouch];
    }

    if ( !handled ) {
        [super touchesEnded:touches withEvent:event];
    }
}

-(void)touchesCancelled:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    BOOL handled = NO;

    if ( event ) {
        UIEvent *theEvent = event;
        handled = [self.hostedGraph pointingDeviceCancelledEvent:theEvent];
    }

    if ( !handled ) {
        [super touchesCancelled:touches withEvent:event];
    }
}

/// @endcond

#pragma mark -
#pragma mark Gestures

/// @cond

#if (TARGET_OS_SIMULATOR || TARGET_OS_IPHONE || TARGET_OS_MACCATALYST) && !TARGET_OS_TV
-(void)setAllowPinchScaling:(BOOL)allowScaling
{
    if ( allowPinchScaling != allowScaling ) {
        allowPinchScaling = allowScaling;
        if ( allowPinchScaling ) {
            // Register for pinches
            UIPinchGestureRecognizer *gestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
            [self addGestureRecognizer:gestureRecognizer];
            self.pinchGestureRecognizer = gestureRecognizer;
        }
        else {
            UIPinchGestureRecognizer *pinchRecognizer = self.pinchGestureRecognizer;
            if ( pinchRecognizer ) {
                [self removeGestureRecognizer:pinchRecognizer];
                self.pinchGestureRecognizer = nil;
            }
        }
    }
}

-(void)handlePinchGesture:(nonnull UIPinchGestureRecognizer *)aPinchGestureRecognizer
{
    CGPoint interactionPoint = [aPinchGestureRecognizer locationInView:self];
    CPTGraph *theHostedGraph = self.hostedGraph;

    theHostedGraph.frame = self.bounds;
    [theHostedGraph layoutIfNeeded];

    if ( self.collapsesLayers ) {
        interactionPoint.y = self.frame.size.height - interactionPoint.y;
    }
    else {
        interactionPoint = [self.layer convertPoint:interactionPoint toLayer:theHostedGraph];
    }

    CGPoint pointInPlotArea = [theHostedGraph convertPoint:interactionPoint toLayer:theHostedGraph.plotAreaFrame.plotArea];

    UIPinchGestureRecognizer *pinchRecognizer = self.pinchGestureRecognizer;

    CGFloat scale = pinchRecognizer.scale;

    for ( CPTPlotSpace *space in theHostedGraph.allPlotSpaces ) {
        if ( space.allowsUserInteraction ) {
            [space scaleBy:scale aboutPoint:pointInPlotArea];
        }
    }

    pinchRecognizer.scale = 1.0;
}

#endif

/// @endcond

#pragma mark -
#pragma mark TV Focus

/// @cond

#if TARGET_OS_TV

-(BOOL)canBecomeFocused
{
    return YES;
}

#endif

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)drawRect:(CGRect __unused)rect
{
    if ( self.collapsesLayers ) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1, -1);

        CPTGraph *theHostedGraph = self.hostedGraph;
        theHostedGraph.frame = self.bounds;
        [theHostedGraph layoutAndRenderInContext:context];
    }
}

-(void)graphNeedsRedraw:(nonnull NSNotification *__unused)notification
{
    [self setNeedsDisplay];
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
    [super traitCollectionDidChange:previousTraitCollection];

    [self.hostedGraph setNeedsDisplayAllLayers];
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setHostedGraph:(nullable CPTGraph *)newLayer
{
    NSParameterAssert((newLayer == nil) || [newLayer isKindOfClass:[CPTGraph class]]);

    if ( newLayer == hostedGraph ) {
        return;
    }

    if ( hostedGraph ) {
        [hostedGraph removeFromSuperlayer];
        hostedGraph.hostingView = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:CPTGraphNeedsRedrawNotification
                                                      object:hostedGraph];
    }
    hostedGraph = newLayer;

    // Screen scaling
    UIScreen *screen = self.window.screen;

    if ( !screen ) {
        screen = [UIScreen mainScreen];
    }

    hostedGraph.contentsScale = screen.scale;
    hostedGraph.hostingView   = self;

    if ( self.collapsesLayers ) {
        [self setNeedsDisplay];
        if ( hostedGraph ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(graphNeedsRedraw:)
                                                         name:CPTGraphNeedsRedrawNotification
                                                       object:hostedGraph];
        }
    }
    else {
        if ( newLayer ) {
            CPTGraph *newGraph = newLayer;

            newGraph.frame = self.layer.bounds;
            [self.layer addSublayer:newGraph];
        }
    }
}

-(void)setCollapsesLayers:(BOOL)collapse
{
    if ( collapse != collapsesLayers ) {
        collapsesLayers = collapse;

        CPTGraph *theHostedGraph = self.hostedGraph;

        [self setNeedsDisplay];

        if ( collapsesLayers ) {
            [theHostedGraph removeFromSuperlayer];

            if ( theHostedGraph ) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(graphNeedsRedraw:)
                                                             name:CPTGraphNeedsRedrawNotification
                                                           object:theHostedGraph];
            }
        }
        else {
            if ( theHostedGraph ) {
                [self.layer addSublayer:theHostedGraph];

                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:CPTGraphNeedsRedrawNotification
                                                              object:theHostedGraph];
            }
        }
    }
}

-(void)setFrame:(CGRect)newFrame
{
    super.frame = newFrame;

    CPTGraph *theHostedGraph = self.hostedGraph;

    [theHostedGraph setNeedsLayout];

    if ( self.collapsesLayers ) {
        [self setNeedsDisplay];
    }
    else {
        theHostedGraph.frame = self.bounds;
    }
}

-(void)setBounds:(CGRect)newBounds
{
    super.bounds = newBounds;

    CPTGraph *theHostedGraph = self.hostedGraph;

    [theHostedGraph setNeedsLayout];

    if ( self.collapsesLayers ) {
        [self setNeedsDisplay];
    }
    else {
        theHostedGraph.frame = newBounds;
    }
}

/// @endcond

@end

#endif
