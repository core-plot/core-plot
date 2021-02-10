//
//  CPTPolarPlotSpaceAnnotation.m
//  CorePlot iOS/Mac
//
//  Created by Steve Wainwright on 10/12/2020.
//

#import "CPTPolarPlotSpaceAnnotation.h"

#import "CPTExceptions.h"
#import "CPTUtilities.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPolarPlotSpace.h"

/// @cond

@interface CPTPolarPlotSpaceAnnotation()

@property (nonatomic, readwrite, nonnull) NSDecimal *decimalAnchor;
@property (nonatomic, readwrite) NSUInteger anchorCount;

-(void)setContentNeedsLayout;

@end

/// @endcond

#pragma mark -

/** @brief Positions a content layer relative to some anchor point in a plot space.
 *
 *  Plot space annotations are positioned relative to a plot space. This allows the
 *  annotation content layer to move with the plot when the plot space changes.
 *  This is useful for applications such as labels attached to specific data points on a plot.
 **/
@implementation CPTPolarPlotSpaceAnnotation

/** @property nullable CPTNumberArray *anchorPlotPoint
 *  @brief An array of NSDecimalNumber objects giving the anchor plot coordinates.
 **/
@synthesize anchorPlotPoint;

/** @property nonnull CPTPlotSpace *plotSpace
 *  @brief The plot space which the anchor is defined in.
 **/
@synthesize plotSpace;

@synthesize decimalAnchor;
@synthesize anchorCount;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPlotSpaceAnnotation object.
 *
 *  This is the designated initializer. The initialized layer will be anchored to
 *  a point in plot coordinates.
 *
 *  @param newPlotSpace The plot space which the anchor is defined in. Must be non-@nil.
 *  @param newPlotPoint An array of NSDecimalNumber objects giving the anchor plot coordinates.
 *  @return The initialized CPTPlotSpaceAnnotation object.
 **/
-(nonnull instancetype)initWithPlotSpace:(nonnull CPTPolarPlotSpace *)newPlotSpace anchorPlotPoint:(nullable CPTNumberArray *)newPlotPoint
{
    NSParameterAssert(newPlotSpace);

    if ( (self = [super init]) ) {
        plotSpace            = newPlotSpace;
//        if ( plotSpace.radialAngleOption == CPTPolarRadialAngleModeDegrees && newPlotPoint != nil ) {
//            NSNumber *theta = newPlotPoint[0];
//            theta = [NSNumber numberWithDouble: [theta doubleValue] * M_PI / 180.0];
//            CPTNumberArray *adjustedNewPlotPoint = [CPTNumberArray arrayWithObjects: theta, newPlotPoint[1], nil];
//            self.anchorPlotPoint = adjustedNewPlotPoint;
//        }
//        else {
            self.anchorPlotPoint = newPlotPoint;
//        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setContentNeedsLayout)
                                                     name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                   object:plotSpace];
    }
    return self;
}

/// @}

/// @cond

// plotSpace is required
-(nonnull instancetype)init
{
    [NSException raise:CPTException format:@"%@ must be initialized with a plot space.", NSStringFromClass([self class])];
    return [self initWithPlotSpace:[[CPTPolarPlotSpace alloc] init] anchorPlotPoint:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    free(decimalAnchor);
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.anchorPlotPoint forKey:@"CPTPolarPlotSpaceAnnotation.anchorPlotPoint"];
    [coder encodeConditionalObject:self.plotSpace forKey:@"CPTPolarPlotSpaceAnnotation.plotSpace"];
}

/// @endcond

/** @brief Returns an object initialized from data in a given unarchiver.
 *  @param coder An unarchiver object.
 *  @return An object initialized from data in a given unarchiver.
 */
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        self.anchorPlotPoint = [[coder decodeObjectOfClasses:[NSSet setWithArray:@[[NSArray class], [NSNumber class]]]
                                                      forKey:@"CPTPolarPlotSpaceAnnotation.anchorPlotPoint"] copy];

        CPTPolarPlotSpace *thePlotSpace = [coder decodeObjectOfClass:[CPTPolarPlotSpace class]
                                                         forKey:@"CPTPolarPlotSpaceAnnotation.plotSpace"];
        if ( thePlotSpace ) {
            plotSpace = thePlotSpace;

            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(setContentNeedsLayout)
                                                         name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                       object:plotSpace];
        }
    }
    return self;
}

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

#pragma mark -
#pragma mark Layout

/// @cond

-(void)setContentNeedsLayout
{
    [self.contentLayer.superlayer setNeedsLayout];
}

-(void)positionContentLayer
{
    CPTLayer *content = self.contentLayer;

    if ( content ) {
        CPTLayer *hostLayer = self.annotationHostLayer;
        if ( hostLayer ) {
            CPTNumberArray *plotAnchor = self.anchorPlotPoint;
            if ( plotAnchor ) {
                // Get plot area point
                CPTPolarPlotSpace *thePlotSpace      = self.plotSpace;

                double theta = CPTDecimalDoubleValue(self.decimalAnchor[0]);
                if (thePlotSpace.radialAngleOption == CPTPolarRadialAngleModeDegrees) {
                    theta *= M_PI / 180.0;
                }
                
                double plotPoint[2];
                plotPoint[CPTCoordinateX] = CPTDecimalDoubleValue(self.decimalAnchor[1]);
                plotPoint[CPTCoordinateY] = 0.0;
                
                double centrePlotPoint[2];
                centrePlotPoint[CPTCoordinateX] = 0.0;
                centrePlotPoint[CPTCoordinateY] = 0.0;
                
                CGPoint centrePoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:centrePlotPoint numberOfCoordinates:self.anchorCount];
                CGPoint plotAreaViewAnchorPoint = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint numberOfCoordinates:2];
                plotAreaViewAnchorPoint = CPTPointMake((plotAreaViewAnchorPoint.x - centrePoint.x) * sin(theta) + centrePoint.x, (plotAreaViewAnchorPoint.x - centrePoint.x) * cos(theta) + centrePoint.y);
                
//                CGPoint plotAreaViewAnchorPoint = [thePlotSpace plotAreaViewPointForPlotPoint:self.decimalAnchor numberOfCoordinates:self.anchorCount];
                

                CGPoint newPosition;
                CPTGraph *theGraph    = thePlotSpace.graph;
                CPTPlotArea *plotArea = theGraph.plotAreaFrame.plotArea;
                if ( plotArea ) {
                    newPosition = [plotArea convertPoint:plotAreaViewAnchorPoint toLayer:hostLayer];
                }
                else {
                    newPosition = CGPointZero;
                }
                CGPoint offset = self.displacement;
                newPosition.x += offset.x;
                newPosition.y += offset.y;

                content.anchorPoint = self.contentAnchorPoint;
                content.position    = newPosition;
                content.transform   = CATransform3DMakeRotation(self.rotation, CPTFloat(0.0), CPTFloat(0.0), CPTFloat(1.0) );
                [content pixelAlign];
            }
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setAnchorPlotPoint:(nullable CPTNumberArray *)newPlotPoint
{
    if ( anchorPlotPoint != newPlotPoint ) {
        anchorPlotPoint = [newPlotPoint copy];

        self.anchorCount = anchorPlotPoint.count;

        NSDecimal *decimalPoint = calloc(self.anchorCount, sizeof(NSDecimal) );
        for ( NSUInteger i = 0; i < self.anchorCount; i++ ) {
            decimalPoint[i] = anchorPlotPoint[i].decimalValue;
        }
        self.decimalAnchor = decimalPoint;

        [self setContentNeedsLayout];
    }
}

-(void)setDecimalAnchor:(nonnull NSDecimal *)newAnchor
{
    if ( decimalAnchor != newAnchor ) {
        free(decimalAnchor);
        decimalAnchor = newAnchor;
    }
}

/// @endcond

@end
