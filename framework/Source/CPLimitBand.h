#import <Foundation/Foundation.h>

@class CPPlotRange;
@class CPFill;

@interface CPLimitBand : NSObject <NSCoding, NSCopying> {
@private
	CPPlotRange *range;
	CPFill *fill;
}

@property (nonatomic, readwrite, retain) CPPlotRange *range;
@property (nonatomic, readwrite, retain) CPFill *fill;

+(CPLimitBand *)limitBandWithRange:(CPPlotRange *)newRange fill:(CPFill *)newFill;

-(id)initWithRange:(CPPlotRange *)newRange fill:(CPFill *)newFill;

@end
