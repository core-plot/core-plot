//
//  CPImage.h
//  CorePlot
//

#import <Foundation/Foundation.h>


@interface CPImage : NSObject <NSCopying> {
    @private
	CGImageRef image;
	BOOL tiled;
}

@property (assign) CGImageRef image;
@property (assign, getter=isTiled) BOOL tiled;

+(CPImage *)imageWithCGImage:(CGImageRef)anImage;

-(id)init;
-(id)copyWithZone:(NSZone *)zone;

-(void)drawInRect:(CGRect)rect inContext:(CGContextRef)context;

@end
