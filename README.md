<img src="/documentation/Objects%20and%20Layers.graffle/image1.png" alt="Core Plot logo" width="150"/>

# Core Plot

*Cocoa plotting framework for macOS, iOS, and tvOS.*

[![Cocoapods platforms](https://img.shields.io/cocoapods/p/CorePlot?color=bright-green)](https://core-plot.github.io) [![core-plot CI](https://github.com/core-plot/core-plot/actions/workflows/ci.yml/badge.svg)](https://github.com/core-plot/core-plot/actions/workflows/ci.yml)
[![Cocoapods](https://img.shields.io/cocoapods/v/CorePlot?color=bright-green)](https://cocoapods.org/pods/CorePlot) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen?style=flat)](https://github.com/Carthage/Carthage) [![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen)](https://github.com/apple/swift-package-manager)
[![GitHub license](https://img.shields.io/github/license/core-plot/core-plot?color=bright-green)](https://opensource.org/licenses/BSD-3-Clause)

# Introduction

Core Plot is a 2D plotting framework for macOS, iOS, and tvOS. It is highly customizable and capable of drawing many types of plots. See the  [Example Graphs](https://github.com/core-plot/core-plot/wiki/Example-Graphs) wiki page and the [example applications](https://github.com/core-plot/core-plot/tree/master/examples) for examples of some of its capabilities.

# Getting Started

See the [High Level Design Overview](https://github.com/core-plot/core-plot/wiki/High-Level-Design-Overview) wiki for an overview of Core Plot's architecture and the [Using Core Plot in an Application](https://github.com/core-plot/core-plot/wiki/Using-Core-Plot-in-an-Application) wiki for information on how to use Core Plot in your own application.

# Documentation

Documentation of the Core Plot API and high-level architecture can be found in the following places:

  * [Change log](https://github.com/core-plot/core-plot/blob/master/documentation/changelog.markdown)
  * [API documentation](https://core-plot.github.io/MacOS/index.html) for Mac
  * [API documentation](https://core-plot.github.io/iOS/index.html) for iOS and tvOS
  * API documentation built with [Doxygen](https://www.doxygen.nl/) and installed locally in Xcode (see the  [instructions](https://github.com/core-plot/core-plot/blob/master/READMEs/README%20for%20Docs%20Install.md) in the **READMEs** folder for details)
  * [Project Wiki](https://github.com/core-plot/core-plot/wiki) on GitHub
  * [Documentation](https://github.com/core-plot/core-plot/tree/master/documentation) folder in the code repository

# Where to Ask For Help

## Q&A Sites

  * [Core Plot](https://groups.google.com/group/coreplot-discuss) Google Group
  * Stackoverflow.com [core-plot tag](https://stackoverflow.com/questions/tagged/core-plot)

## Social Networks

  * [Twitter](https://twitter.com/CorePlot)

# Contributing to Core Plot

Core Plot is an open source project hosted on [GitHub](https://github.com/core-plot). There are two code repositories under the main project:

   * [core-plot](https://github.com/core-plot/core-plot): This is main code repository with the framework and all examples. This is where you will find the release packages, wiki pages, and issue tracker.

   * [core-plot.github.io](https://github.com/core-plot/core-plot.github.io): This is the HTML API documentation. You can view the pages online at [https://core-plot.github.io](https://core-plot.github.io).

## Coding Standards
Everyone has a their own preferred coding style, and no one way can be considered right. Nonetheless, in a project like Core Plot, with many developers contributing, it is worthwhile defining a set of basic coding standards to prevent a mishmash of different styles which can become frustrating when navigating the code base. See the file [CONTRIBUTING.md](https://github.com/core-plot/core-plot/blob/master/.github/CONTRIBUTING.md) found in the [.github](https://github.com/core-plot/core-plot/tree/master/.github)  directory of the project source for specific guidelines.

Core Plot includes a [script](https://github.com/core-plot/core-plot/blob/master/scripts/format_core_plot.sh) to run [Uncrustify](https://github.com/uncrustify/uncrustify) on the source code to standardize the formatting. All source code will be formatted with this tool before being committed to the Core Plot repository.

## Testing
Core Plot is intended to be applied in scientific, financial, and other domains where correctness is paramount. In order to assure the quality of the framework, unit testing is integrated. Good test coverage protects developers from introducing accidental regressions, and helps them to experiment and refactor without breaking existing code. See the [unit testing](https://github.com/core-plot/core-plot/wiki/Unit-Testing) wiki page for instructions on how to build unit tests for any new code you add to the project.
