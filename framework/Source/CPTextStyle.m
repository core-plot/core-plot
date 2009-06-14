
#import "CPTextStyle.h"
#import "CPColor.h"


@implementation CPTextStyle

@synthesize fontSize;
@synthesize fontName;
@synthesize color;

#pragma mark -
#pragma mark Initialization and teardown

-(id)init 
{
	if ( self = [super init] ) {
		self.fontName = @"Helvetica";
		self.fontSize = 12.0f;
		self.color = [CPColor blackColor];
	}
	return self;
}

-(void)dealloc
{
	self.fontName = nil;
	self.color = nil;
	[super dealloc];
}

+(CPTextStyle *)defaultTextStyle
{
	static CPTextStyle *textStyle = nil;
	
	if ( textStyle == nil ) {
		textStyle = [[self alloc] init];
		textStyle.fontName = @"Helvetica";
		textStyle.fontSize = 12.0f;
		textStyle.color = [CPColor blackColor];
	}
	return textStyle;
}

#pragma mark -
#pragma mark Copying

-(id)copyWithZone:(NSZone *)zone 
{
	CPTextStyle *newCopy = [[CPTextStyle allocWithZone:zone] init];
	newCopy.fontName = self.fontName;
	newCopy.color = self.color;
	newCopy.fontSize = self.fontSize;
	return newCopy;
}

@end
