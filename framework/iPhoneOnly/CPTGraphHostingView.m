#import "CPTGraphHostingView.h"

#import "CPTGraph.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotSpace.h"
#import "NSNumberExtensions.h"

/// @cond
@interface CPTGraphHostingView()

@property (nonatomic, readwrite, cpt_weak_property) cpt_weak UIPinchGestureRecognizer *pinchGestureRecognizer;

-(void)graphNeedsRedraw:(NSNotification *)notification;
-(void)handlePinchGesture:(UIPinchGestureRecognizer *)aPinchGestureRecognizer;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A container view for displaying a CPTGraph.
 **/
@implementation CPTGraphHostingView

/** @property CPTGraph *hostedGraph
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

/** @internal
 *  @property cpt_weak id pinchGestureRecognizer
 *  @brief The pinch gesture recognizer for this view.
 **/
@synthesize pinchGestureRecognizer;

/// @endcond

#pragma mark -
#pragma mark init/dealloc

/// @cond

+(Class)layerClass
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
    self.layer.sublayerTransform = CATransform3DMakeScale( CPTFloat(1.0), CPTFloat(-1.0), CPTFloat(1.0) );
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        [self commonInit];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeBool:self.collapsesLayers forKey:@"CPTGraphHostingView.collapsesLayers"];
    [coder encodeObject:self.hostedGraph forKey:@"CPTGraphHostingView.hostedGraph"];
    [coder encodeBool:self.allowPinchScaling forKey:@"CPTGraphHostingView.allowPinchScaling"];

    // No need to archive these properties:
    // pinchGestureRecognizer
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        [self commonInit];

        collapsesLayers  = [coder decodeBoolForKey:@"CPTGraphHostingView.collapsesLayers"];
        self.hostedGraph = [coder decodeObjectForKey:@"CPTGraphHostingView.hostedGraph"]; // setup layers

        if ( [coder containsValueForKey:@"CPTGraphHostingView.allowPinchScaling"] ) {
            self.allowPinchScaling = [coder decodeBoolForKey:@"CPTGraphHostingView.allowPinchScaling"]; // set gesture recognizer if needed
        }
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Touch handling

/// @cond

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    BOOL handled = NO;

    // Ignore pinch or other multitouch gestures
    if ( [[event allTouches] count] == 1 ) {
        CPTGraph *theHostedGraph = self.hostedGraph;

        theHostedGraph.frame = self.bounds;
        [theHostedGraph layoutIfNeeded];

        CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];

        if ( self.collapsesLayers ) {
            pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
        }
        else {
            pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:theHostedGraph];
        }
        handled = [theHostedGraph pointingDeviceDownEvent:event atPoint:pointOfTouch];
    }

    if ( !handled ) {
        [super touchesBegan:touches withEvent:event];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CPTGraph *theHostedGraph = self.hostedGraph;

    theHostedGraph.frame = self.bounds;
    [theHostedGraph layoutIfNeeded];

    CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];

    if ( self.collapsesLayers ) {
        pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
    }
    else {
        pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:theHostedGraph];
    }
    BOOL handled = [theHostedGraph pointingDeviceDraggedEvent:event atPoint:pointOfTouch];

    if ( !handled ) {
        [super touchesMoved:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CPTGraph *theHostedGraph = self.hostedGraph;

    theHostedGraph.frame = self.bounds;
    [theHostedGraph layoutIfNeeded];

    CGPoint pointOfTouch = [[[event touchesForView:self] anyObject] locationInView:self];

    if ( self.collapsesLayers ) {
        pointOfTouch.y = self.frame.size.height - pointOfTouch.y;
    }
    else {
        pointOfTouch = [self.layer convertPoint:pointOfTouch toLayer:theHostedGraph];
    }
    BOOL handled = [theHostedGraph pointingDeviceUpEvent:event atPoint:pointOfTouch];

    if ( !handled ) {
        [super touchesEnded:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    BOOL handled = [self.hostedGraph pointingDeviceCancelledEvent:event];

    if ( !handled ) {
        [super touchesCancelled:touches withEvent:event];
    }
}

/// @endcond

#pragma mark -
#pragma mark Gestures

/// @cond

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

-(void)handlePinchGesture:(UIPinchGestureRecognizer *)aPinchGestureRecognizer
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

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)drawRect:(CGRect)rect
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

-(void)graphNeedsRedraw:(NSNotification *)notification
{
    [self setNeedsDisplay];
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setHostedGraph:(CPTGraph *)newLayer
{
    NSParameterAssert( (newLayer == nil) || [newLayer isKindOfClass:[CPTGraph class]] );

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
            newLayer.frame = self.layer.bounds;
            [self.layer addSublayer:newLayer];
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
    [super setFrame:newFrame];

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
    [super setBounds:newBounds];

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
