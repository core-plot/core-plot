#import "CPTheme.h"
#import <Foundation/Foundation.h>

@interface CPDarkGradientTheme : CPTheme {

}

-(void)applyThemeToBackground:(CPXYGraph *)graph;
-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea;
-(void)applyThemeToAxisSet:(CPAxisSet *)axisSet; 

@end
