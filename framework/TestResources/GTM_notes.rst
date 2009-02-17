---------------------------------------------------
The Google Mac Toolbox for unit testing and logging
---------------------------------------------------


The toolbox
-----------

The `Google Mac Toolbox <http://code.google.com/p/google-toolbox-for-mac/>`_ (GMT) is a collection of additions for Cocoa and CocoaTouch, a set of (in-code) debugging utilties, a logging framework, and additions to the OCUnit framework for Cocoa and an implementation of a unit testing framework for the iPhone SDK. The code is released under the 
`Apache License <http://www.apache.org/licenses/LICENSE-2.0>`_, version 2.0.

The Cocoa additions are primarily directed at (1) providing Leopard-style behavior to pre-Leopard SDKs (such as NSTableView's `-tableView:dataCellForTableColumn:row`) and stubs so that code using garbage collection and Objective-C 2.0-isms can compile on pre-10.5 SDKs and (2) webby stuff such as XML and URL escaping.

Although the GMT can be compiled as a framework, the stated intention is that individual classes be incorporated directly into other projects. There are very few within-framework dependencies, facilitating this take-it-as-you-wish approach [1]_.

Benefits for CorePlot
---------------------

Based on my review of the GTM, I believe that adding a dependency on the GTM provides two major benefits for the CorePlot project (in order of importance):

1. The GTM provides a major set of testing infrastructure that allows testing UI (``NSView`` and ``CALayer``) state (e.g button state, label values, etc.) *and* output (i.e. pixel-level drawing) with very little developer overhead. If views are bound to model data, then a test which changes the model data can easily assert that the UI state is correctly updated as compared to a previously saved state *and* that the rendered output of the view/layer is correct as compared to a previously saved state. If there is no saved value for the state or rendered output, one is generated. If there is a descrepancy between actual and expected state or rendered output, the GTM test apparatus generates a file that describes the differences and saves the actual state or rendered output so that it can easily be used as the future expected state or output. Thus *even if code evolves to invalidate the previously saved state or rendered output*, the test can be "caught up" with the code at any time by replacing the saved state and rendered output witht the currently generated state and rendered output. More on this awesome test capability, with details on implementation and use below.

2. The GTM logging framework is a nice Objective-C wrapping on the Apple System Logger (ASL), providing multiple log levels and log-level filtering (debug logs are automatically skipped in release builds, for example). The logging system can also write to several different outputs (file handles, ASL, stdout, etc.) and can be configured to write to more than one at a time. A shared logger is created automatically and additional logger instances can be created as neede. Instead of using `NSLog`, logs to the shared logger are created using similar, log-level specific macros::

    GTMLoggerDebug(format,...)
    GTMLoggerInfo(format,...)
    GTMLoggerError(format,..)

..

    The logger can be set-up to use the ASL by adding a single line to the application/framework initialization code::
    
        [[GTMLogger sharedLogger] setSharedLogger:[GTMLogger standardLoggerWithASL]];
    

``NSView`` and ``CALayer`` state and rendering tests
----------------------------------------------------

The key benefit of GTM for the CorePlot project is in making it relatively easy to test UI (e.g. control) state and to test rendered output of ``NSView``/``UIView`` and/or ``CALayer`` on both the Mac and iPhone. I'll discuss state and rendering testing separately below, but both rely on saving a file that describes either the state or rendered output of a view/layer hierarchy. I will thus describe this general system first.

State and rendering tests are run by asserting that the actual state or rendering matches a saved state or rendering of a given name. The system locates the saved state or rendered output by name (see below), and the actual state or rendered output is compared against this saved version. Discrepancies indicate test failure. If no file of the given name exists yet, the current (i.e. produced by the test) file is saved. 

The GTM test code searches for state/rendering files by name in the test class' bundle (i.e. the unit test bundle containg the test code). Files, indentified by "name" to the test methdods are searched for in the following order::

    "name.extension", 
    "name.arch.extension", 
    "name.arch.OSVersionMajor.extension"
    "name.arch.OSVersionMajor.OSVersionMinor.extension"
    "name.arch.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.extension"
    "name.arch.OSVersionMajor.extension"
    "name.OSVersionMajor.arch.extension"
    "name.OSVersionMajor.OSVersionMinor.arch.extension"
    "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.arch.extension"
    "name.OSVersionMajor.extension"
    "name.OSVersionMajor.OSVersionMinor.extension"
    "name.OSVersionMajor.OSVersionMinor.OSVersion.bugfix.extension"

Thus, multiple states/renderings can be saved corresponding to different systems etc.

When there is no existing state or rendering, the state/rendering files produced by the test are saved to `saveToDirectory`. Similarly, if a test fails, the actual state/rendering is saved to the same directory. By default this directory is ~/Desktop, but it can be easily set via +[NSObject(GTMUnitTestingAdditions) gtm_setUnitTestSaveToDirectory:]. On automated build systems--or any time that the environment has a variable ending in "BUILD_NUMBER"--the test system uses $BUILT_PRODUCTS_DIRECTORY as the saveToDirectory.

Developers can replace the saved state/rendering with the current one by simply copying the saved file from `saveToDirectory` into the test bundle's Resources directory. **Super easy**.

Now that I've described the way the test system locates the state or rendering to compare agains, I'll describe how state and rendering tests are coded, and how they are implemented by the GTM.

In general, tests will verify both state and rendering out put at the same time using the GTMAssertObjectEqualToStateAndImageNamed(obj, name, description, ...), which calls the state and image assertion macros described below.

**NOTE**: ``NSView`` and ``CALayer`` already provide state and rendering test-capability via GTMCALayer+UnitTesting and GTMAppKit+UnitTesting.

State tests
***********
In order to be state-testable, classes must implement the GTMUnitTestEncoding protocol (-(void)gtm_unitTestEncodeState:(NSCoder*)coder). GTM provides implementations of this protocol for ``NSView`` s and ``CALayer`` s (in GTMCALayer+UnitTesting and GTMAppKit+UnitTesting). These implementations recursively encode the state of the callee and its subviews/sublayers.

Classes may override -(BOOL)gtm_shouldEncodeStateForSublayers or -(BOOL)gtm_shouldEncodeStateForSublayersOfLayer:(``CALayer``*)layer (for layer delegate) or -(BOOL)gtm_shouldEncodeStateForSubviews (for ``NSView``) to indicate whether their subviews/sublayers should be encoded.

Tests may check a tree's (rooted at `obj`) state against the saved state with::

    GTMAssertObjectStateEqualToStateNamed(obj, name, description,...)
    
Really, that's it; there's no more to it.


Rendering tests
***************
In order to be rendering testable, classes must implement the GTMUnitTestImaging protocol. ``NSView`` and ``CALayer`` already do so via GTM categories, as noted above. Basically, conformant instances can render themselves to an image via -gtm_createUnitTestImage. A rendering test can verify that the image is the same as a saved image via::

    GTMAssertObjectImageEqualToImageNamed(obj, name, description, ...)

Classes may provide more control over the rendered image by implementing the GTMUnitTestViewDrawer protocol. In this case tests can call::

    GTMAssertDrawingEqualToImageNamed(obj, size, name, contextInfo, description, ...)
    
This macro instantiates a GTMUnitTestView, which calls obj to draw its unit test image.

Classes overriding gtm_createUnitTestImage may use - (CGContextRef)[NSObject(GTMUnitTesting) gtm_createUnitTestBitmapContextOfSize:(CGSize)size data:(unsigned char**)data] to create a bitmap context for drawing the image, lock focus on the context, then draw themselves, etc.

Like the state tests, ``NSView`` and ``CALayer`` subclasses do not have to do *anything* to provide rendering support.


Other nice testing tools
------------------------

The GTM includes several other nice testing tools. Among them:

1. running the GTM/UnitTesting/RunMacOSUnitTests.sh as the test harness enables memory-error detecting environment variables such as MallocScribbling, MallocGuardEdges, NSAutoreleaseFreedObjectCheckEnabled, etc. and uses the Cocoa debug libraries, if present on the system. It behaves just as the standard OCUnit test harness (e.g. with failures presented as build errors in Xcode etc.).

2. The GTMUnitTestDevLog class allows you to test the logged output from a test. Much like a mock object, you set up the GTMUnitTestLog instance with a set of log messages that you expect to be produced, then run the test, then assert that no unexpected log messages are produced::

    [GTMUnitTestDevLog enableTracking];
    [GTMUnitTestDevLog expectString:my_expected_log_string]; // for exact string matches
    [GTMUnitTestDevLog expectPattern:my_expected_log_regex]; // for regex pattern matches
    
    ... // run test code
    
    [GTMUnitTestDevLog disableTracking];
    
..
    
    The expected logs are reset with::
    
    [GTMUnitTestDevLog resetExpectedLogs]; //e.g. in -setUp
    
..
    
    Any unexpected log messages become failures.
    
3. Inheriting from GTMTestCase instead of SenTestCase gives automatic support for GTMUnitTestDevLog by automatically asserting that no expected logs *failed* to be emitted during a test.

4. If we have a demo application which serves as the test host, modifying main() like this::
    
    #import <Cocoa/Cocoa.h>
    #import "GTMUnitTestingUtilities.h"

    int main(int argc, char *argv[]) {
      [GTMUnitTestingUtilities setUpForUIUnitTestsIfBeingTested];
      return NSApplicationMain(argc,  (const char **) argv);
    }
    
..

    sets up UI preferences (scroll-bar types, selection colors, etc.) for unit testing (regardless of the test computer's settings) and restores the existing settings after exit. Thus, pixel-level rendering tests can be run on any system. Obviously, these changes are not applied if the application is not being run in unit test mode (via the standard unit test bundle injection technique for running unit tests from within an application).
    
5. GTMTestTimer provides very high precision (using mach_absolute_time) timers for verifying run times. If we plan to support live plotting of large data sets, it seems useful to be able to verify, via automated testing, that operations run in an expected max time under testing conditions.

6. GTMDebugSelectorValidation.h provides macros that verify via assert (in DEBUG mode only) that a selector passed into a method, e.g. as a callback selector, matches the expected form (return type and parameter types).

7. Bindings can be automatically tested. This is useful for testing, e.g. the bindings of a UI widget such as our plots. GTMDoExposedBindingsFunctionCorrectly() automatically exercies the exposed bindings of a class, testing the getters and setters. Classes can override -(NSMutableArray*)gtm_unitTestExposedBindingsToIgnore to exclude bindings from this automated test. Classes can override -(NSMutableDictionary*)gtm_unitTestExposedBindingsTestValues:(NSString*)binding to provide particular values to test for a given binding::
    
    - (NSMutableDictionary*)gtm_unitTestExposedBindingsTestValues:(NSString*)binding {
      NSMutableDictionary *dict = [super unitTestExposedBindingsTestValues:binding];
      if ([binding isEqualToString:@"myBinding"]) {
        [dict setObject:[[[MySpecialBindingValueSet alloc] init] autorelease]
                 forKey:[[[MySpecialBindingValueGet alloc] init] autorelease]];
        ...
      else if ([binding isEqualToString:@"myBinding2"]) {
        ...
      }
      return dict;
    }

..

    Finally, classes can override -(BOOL)gtm_unitTestIsEqualTo:(id)value to test whether two bindings values are equal (in cases where standard isEqualTo: isn't sufficient; by it default calls isEqualTo:).
    
..

    Obviously, these overrides would probably be added by a class category.
    

.. [1] Although this is the recommendation, I think it is best, at least during development of the project to link to the GTM.framework, included as a project dependency. This minimizes file-management in the developing code base. For final release, we could consider incorporating only those classes that we actually end up using.