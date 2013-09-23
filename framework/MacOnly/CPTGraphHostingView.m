#import "CPTGraphHostingView.h"

#import "CPTGraph.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotSpace.h"

/// @cond

static void *const CPTGraphHostingViewKVOContext = (void *)&CPTGraphHostingViewKVOContext;

// for MacOS 10.6 SDK compatibility
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
#if MAC_OS_X_VERSION_MAX_ALLOWED < 1070
@interface NSWindow(CPTExtensions)

@property (readonly) CGFloat backingScaleFactor;

-(void)viewDidChangeBackingProperties;

@end
#endif
#endif

#pragma mark -

@interface CPTGraphHostingView()

-(void)plotSpaceAdded:(NSNotification *)notification;
-(void)plotSpaceRemoved:(NSNotification *)notification;
-(void)plotAreaBoundsChanged;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A container view for displaying a CPTGraph.
 **/
@implementation CPTGraphHostingView

/** @property CPTGraph *hostedGraph
 *  @brief The CPTGraph hosted inside this view.
 **/
@synthesize hostedGraph;

/** @property NSRect printRect
 *  @brief The bounding rectangle used when printing this view.
 **/
@synthesize printRect;

/** @property NSCursor *closedHandCursor
 *  @brief The cursor displayed when the user is actively dragging any plot space.
 **/
@synthesize closedHandCursor;

/** @property NSCursor *openHandCursor
 *  @brief The cursor displayed when the mouse pointer is over a plot area mapped to a plot space that allows user interaction, but not actively being dragged.
 **/
@synthesize openHandCursor;

/// @cond

-(instancetype)initWithFrame:(NSRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        hostedGraph = nil;
        printRect   = NSZeroRect;

        closedHandCursor = [NSCursor closedHandCursor];
        openHandCursor   = [NSCursor openHandCursor];

        CPTLayer *mainLayer = [(CPTLayer *)[CPTLayer alloc] initWithFrame : NSRectToCGRect(frame)];
        self.layer = mainLayer;
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [hostedGraph removeObserver:self forKeyPath:@"plotAreaFrame" context:CPTGraphHostingViewKVOContext];
    [hostedGraph.plotAreaFrame removeObserver:self forKeyPath:@"plotArea" context:CPTGraphHostingViewKVOContext];

    for ( CPTPlotSpace *space in hostedGraph.allPlotSpaces ) {
        [space removeObserver:self forKeyPath:@"isDragging" context:CPTGraphHostingViewKVOContext];
    }

    [hostedGraph removeFromSuperlayer];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.hostedGraph forKey:@"CPTLayerHostingView.hostedGraph"];
    [coder encodeRect:self.printRect forKey:@"CPTLayerHostingView.printRect"];
    [coder encodeObject:self.closedHandCursor forKey:@"CPTLayerHostingView.closedHandCursor"];
    [coder encodeObject:self.openHandCursor forKey:@"CPTLayerHostingView.openHandCursor"];
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        CPTLayer *mainLayer = [(CPTLayer *)[CPTLayer alloc] initWithFrame : NSRectToCGRect(self.frame)];
        self.layer = mainLayer;

        hostedGraph           = nil;
        self.hostedGraph      = [coder decodeObjectForKey:@"CPTLayerHostingView.hostedGraph"]; // setup layers
        self.printRect        = [coder decodeRectForKey:@"CPTLayerHostingView.printRect"];
        self.closedHandCursor = [coder decodeObjectForKey:@"CPTLayerHostingView.closedHandCursor"];
        self.openHandCursor   = [coder decodeObjectForKey:@"CPTLayerHostingView.openHandCursor"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)drawRect:(NSRect)dirtyRect
{
    if ( self.hostedGraph ) {
        if ( ![NSGraphicsContext currentContextDrawingToScreen] ) {
            [self viewDidChangeBackingProperties];

            NSGraphicsContext *graphicsContext = [NSGraphicsContext currentContext];

            [graphicsContext saveGraphicsState];

            CGRect destinationRect = NSRectToCGRect(self.printRect);
            CGRect sourceRect      = NSRectToCGRect(self.frame);

            // scale the view isotropically so that it fits on the printed page
            CGFloat widthScale  = ( sourceRect.size.width != CPTFloat(0.0) ) ? destinationRect.size.width / sourceRect.size.width : CPTFloat(1.0);
            CGFloat heightScale = ( sourceRect.size.height != CPTFloat(0.0) ) ? destinationRect.size.height / sourceRect.size.height : CPTFloat(1.0);
            CGFloat scale       = MIN(widthScale, heightScale);

            // position the view so that its centered on the printed page
            CGPoint offset = destinationRect.origin;
            offset.x += ( ( destinationRect.size.width - (sourceRect.size.width * scale) ) / CPTFloat(2.0) );
            offset.y += ( ( destinationRect.size.height - (sourceRect.size.height * scale) ) / CPTFloat(2.0) );

            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy:offset.x yBy:offset.y];
            [transform scaleBy:scale];
            [transform concat];

            // render CPTLayers recursively into the graphics context used for printing
            // (thanks to Brad for the tip: http://stackoverflow.com/a/2791305/132867 )
            CGContextRef context = [graphicsContext graphicsPort];
            [self.hostedGraph recursivelyRenderInContext:context];

            [graphicsContext restoreGraphicsState];
        }
    }
}

-(BOOL)knowsPageRange:(NSRangePointer)rangePointer
{
    rangePointer->location = 1;
    rangePointer->length   = 1;

    return YES;
}

-(NSRect)rectForPage:(NSInteger)pageNumber
{
    return self.printRect;
}

/// @endcond

#pragma mark -
#pragma mark Mouse handling

/// @cond

-(BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(void)mouseDown:(NSEvent *)theEvent
{
    CPTGraph *theGraph = self.hostedGraph;

    if ( theGraph ) {
        CGPoint pointOfMouseDown   = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
        CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDown toLayer:theGraph];
        [theGraph pointingDeviceDownEvent:theEvent atPoint:pointInHostedGraph];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    CPTGraph *theGraph = self.hostedGraph;

    if ( theGraph ) {
        CGPoint pointOfMouseDrag   = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
        CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseDrag toLayer:theGraph];
        [theGraph pointingDeviceDraggedEvent:theEvent atPoint:pointInHostedGraph];
    }
}

-(void)mouseUp:(NSEvent *)theEvent
{
    CPTGraph *theGraph = self.hostedGraph;

    if ( theGraph ) {
        CGPoint pointOfMouseUp     = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
        CGPoint pointInHostedGraph = [self.layer convertPoint:pointOfMouseUp toLayer:theGraph];
        [theGraph pointingDeviceUpEvent:theEvent atPoint:pointInHostedGraph];
    }
}

/// @endcond

#pragma mark -
#pragma mark Trackpad handling

/// @cond

-(void)magnifyWithEvent:(NSEvent *)event
{
    CPTGraph *theGraph = self.hostedGraph;

    if ( theGraph ) {
        CGPoint pointOfMagnification = NSPointToCGPoint([self convertPoint:[event locationInWindow] fromView:nil]);
        CGPoint pointInHostedGraph   = [self.layer convertPoint:pointOfMagnification toLayer:theGraph];
        CGPoint pointInPlotArea      = [theGraph convertPoint:pointInHostedGraph toLayer:theGraph.plotAreaFrame.plotArea];

        CGFloat scale = event.magnification + CPTFloat(1.0);

        for ( CPTPlotSpace *space in theGraph.allPlotSpaces ) {
            if ( space.allowsUserInteraction ) {
                [space scaleBy:scale aboutPoint:pointInPlotArea];
            }
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark HiDPI display support

/// @cond

-(void)viewDidChangeBackingProperties
{
    CPTLayer *myLayer  = (CPTLayer *)self.layer;
    NSWindow *myWindow = self.window;

    // backingScaleFactor property is available in MacOS 10.7 and later
    if ( [myWindow respondsToSelector:@selector(backingScaleFactor)] ) {
        myLayer.contentsScale = myWindow.backingScaleFactor;
    }
    else {
        myLayer.contentsScale = CPTFloat(1.0);
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

    if ( plotArea && (closedCursor || openCursor) ) {
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
-(void)plotSpaceAdded:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CPTPlotSpace *space    = userInfo[CPTGraphPlotSpaceNotificationKey];

    [space addObserver:self
            forKeyPath:@"isDragging"
               options:NSKeyValueObservingOptionNew
               context:CPTGraphHostingViewKVOContext];
}

/** @internal
 *  @brief Removes the KVO observer from a plot space removed from the hosted graph.
 **/
-(void)plotSpaceRemoved:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CPTPlotSpace *space    = userInfo[CPTGraphPlotSpaceNotificationKey];

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

/// @endcond

#pragma mark -
#pragma mark KVO Methods

/// @cond

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( context == CPTGraphHostingViewKVOContext ) {
        CPTGraph *theGraph = self.hostedGraph;

        if ( [keyPath isEqualToString:@"isDragging"] && [object isKindOfClass:[CPTPlotSpace class]] ) {
            [self.window invalidateCursorRectsForView:self];
        }
        else if ( [keyPath isEqualToString:@"plotAreaFrame"] && (object == theGraph) ) {
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
        else if ( [keyPath isEqualToString:@"plotArea"] && (object == theGraph.plotAreaFrame) ) {
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
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setHostedGraph:(CPTGraph *)newGraph
{
    NSParameterAssert( (newGraph == nil) || [newGraph isKindOfClass:[CPTGraph class]] );

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

        if ( hostedGraph ) {
            hostedGraph.hostingView = self;

            [self viewDidChangeBackingProperties];
            [self.layer addSublayer:hostedGraph];

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(plotSpaceAdded:)
                                                         name:CPTGraphDidAddPlotSpaceNotification
                                                       object:hostedGraph];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(plotSpaceRemoved:)
                                                         name:CPTGraphDidRemovePlotSpaceNotification
                                                       object:hostedGraph];

            [hostedGraph addObserver:self
                          forKeyPath:@"plotAreaFrame"
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial
                             context:CPTGraphHostingViewKVOContext];

            for ( CPTPlotSpace *space in hostedGraph.allPlotSpaces ) {
                [space addObserver:self
                        forKeyPath:@"isDragging"
                           options:NSKeyValueObservingOptionNew
                           context:CPTGraphHostingViewKVOContext];
            }
        }
    }
}

-(void)setClosedHandCursor:(NSCursor *)newCursor
{
    if ( newCursor != closedHandCursor ) {
        closedHandCursor = newCursor;

        [self.window invalidateCursorRectsForView:self];
    }
}

-(void)setOpenHandCursor:(NSCursor *)newCursor
{
    if ( newCursor != openHandCursor ) {
        openHandCursor = newCursor;

        [self.window invalidateCursorRectsForView:self];
    }
}

/// @endcond

@end
