#import "CPTheme.h"
#import <Foundation/Foundation.h>

@class CPXYGraph;
@class CPPlotArea;
@class CPXYAxisSet;

@interface CPDarkGradientTheme : CPTheme {

}

@end

@interface CPDarkGradientTheme(Protected)

-(void)applyThemeToBackground:(CPXYGraph *)graph;
-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea;
-(void)applyThemeToAxisSet:(CPXYAxisSet *)axisSet; 

@end