# Core Plot

*Cocoa plotting framework for Mac OS X and iOS.*

[![Build Status](https://secure.travis-ci.org/core-plot/core-plot.svg)](http://travis-ci.org/core-plot/core-plot) [![Version Status](https://img.shields.io/cocoapods/v/CorePlot.svg)](https://cocoapods.org/pods/CorePlot) [![license MIT](https://img.shields.io/cocoapods/l/CorePlot.svg)](http://opensource.org/licenses/BSD-3-Clause)  [![Platform](https://img.shields.io/cocoapods/p/CorePlot.svg)](http://core-plot.github.io)

# Introduction

Core Plot is a 2D plotting framework for Mac OS X, iOS, and tvOS. It is highly customizable and capable of drawing many types of plots. See the  [Example Graphs](https://github.com/core-plot/core-plot/wiki/Example-Graphs) wiki page and the [example applications](https://github.com/core-plot/core-plot/tree/master/examples) for examples of some of its capabilities.

# Getting Started

See the [High Level Design Overview](https://github.com/core-plot/core-plot/wiki/High-Level-Design-Overview) wiki for an overview of Core Plot's architecture and the [Using Core Plot in an Application](https://github.com/core-plot/core-plot/wiki/Using-Core-Plot-in-an-Application) wiki for information on how to use Core Plot in your own application.

# Documentation

Documentation of the Core Plot API and high-level architecture can be found in the following places:

  * [Change log](https://github.com/core-plot/core-plot/blob/master/documentation/changelog.markdown)
  * [API documentation](http://core-plot.github.io/MacOS/index.html) for Mac
  * [API documentation](http://core-plot.github.io/iOS/index.html) for iOS and tvOS
  * API documentation built with [Doxygen](http://www.doxygen.org/) and installed locally in Xcode (see the  [instructions](https://github.com/core-plot/core-plot/blob/master/READMEs/README%20for%20Docs%20Install.md) in the **READMEs** folder for details)
  * [Project Wiki](https://github.com/core-plot/core-plot/wiki) on GitHub
  * [Documentation](https://github.com/core-plot/core-plot/tree/master/documentation) folder in the code repository

# Where to Ask For Help

## Q&A Sites

  * [Core Plot](http://groups.google.com/group/coreplot-discuss) Google Group
  * Stackoverflow.com [core-plot tag](http://stackoverflow.com/questions/tagged/core-plot)

## Social Networks

  * [Twitter](https://twitter.com/CorePlot)
  * [App.net](https://alpha.app.net/coreplot); Subscribe to the [Announcements](https://app.net/c/2rw2) broadcast.

# Contributing to Core Plot

Core Plot is an open source project hosted on [GitHub](https://github.com/core-plot). There are two code repositories under the main project:

   * [core-plot](https://github.com/core-plot/core-plot): This is main code repository with the framework and all examples. This is where you will find the release packages, wiki pages, and issue tracker.

   * [core-plot.github.io](https://github.com/core-plot/core-plot.github.io): This is the HTML API documentation. You can view the pages online at [http://core-plot.github.io](http://core-plot.github.io).

## Coding Standards
Everyone has a their own preferred coding style, and no one way can be considered right. Nonetheless, in a project like Core Plot, with many developers contributing, it is worthwhile defining a set of basic coding standards to prevent a mishmash of different styles which can become frustrating when navigating the code base. See the file [CONTRIBUTING.md](https://github.com/core-plot/core-plot/blob/master/.github/CONTRIBUTING.md) found in the [.github](https://github.com/core-plot/core-plot/tree/master/.github)  directory of the project source for specific guidelines.

Core Plot includes a [script](https://github.com/core-plot/core-plot/blob/master/scripts/format_core_plot.sh) to run [Uncrustify](http://uncrustify.sourceforge.net) on the source code to standardize the formatting. All source code will be formatted with this tool before being committed to the Core Plot repository.

## Testing
Because Core Plot is intended to be used in scientific, financial, and other domains where correctness is paramount, unit testing is integrated into the framework. Good test coverage protects developers from introducing accidental regressions and frees them to experiment and refactor without fear of breaking things. See the [unit testing](https://github.com/core-plot/core-plot/wiki/Unit-Testing) wiki page for instructions on how to build unit tests for any new code you add to the project.

# Support Core Plot

<a href="https://flattr.com/submit/auto?user_id=CorePlot&url=https%3A%2F%2Fgithub.com%2Fcore-plot" target="_blank"><img src="http://api.flattr.com/button/flattr-badge-large.png" alt="Flattr this" title="Flattr this" border="0"></a>
