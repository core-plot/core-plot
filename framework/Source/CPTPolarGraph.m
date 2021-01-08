#import "CPTPolarGraph.h"

#import "CPTPolarAxis.h"
#import "CPTPolarAxisSet.h"
#import "CPTPolarPlotSpace.h"

/// @cond
@interface CPTPolarGraph()

@property (nonatomic, readwrite, assign) CPTScaleType majorScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType minorScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType radialScaleType;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A graph using a cartesian (Polar) plot space.
 **/
@implementation CPTPolarGraph

/** @property CPTScaleType xScaleType
 *  @brief The scale type for the x-axis.
 **/
@synthesize majorScaleType;

/** @property CPTScaleType yScaleType
 *  @brief The scale type for the y-axis.
 **/
@synthesize minorScaleType;

/** @property CPTScaleType zScaleType
 *  @brief The scale type for the z-axis.
 **/
@synthesize radialScaleType;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPolarGraph object with the provided frame rectangle and scale types.
 *
 *  This is the designated initializer.
 *
 *  @param newFrame The frame rectangle.
 *  @param newMajorScaleType The scale type for the major-axis.
 *  @param newMinorScaleType The scale type for the minor-axis.
 *  @param newRadialScaleType The scale type for the radial-axis.
 *  @return The initialized CPTPolarGraph object.
 **/
-(nonnull instancetype)initWithFrame:(CGRect)newFrame majorScaleType:(CPTScaleType)newMajorScaleType minorScaleType:(CPTScaleType)newMinorScaleType
{
    if ( (self = [self initWithFrame:newFrame]) ) {
        majorScaleType = newMajorScaleType;
        minorScaleType = newMinorScaleType;
        radialScaleType = CPTScaleTypeLinear; // always linear
    }
    return self;
}

/** @brief Initializes a newly allocated CPTPolarGraph object with the provided frame rectangle.
 *
 *  The initialized layer will have the following properties:
 *  - @link CPTPolarPlotSpace::majorScaleType majorScaleType @endlink = #CPTScaleTypeLinear
 *  - @link CPTPolarPlotSpace::minorScaleType minorScaleType @endlink = #CPTScaleTypeLinear
 *  - @link CPTPolarPlotSpace::radialScaleType radialScaleType @endlink = #CPTScaleTypeLinear
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTPolarGraph object.
 *  @see @link CPTPolarGraph::initWithFrame:majorScaleType:minorScaleType:radialScaleType: -initWithFrame:majorScaleType:minorScaleType:radialScaleType: @endlink
 **/
-(nonnull instancetype)initWithFrame:(CGRect)newFrame
{
    if ((self = [super initWithFrame:newFrame])) {
        majorScaleType = CPTScaleTypeLinear;
        minorScaleType = CPTScaleTypeLinear;
        radialScaleType = CPTScaleTypeLinear;
    }
    return self;
}

/// @}

/// @cond

-(nonnull instancetype)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTPolarGraph *theLayer = (CPTPolarGraph *)layer;

        majorScaleType = theLayer->majorScaleType;
        minorScaleType = theLayer->minorScaleType;
        radialScaleType = theLayer->radialScaleType;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeInteger:self.majorScaleType forKey:@"CPTPolarGraph.majorScaleType"];
    [coder encodeInteger:self.minorScaleType forKey:@"CPTPolarGraph.minorScaleType"];
    [coder encodeInteger:self.radialScaleType forKey:@"CPTPolarGraph.radialScaleType"];
}

-(nullable instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        majorScaleType = (CPTScaleType)[coder decodeIntForKey : @"CPTPolarGraph.majorScaleType"];
        minorScaleType = (CPTScaleType)[coder decodeIntForKey : @"CPTPolarGraph.minorScaleType"];
        radialScaleType = (CPTScaleType)[coder decodeIntForKey : @"CPTPolarGraph.radialScaleType"];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Factory Methods

/// @cond

-(CPTPlotSpace *)newPlotSpace
{
    CPTPolarPlotSpace *space = [[CPTPolarPlotSpace alloc] init];

    space.majorScaleType = self.majorScaleType;
    space.minorScaleType = self.minorScaleType;
    
    return space;
}

-(CPTAxisSet *)newAxisSet
{
    CPTPolarAxisSet *newAxisSet = [(CPTPolarAxisSet *)[CPTPolarAxisSet alloc] initWithFrame:self.bounds];

    newAxisSet.majorAxis.plotSpace = self.defaultPlotSpace;
    newAxisSet.minorAxis.plotSpace = self.defaultPlotSpace;
    newAxisSet.radialAxis.plotSpace = self.defaultPlotSpace;
    return newAxisSet;
}

/// @endcond

@end
