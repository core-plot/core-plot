Installing the Core Plot SDK for Developing on iPhone/iPad
----------------------------------------------------------

1. Copy the CorePlotSDK directory to ~/Library/SDKs/

2. Add to your project's .PCH file:

#import <CorePlot/CorePlot.h>

3. Open Project > Edit Project Settings and for All Configurations:

	3a. Add to Additional SDKS: 

		$HOME/Library/SDKs/CorePlotSDK/${PLATFORM_NAME}.sdk

	3b. Add to Other Linker Flags:

		-ObjC -all_load -lCorePlot 

4. Double-click on your Target and select Build tab. Check that Other Linker Flags setting is inherited from the project. If not, add settings

	-ObjC -all_load -lCorePlot 

5. Add the QuartzCore framework to the project.

6. Add a CPGraph to your application.