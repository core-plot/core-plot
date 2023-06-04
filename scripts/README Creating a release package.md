Follow these steps to create a Core Plot release and post it to GitHub:

# Build Core Plot

1. Ensure the following tools are installed on your development machine:

    <ul>
        <li>Xcode 11</li>
        <li>[Doxygen](http://www.stack.nl/~dimitri/doxygen/download.html#latestsrc), version 1.8.12 or later, installed in <strong>/Applications</strong></li>
        <li>[Graphviz](http://www.graphviz.org/Download_macos.php), version 2.36.0 or later</li>
    </ul>

2. Ensure the [change log](https://github.com/core-plot/core-plot/blob/master/documentation/changelog.markdown) and [podspec](https://github.com/core-plot/core-plot/blob/master/CorePlot.podspec) are up-to-date and committed to the Git repository.

3. Merge the development branch into `master`, resolve any merge conflicts, and commit the change.

4. In the "Core Plot" project build settings, set the "Current Project Version" to the release version. Commit the change in Git.

5. Using Git, ensure your local Core Plot source directory is in sync with the public repository on GitHub.

6. Open the Terminal application and `cd` to the root directory of your local Core Plot source directory.

7. Tag the current revision with the release version:

    `$ git tag <version>`
    
    where **&lt;version&gt;** is the semantic version number for this release, e.g., 2.5.0.

8. Change to the **scripts** folder:

    `$ cd scripts`

9. Run the createrelease script:

    `$ python createrelease.py <version>`

10. Review the messages printed in the Terminal window and verify that all build steps succeeded.

11. The release products were placed in a folder called **CorePlot_&lt;version&gt;** and placed on your desktop. Open this folder and verify that the following subfolders and files are present:

    <ul>
        <li><strong>Binaries/iOS/</strong></li>
        <li><strong>Binaries/MacOS/</strong></li>
        <li><strong>Binaries/tvOS/</strong></li>
        <li><strong>Documentation/</strong></li>
        <li><strong>READMEs/</strong></li>
        <li><strong>Source/</strong></li>
        <li><strong>License.txt</strong></li>
    </ul>

12. Right-click the release folder on your desktop and select **Compress "&lt;filename&gt;"** from the menu.

13. Log into GitHub and navigate to the [Releases](https://github.com/core-plot/core-plot/releases) page.

14. Click **Draft a new release**.

15. Select the tag for the new release (`<version>`).

    Enter the following:

    <ul>
        <li>Release title: <strong>Core Plot Release &lt;version&gt;</strong></li>
        <li>Binaries: drag the Core Plot zip file on your desktop to the box</li>
    </ul>
    
16. Click **Publish release**.

# Update Documentation

1. Change to the HTML documentation directory cloned from [core-plot.github.io](https://github.com/core-plot/core-plot.github.io):

    `cd ../documentation/html`

2. Commit any changes from the release build of the documentation.

3. Tag the current documentation revision with the release version:

    `$ git tag <version>`
    
4. Review the [wiki pages](https://github.com/core-plot/core-plot/wiki) and make any needed updates.

# Update CocoaPods

1. Make a copy of the [podspec](https://github.com/core-plot/core-plot/blob/master/CorePlot.podspec).

2. Update the **version** tag to the current release number.

    `s.version  = '<version>'`

3. Add the git tag name (`<version>`) under the **source** tag.

    `s.source   = { :git => 'https://github.com/core-plot/core-plot.git', 
                    :tag => '<version>'}`

4. Submit the updated podspec to [CocoaPods](https://github.com/CocoaPods/CocoaPods).

# Spread the Word

1. Post release announcements on the following sites:

    <ul>
        <li>The Core Plot [discussion board](https://groups.google.com/forum/#!forum/coreplot-discuss)</li>
        <li>[Twitter](https://twitter.com/CorePlot)</li>
    </ul>
