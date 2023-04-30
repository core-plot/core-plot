#define CPT_IS_FRAMEWORK

#import <TargetConditionals.h>

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE || TARGET_OS_MACCATALYST

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#else

#import <Cocoa/Cocoa.h>

#endif

#import <CorePlot/_CPTAxisLabelGroup.h>
#import <CorePlot/_CPTGridLineGroup.h>
#import <CorePlot/_CPTGridLines.h>
#import <CorePlot/_CPTPlotGroup.h>

#import <CorePlot/_CPTConstraintsFixed.h>
#import <CorePlot/_CPTConstraintsRelative.h>

#import <CorePlot/_CPTFillColor.h>
#import <CorePlot/_CPTFillGradient.h>
#import <CorePlot/_CPTFillImage.h>

#import <CorePlot/_CPTDarkGradientTheme.h>
#import <CorePlot/_CPTPlainBlackTheme.h>
#import <CorePlot/_CPTPlainWhiteTheme.h>
#import <CorePlot/_CPTSlateTheme.h>
#import <CorePlot/_CPTStocksTheme.h>

#import <CorePlot/_NSCoderExtensions.h>
#import <CorePlot/_NSDecimalNumberExtensions.h>
#import <CorePlot/_NSNumberExtensions.h>
