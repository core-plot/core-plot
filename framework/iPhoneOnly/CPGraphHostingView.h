#import <UIKit/UIKit.h>

@class CPGraph;

@interface CPGraphHostingView : UIView {
	@protected
	CPGraph *hostedGraph;
	BOOL collapsesLayers;
}

@property (nonatomic, readwrite, retain) CPGraph *hostedGraph;
@property (nonatomic, readwrite, assign) BOOL collapsesLayers;

@end
