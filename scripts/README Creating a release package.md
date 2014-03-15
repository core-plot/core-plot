Follow these steps to create a Core Plot release and post it to GitHub:

1. Ensure the following tools are installed on your development machine:

    <ul>
        <li>Xcode 5</li>
        <li>[Doxygen](http://www.stack.nl/~dimitri/doxygen/download.html#latestsrc), version 1.8.6 or later, installed in <strong>/Applications</strong></li>
        <li>[Graphviz](http://www.graphviz.org/Download_macos.php), version 2.34.0 or later</li>
    </ul>

2. Ensure the [change log](https://github.com/core-plot/core-plot/blob/master/documentation/changelog.markdown) and [podspec](https://github.com/core-plot/core-plot/blob/master/CorePlot.podspec) are up-to-date and committed to the Git repository.

3. Using Git, ensure your local Core Plot source directory is in sync with the public repository on GitHub.

4. Open the Terminal application and `cd` to the root directory of your local Core Plot source directory.

5. Tag the current revision with the release version:

    `$ git tag release_<version>`
    
    where **&lt;version&gt;** is the version number for this release.

6. Change to the **scripts** folder:

    `$ cd scripts`

7. Run the createrelease script:

    `$ python createrelease.py <version>`

8. Review the messages printed in the Terminal window and verify that all build steps succeeded.

9. The release products were placed in a folder called **CorePlot_&lt;version&gt;** and placed on your desktop. Open this folder and verify that the following subfolders and files are present:

    <ul>
        <li><strong>Binaries/iOS/</strong></li>
        <li><strong>Binaries/MacOS/</strong></li>
        <li><strong>Documentation/</strong></li>
        <li><strong>READMEs/</strong></li>
        <li><strong>Source/</strong></li>
        <li><strong>License.txt</strong></li>
    </ul>

10. Right-click the release folder on your desktop and select **Compress "&lt;filename&gt;"** from the menu.

11. Log into GitHub and navigate to the [Releases](https://github.com/core-plot/core-plot/releases) page.

12. Click **Draft a new release**.

13. Select the tag for the new release (`release_<version>`).

    Enter the following:

    <ul>
        <li>Release title: <strong>Core Plot Release &lt;version&gt;</strong></li>
        <li>Binaries: drag the Core Plot zip file on your desktop to the box</li>
    </ul>
    
14. Click **Publish release**.

15. Change to the HTML documentation directory cloned from [core-plot.github.io](https://github.com/core-plot/core-plot.github.io):

    `cd ../documentation/html`
