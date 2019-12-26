//
// PlotGalleryController.m
// CorePlotGallery
//

#import "PlotGalleryController.h"

#import "dlfcn.h"
#import "PlotViewItem.h"

static const CGFloat CPT_SPLIT_VIEW_MIN_LHS_WIDTH = 150.0;

static NSString *const kThemeTableViewControllerNoTheme      = @"None";
static NSString *const kThemeTableViewControllerDefaultTheme = @"Default";

static NSString *const kCollectionHeader = @"CPTCollectionHeader";
static NSString *const kCollectionItem   = @"PlotViewItem";

@interface PlotGalleryController()

@property (nonatomic, readwrite, strong, nullable) IBOutlet NSSplitView *splitView;
@property (nonatomic, readwrite, strong, nullable) IBOutlet NSScrollView *scrollView;
@property (nonatomic, readwrite, strong, nullable) IBOutlet NSCollectionView *imageBrowser;
@property (nonatomic, readwrite, strong, nullable) IBOutlet NSPopUpButton *themePopUpButton;

@property (nonatomic, readwrite, strong, nullable) IBOutlet PlotView *hostingView;

@end

#pragma mark -

@implementation PlotGalleryController

@synthesize splitView;
@synthesize scrollView;
@synthesize imageBrowser;
@synthesize themePopUpButton;

@synthesize hostingView;

@synthesize plotItem;
@synthesize currentThemeName;

-(void)setupThemes
{
    [self.themePopUpButton addItemWithTitle:kThemeTableViewControllerDefaultTheme];
    [self.themePopUpButton addItemWithTitle:kThemeTableViewControllerNoTheme];

    for ( Class c in [CPTTheme themeClasses] ) {
        [self.themePopUpButton addItemWithTitle:[c name]];
    }

    self.currentThemeName = kThemeTableViewControllerDefaultTheme;
    [self.themePopUpButton selectItemWithTitle:kThemeTableViewControllerDefaultTheme];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    [[PlotGallery sharedPlotGallery] sortByTitle];

    self.splitView.delegate = self;

    NSCollectionView *browser = self.imageBrowser;

    browser.delegate   = self;
    browser.dataSource = self;

    [browser registerClass:[NSTextField class]
     forSupplementaryViewOfKind:NSCollectionElementKindSectionHeader
                 withIdentifier:kCollectionHeader];

    [browser reloadData];

    self.hostingView.delegate = self;

    [self setupThemes];
}

-(void)dealloc
{
    [self setPlotItem:nil];

    splitView.delegate      = nil;
    imageBrowser.dataSource = nil;
    imageBrowser.delegate   = nil;
    hostingView.delegate    = nil;
}

-(void)setFrameSize:(NSSize)newSize
{
    if ( [self.plotItem respondsToSelector:@selector(setFrameSize:)] ) {
        [self.plotItem setFrameSize:newSize];
    }
}

#pragma mark -
#pragma mark Theme Selection

-(nullable CPTTheme *)currentTheme
{
    CPTTheme *theme;

    if ( [self.currentThemeName isEqualToString:kThemeTableViewControllerNoTheme] ) {
        theme = (id)[NSNull null];
    }
    else if ( [self.currentThemeName isEqualToString:kThemeTableViewControllerDefaultTheme] ) {
        theme = nil;
    }
    else {
        theme = [CPTTheme themeNamed:self.currentThemeName];
    }

    return theme;
}

-(IBAction)themeSelectionDidChange:(nonnull id)sender
{
    self.currentThemeName = [sender titleOfSelectedItem];

    PlotView *hostView = self.hostingView;
    if ( hostView ) {
        [self.plotItem renderInView:hostView withTheme:[self currentTheme] animated:YES];
    }
}

#pragma mark -
#pragma mark Export Images

-(void)exportTVImageWithSize:(CGSize)size toURL:(NSURL *)url showPlots:(BOOL)showPlots showBackground:(BOOL)showBackground
{
    if ( url ) {
        CGRect imageFrame = CGRectMake(0.0, 0.0, size.width, size.height);

        NSView *imageView = [[NSView alloc] initWithFrame:NSRectFromCGRect(imageFrame)];
        [imageView setWantsLayer:YES];

        [self.plotItem renderInView:imageView withTheme:nil animated:NO];

        if ( !showBackground ) {
            for ( CPTGraphHostingView *view in imageView.subviews ) {
                CPTGraph *graph = view.hostedGraph;

                graph.fill    = [CPTFill fillWithColor:[CPTColor clearColor]];
                graph.axisSet = nil;

                graph.plotAreaFrame.fill            = [CPTFill fillWithColor:[CPTColor clearColor]];
                graph.plotAreaFrame.borderLineStyle = nil;

                graph.plotAreaFrame.plotArea.fill            = [CPTFill fillWithColor:[CPTColor clearColor]];
                graph.plotAreaFrame.plotArea.borderLineStyle = nil;
            }
        }

        if ( !showPlots ) {
            for ( CPTGraphHostingView *view in imageView.subviews ) {
                for ( CPTPlot *plot in view.hostedGraph.allPlots ) {
                    plot.hidden = YES;
                }
            }
        }

        CGSize boundsSize = imageFrame.size;

        NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc]
                                        initWithBitmapDataPlanes:NULL
                                                      pixelsWide:(NSInteger)boundsSize.width
                                                      pixelsHigh:(NSInteger)boundsSize.height
                                                   bitsPerSample:8
                                                 samplesPerPixel:4
                                                        hasAlpha:YES
                                                        isPlanar:NO
                                                  colorSpaceName:NSCalibratedRGBColorSpace
                                                     bytesPerRow:(NSInteger)boundsSize.width * 4
                                                    bitsPerPixel:32];

        NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
        CGContextRef context             = (CGContextRef)bitmapContext.graphicsPort;

        CGContextClearRect(context, CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height));
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldSmoothFonts(context, false);
        [imageView.layer renderInContext:context];
        CGContextFlush(context);

        NSImage *image = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
        [image addRepresentation:layerImage];

        NSData *tiffData          = image.TIFFRepresentation;
        NSBitmapImageRep *tiffRep = [NSBitmapImageRep imageRepWithData:tiffData];
        NSData *pngData           = [tiffRep representationUsingType:NSPNGFileType properties:@{}];

        [pngData writeToURL:url atomically:NO];
    }
}

-(IBAction)exportTVImagesToPNG:(id)sender
{
    NSOpenPanel *pngSavingDialog = [NSOpenPanel openPanel];

    pngSavingDialog.canChooseFiles          = NO;
    pngSavingDialog.canChooseDirectories    = YES;
    pngSavingDialog.allowsMultipleSelection = NO;

    if ( [pngSavingDialog runModal] == NSModalResponseOK ) {
        NSURL *url = pngSavingDialog.URL;
        if ( url ) {
// top image
            CGSize topShelfSize = CGSizeMake(1920.0, 720.0);

            NSURL *topURL = [NSURL URLWithString:@"PlotGalleryTopShelf.png" relativeToURL:url];
            [self exportTVImageWithSize:topShelfSize toURL:topURL showPlots:YES showBackground:YES];

// large icon image
            CGSize largeIconSize = CGSizeMake(1280.0, 768.0);

            NSURL *largeBackURL = [NSURL URLWithString:@"PlotGalleryLargeIconBack.png" relativeToURL:url];
            [self exportTVImageWithSize:largeIconSize toURL:largeBackURL showPlots:NO showBackground:YES];

            NSURL *largeFrontURL = [NSURL URLWithString:@"PlotGalleryLargeIconFront.png" relativeToURL:url];
            [self exportTVImageWithSize:largeIconSize toURL:largeFrontURL showPlots:YES showBackground:NO];

// small icon image
            CGSize smallIconSize = CGSizeMake(400.0, 240.0);

            NSURL *smallBackURL = [NSURL URLWithString:@"PlotGallerySmallIconBack.png" relativeToURL:url];
            [self exportTVImageWithSize:smallIconSize toURL:smallBackURL showPlots:NO showBackground:YES];

            NSURL *smallFrontURL = [NSURL URLWithString:@"PlotGallerySmallIconFront.png" relativeToURL:url];
            [self exportTVImageWithSize:smallIconSize toURL:smallFrontURL showPlots:YES showBackground:NO];
        }
    }
}

#pragma mark -
#pragma mark PlotItem Property

-(void)setPlotItem:(nullable PlotItem *)item
{
    if ( plotItem != item ) {
        [plotItem killGraph];

        plotItem = item;

        PlotView *hostView = self.hostingView;
        if ( hostView ) {
            [plotItem renderInView:hostView withTheme:[self currentTheme] animated:YES];
        }
    }
}

#pragma mark -
#pragma mark NSCollectionViewDataSource methods

-(NSInteger)numberOfSectionsInCollectionView:(nonnull NSCollectionView *)collectionView;
{
    return (NSInteger)[PlotGallery sharedPlotGallery].numberOfSections;
}

-(NSInteger)collectionView:(nonnull NSCollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return (NSInteger)[[PlotGallery sharedPlotGallery] numberOfRowsInSection:(NSUInteger)section];
}

-(nonnull NSCollectionViewItem *)collectionView:(nonnull NSCollectionView *)collectionView
            itemForRepresentedObjectAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    PlotViewItem *item = [collectionView makeItemWithIdentifier:kCollectionItem
                                                   forIndexPath:indexPath];

    PlotItem *thePlotItem = [[PlotGallery sharedPlotGallery] objectInSection:(NSUInteger)indexPath.section
                                                                     atIndex:(NSUInteger)indexPath.item];

    item.plotItemTitle.stringValue = thePlotItem.title;
    item.plotItemImage.image       = thePlotItem.image;

    return item;
}

-(nonnull NSView *)    collectionView:(nonnull NSCollectionView *)collectionView
    viewForSupplementaryElementOfKind:(nonnull NSCollectionViewSupplementaryElementKind)kind
                          atIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSString *identifier = nil;

    if ( [kind isEqual:NSCollectionElementKindSectionHeader] ) {
        identifier = kCollectionHeader;
    }
    else {
        identifier = @"";
    }

    NSString *content = [PlotGallery sharedPlotGallery].sectionTitles[(NSUInteger)indexPath.section];

    NSView *view = [collectionView makeSupplementaryViewOfKind:kind withIdentifier:identifier forIndexPath:indexPath];
    if ( content && [view isKindOfClass:[NSTextField class]] ) {
        NSTextField *titleTextField = (NSTextField *)view;

        titleTextField.editable        = NO;
        titleTextField.selectable      = NO;
        titleTextField.backgroundColor = [NSColor controlAccentColor];
        titleTextField.textColor       = [NSColor headerTextColor];
        titleTextField.font            = [NSFont boldSystemFontOfSize:14.0];
        titleTextField.bordered        = YES;
        titleTextField.stringValue     = content;
    }

    return view;
}

#pragma mark -
#pragma mark NSCollectionViewDelegate methods

-(void)         collectionView:(nonnull NSCollectionView *)collectionView
    didSelectItemsAtIndexPaths:(nonnull NSSet<NSIndexPath *> *)indexPaths
{
    NSUInteger section = NSNotFound;
    NSUInteger index   = NSNotFound;
    NSIndexPath *path  = indexPaths.allObjects.firstObject;

    if ( path ) {
        section = (NSUInteger)path.section;
        index   = (NSUInteger)path.item;
    }

    if ( index != NSNotFound ) {
        self.plotItem = [[PlotGallery sharedPlotGallery] objectInSection:section atIndex:index];
    }
}

#pragma mark -
#pragma mark NSSplitViewDelegate methods

-(CGFloat)       splitView:(nonnull NSSplitView *)sv
    constrainMinCoordinate:(CGFloat)coord
               ofSubviewAt:(NSInteger)index
{
    return coord + CPT_SPLIT_VIEW_MIN_LHS_WIDTH;
}

-(CGFloat)       splitView:(nonnull NSSplitView *)sv
    constrainMaxCoordinate:(CGFloat)coord
               ofSubviewAt:(NSInteger)index
{
    return coord - CPT_SPLIT_VIEW_MIN_LHS_WIDTH;
}

-(void)             splitView:(nonnull NSSplitView *)sender
    resizeSubviewsWithOldSize:(NSSize)oldSize
{
// Lock the LHS width
    NSRect frame   = sender.frame;
    NSView *lhs    = sender.subviews[0];
    NSRect lhsRect = lhs.frame;
    NSView *rhs    = sender.subviews[1];
    NSRect rhsRect = rhs.frame;

    CGFloat dividerThickness = sender.dividerThickness;

    lhsRect.size.height = frame.size.height;

    rhsRect.size.width  = frame.size.width - lhsRect.size.width - dividerThickness;
    rhsRect.size.height = frame.size.height;
    rhsRect.origin.x    = lhsRect.size.width + dividerThickness;

    lhs.frame = lhsRect;
    rhs.frame = rhsRect;
}

@end
