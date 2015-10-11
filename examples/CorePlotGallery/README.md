A gallery of Core Plot examples for Mac OS X and iOS. The iOS app is a universal app that supports both iPhone and iPad.

To add a new plot demo:

1. Create a new subclass of the `PlotItem` class.

2. Add a `+(void)load` class method to register the class via the `[super registerPlotItem:self];` message. This makes it show up in the tableview/imageview.

3. Set the `title` and `section` in the `-init` method. The `title` is used as the label in the list of plots, grouped alphabetically under the `section`.

4. Override the `-renderInGraphHostingView:withTheme:animated:` method to set up the plot demo. Add the graph hosting view(s) for the demo as sublayers of the hosting view parameter. If the plot demo includes more than one graph, your `PlotItem` subclass is responsible for the layout of the graphs. Use autolayout on iOS and calculate the layout manually on the Mac. Be sure to implement the `-setFrameSize:` method on the Mac and update the layout there, too. See the `CompositePlot` class for an example of creating multiple graphs in a plot demo.

5. Call the `-addGraph:toHostingView:` method to add each graph to its hosting view and to the master list of graphs.

6. Implement the `-killGraph` method to release temporary data or views created in the `-renderInGraphHostingView:withTheme:animated:` method.

7. Add any delegate methods you need for handling labels or user interaction and datasource methods to provide plot data.
