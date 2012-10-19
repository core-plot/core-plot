Drawing Order
-------------

1.	Background fill
2.	Even/odd background fills
3.	Arbitrary background fill ranges
4.	Minor grid lines 
5.	Major grid lines
6.	Background border
7.	Minor tick marks
8.	Major tick marks
9.	Axis lines
10.	Plots
11.	Axis labels
12.	Axis titles

Layers
------

	CPTGraph (1)
	  |--CPTPlotAreaFrame (*)
	       |--CPTPlotArea (1) {1, 2, 3}
	            |--CPTGridLineGroup (1) [minor grid lines]
	            |    |-CPTGridLines (*) {4}
	            |--CPTGridLineGroup (1) [major grid lines]
	            |    |-CPTGridLines (*) {5}
	            |--CPTAxisSet (1) {6}
	            |    |-CPTAxis (*) {7, 8, 9}
	            |--CPTPlotGroup (1)
	            |    |-CPTPlot (*) {10}
	            |--CPTLayer (1) [axis labels]
	            |    |-CPTAxisLabel (content layers) (*) {11}
	            |--CPTLayer (1) [axis titles]
	                 |-CPTAxisTitle (content layers) (*) {12}

Key
---

**(1)**	Zero or one layer of this type

**(*)**	Zero or more layers of this type

**{n}**	n is the element drawn by the indicated layer
