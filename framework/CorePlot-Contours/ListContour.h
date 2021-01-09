//
//  CListContour.h
//  CorePlot-Contours Mac
//
//  Created by Steve Wainwright on 30/12/2020.
//
#include "stdhdr.h"

#include "Contour.h"

namespace COREPLOT_CONTOURS {
    // a list of point index referring to the secondary grid
    // Let i the index of a point,
    typedef std::list<uint> CLineStrip;
    typedef std::list<CLineStrip*> CLineStripList;
    typedef std::vector<CLineStripList> CLineStripListVector;


    class CListContour : public CContour
    {
    public:
        CListContour();
        CListContour(unsigned int noPlanes, const std::vector<double>& vPlanes);
        virtual ~CListContour();

        // retrieving list of line strip for the i-th contour
        CLineStripList* GetLines(uint iPlane) {
            assert(iPlane>=0); assert(iPlane<GetNPlanes());
            return &m_vStripLists[iPlane];
        }

        // Initializing memory
        virtual void InitMemory();
        // Cleaning memory and line strips
        virtual void CleanMemory();
        // Generate contour strips
        virtual void Generate();

        // Adding segment to line strips
        // See CContour::ExportLine for further details
        void ExportLine(int iPlane,int x1, int y1, int x2, int y2);

        // Basic algorithm to concatanate line strip. Not optimized at all !
        void CompactStrips();
        /// debuggin
        void DumpPlane(uint iPlane) const;

        // Area given by this function can be positive or negative depending on the winding direction of the contour.
        double Area(CLineStrip* Line);

        double EdgeWeight(CLineStrip* pLine, double R);
        bool   PrintEdgeWeightContour(char *fname);
        
    protected:
        // Merges pStrip1 with pStrip2 if they have a common end point
        bool MergeStrips(CLineStrip* pStrip1, CLineStrip* pStrip2);
        // Merges the two strips with a welding threshold.
        bool ForceMerge(CLineStrip* pStrip1, CLineStrip* pStrip2);
        // returns true if contour is touching boundary
        bool OnBoundary(CLineStrip* pStrip);

    private:
        // array of line strips
        CLineStripListVector m_vStripLists;
    };
};


