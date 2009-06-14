
#import "CPTextStyle.h"
#import "CPColor.h"


@implementation CPTextStyle

@synthesize fontSize;
@synthesize fontName;
@synthesize color;

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

#pragma mark -
#pragma mark Copying

-(id)copyWithZone:(NSZone *)zone 
{
	CPTextStyle *newCopy = [[CPTextStyle allocWithZone:zone] init];
	newCopy.fontName = fontName;
	newCopy.color = color;
	newCopy.fontSize = fontSize;
	return newCopy;
}

@end
