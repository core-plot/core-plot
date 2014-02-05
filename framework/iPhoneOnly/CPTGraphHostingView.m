#import "CPTGraphHostingView.h"

#import "CPTGraph.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotSpace.h"
#import "NSNumberExtensions.h"

/// @cond
@interface CPTGraphHostingView()

@property (nonatomic, readwrite, cpt_weak_property) __cpt_weak UIPinchGestureRecognizer *pinchGestureRecognizer;

-(void)updateNotifications;
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
 *  @property __cpt_weak id pinchGestureRecognizer
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
    hostedGraph     = nil;
    collapsesLayers = NO;

    self.backgroundColor = [UIColor clearColor];

    self.allowPinchScaling = YES;

    // This undoes the normal coordinate space inversion that UIViews apply to their layers
    self.layer.sublayerTransform = CATransform3DMakeScale( CPTFloat(1.0), CPTFloat(-1.0), CPTFloat(1.0) );
}

-(id)initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
        [self commonInit];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [hostedGraph release];
    [super dealloc];
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

-(id)initWithCoder:(NSCoder *)coder
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Ignore pinch or other multitouch gestures
    if ( [[event allTouches] count] > 1 ) {
        return;
    }

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
    [theHostedGraph pointingDeviceDownEvent:event atPoint:pointOfTouch];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
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
    [theHostedGraph pointingDeviceDraggedEvent:event atPoint:pointOfTouch];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
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
    [theHostedGraph pointingDeviceUpEvent:event atPoint:pointOfTouch];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.hostedGraph pointingDeviceCancelledEvent:event];
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
            Class pinchClass = NSClassFromString(@"UIPinchGestureRecognizer");
            if ( pinchClass ) {
                pinchGestureRecognizer = [[pinchClass alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
                [self addGestureRecognizer:pinchGestureRecognizer];
                [pinchGestureRecognizer release];
            }
        }
        else {
            if ( pinchGestureRecognizer ) {
                [self removeGestureRecognizer:pinchGestureRecognizer];
            }
            pinchGestureRecognizer = nil;
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

    for ( CPTPlotSpace *space in theHostedGraph.allPlotSpaces ) {
        if ( space.allowsUserInteraction ) {
            [space scaleBy:[[pinchGestureRecognizer valueForKey:@"scale"] cgFloatValue] aboutPoint:pointInPlotArea];
        }
    }

    [pinchGestureRecognizer setScale:CPTFloat(1.0)];
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

-(void)updateNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ( self.collapsesLayers ) {
        CPTGraph *theHostedGraph = self.hostedGraph;
        if ( theHostedGraph ) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(graphNeedsRedraw:)
                                                         name:CPTGraphNeedsRedrawNotification
                                                       object:theHostedGraph];
        }
    }
}

-(void)setHostedGraph:(CPTGraph *)newLayer
{
    NSParameterAssert( (newLayer == nil) || [newLayer isKindOfClass:[CPTGraph class]] );

    if ( newLayer == hostedGraph ) {
        return;
    }

    [hostedGraph removeFromSuperlayer];
    hostedGraph.hostingView = nil;
    [hostedGraph release];
    hostedGraph = [newLayer retain];

    // Screen scaling
    UIScreen *screen = [UIScreen mainScreen];
    // scale property is available in iOS 4.0 and later
    if ( [screen respondsToSelector:@selector(scale)] ) {
        hostedGraph.contentsScale = screen.scale;
    }
    else {
        hostedGraph.contentsScale = (CGFloat)1.0;
    }
    hostedGraph.hostingView = self;

    if ( self.collapsesLayers ) {
        [self setNeedsDisplay];
    }
    else {
        if ( hostedGraph ) {
            hostedGraph.frame = self.layer.bounds;
            [self.layer addSublayer:hostedGraph];
        }
    }

    [self updateNotifications];
}

-(void)setCollapsesLayers:(BOOL)collapse
{
    if ( collapse != collapsesLayers ) {
        collapsesLayers = collapse;

        CPTGraph *theHostedGraph = self.hostedGraph;

        if ( collapsesLayers ) {
            [theHostedGraph removeFromSuperlayer];
            [self setNeedsDisplay];
        }
        else {
            if ( theHostedGraph ) {
                [self.layer addSublayer:theHostedGraph];
            }
        }
        [self updateNotifications];
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
