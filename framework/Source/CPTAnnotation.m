#import "CPTAnnotation.h"

#import "CPTAnnotationHostLayer.h"
#import "CPTLayer.h"
#import "NSCoderExtensions.h"

/**	@brief An annotation positions a content layer relative to some anchor point.
 *
 *	Annotations can be used to add text or images that are anchored to a feature
 *	of a graph. For example, the graph title is an annotation anchored to the graph.
 *	The annotation content layer can be any CPTLayer.
 **/
@implementation CPTAnnotation

/**	@property contentLayer
 *	@brief The annotation content.
 **/
@synthesize contentLayer;

/**	@property annotationHostLayer
 *	@brief The host layer for the annotation content.
 **/
@synthesize annotationHostLayer;

/**	@property displacement
 *	@brief The displacement from the layer anchor point.
 **/
@synthesize displacement;

/**	@property contentAnchorPoint
 *	@brief The anchor point for the content layer.
 **/
@synthesize contentAnchorPoint;

/**	@property rotation
 *	@brief The rotation of the label in radians.
 **/
@synthesize rotation;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if ( (self = [super init]) ) {
		annotationHostLayer = nil;
		contentLayer		= nil;
		displacement		= CGPointZero;
		contentAnchorPoint	= CGPointMake(0.5, 0.5);
		rotation			= 0.0;
	}
	return self;
}

-(void)dealloc
{
	[contentLayer release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeConditionalObject:self.annotationHostLayer forKey:@"CPTAnnotation.annotationHostLayer"];
	[coder encodeObject:self.contentLayer forKey:@"CPTAnnotation.contentLayer"];
	[coder encodeCPTPoint:self.contentAnchorPoint forKey:@"CPTAnnotation.contentAnchorPoint"];
	[coder encodeCPTPoint:self.displacement forKey:@"CPTAnnotation.displacement"];
	[coder encodeCGFloat:self.rotation forKey:@"CPTAnnotation.rotation"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		annotationHostLayer = [coder decodeObjectForKey:@"CPTAnnotation.annotationHostLayer"];
		contentLayer		= [[coder decodeObjectForKey:@"CPTAnnotation.contentLayer"] retain];
		contentAnchorPoint	= [coder decodeCPTPointForKey:@"CPTAnnotation.contentAnchorPoint"];
		displacement		= [coder decodeCPTPointForKey:@"CPTAnnotation.displacement"];
		rotation			= [coder decodeCGFloatForKey:@"CPTAnnotation.rotation"];
	}
	return self;
}

#pragma mark -
#pragma mark Description

-(NSString *)description
{
	return [NSString stringWithFormat:@"<%@ {%@}>", [super description], self.contentLayer];
}

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setContentLayer:(CPTLayer *)newLayer
{
	if ( newLayer != contentLayer ) {
		[contentLayer removeFromSuperlayer];
		[contentLayer release];
		contentLayer = [newLayer retain];
		if ( contentLayer ) {
			[annotationHostLayer addSublayer:contentLayer];
		}
	}
}

-(void)setAnnotationHostLayer:(CPTAnnotationHostLayer *)newLayer
{
	if ( newLayer != annotationHostLayer ) {
		[contentLayer removeFromSuperlayer];
		annotationHostLayer = newLayer;
		if ( contentLayer ) {
			[annotationHostLayer addSublayer:contentLayer];
		}
	}
}

-(void)setDisplacement:(CGPoint)newDisplacement
{
	if ( !CGPointEqualToPoint(newDisplacement, displacement) ) {
		displacement = newDisplacement;
		[[self.contentLayer superlayer] setNeedsLayout];
	}
}

-(void)setContentAnchorPoint:(CGPoint)newAnchorPoint
{
	if ( !CGPointEqualToPoint(newAnchorPoint, contentAnchorPoint) ) {
		contentAnchorPoint = newAnchorPoint;
		[[self.contentLayer superlayer] setNeedsLayout];
	}
}

-(void)setRotation:(CGFloat)newRotation
{
	if ( newRotation != rotation ) {
		rotation = newRotation;
		[[self.contentLayer superlayer] setNeedsLayout];
	}
}

///	@endcond

@end

#pragma mark -
#pragma mark Layout

@implementation CPTAnnotation(AbstractMethods)

/**	@brief Positions the content layer relative to its reference anchor.
 *
 *	This method must be overridden by subclasses. The default implementation
 *	does nothing.
 **/
-(void)positionContentLayer
{
	// Do nothing--implementation provided by subclasses
}

@end
