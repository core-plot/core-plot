//
//  CContour.h
//  CorePlot-Contours Mac
//
//  Created by Steve Wainwright on 30/12/2020.
//
// Contour.cpp: implementation of the CContour class.
//
// Contour.h: interface for the CContour class.
//
// CContour implements Contour plot algorithm described in
//        IMPLEMENTATION OF
//        AN IMPROVED CONTOUR
//        PLOTTING ALGORITHM
//        BY
//
//        MICHAEL JOSEPH ARAMINI
//
//        B.S., Stevens Institute of Technology, 1980
// See http://www.ultranet.com/~aramini/thesis.html
//
// Ported to C++ by Jonathan de Halleux.
//
// Using CContour :
//
// CContour is not directly usable. The user has to
//    1. derive the function ExportLine that is
//        supposed to draw/store the segment of the contour
//    2. Set the function draw contour of. (using  SetFieldFn
//        The function must be declared as follows
//        double (*myF)(double x , double y);
//
//    History:
//        31-07-2002:
//            - A lot of contribution from Chenggang Zhou (better strip compressions, merging, area, weight),
//////////////////////////////////////////////////////////////////////

#include "stdhdr.h"

// A simple test function
double TestFunction(double x,double y);

namespace COREPLOT_CONTOURS {

    // A structure used internally by CContour
    struct CFnStr {
        double m_dFnVal;
        short m_sLeftLen;
        short m_sRightLen;
        short m_sTopLen;
        short m_sBotLen;
    };

    class CContour
    {
    public:
        CContour();
        CContour(unsigned int noPlanes, const std::vector<double>& vPlanes);
        virtual ~CContour();

        // Initialize memory. Called in Generate
        virtual void InitMemory();
        // Clean work arrays
        virtual void CleanMemory();
        // Generates contour
        // Before calling this functions you must
        //    1. derive the function ExportLine that is
        //        supposed to draw/store the segment of the contour
        //    2. Set the function draw contour of. (using  SetFieldFn
        //        The function must be declared as follows
        //        double (*myF)(double x , double y);
        virtual void Generate();

        // Set the dimension of the primary grid
        void SetFirstGrid(int iCol, int iRow);
        // Set the dimension of the base grid
        void SetSecondaryGrid(int iCol, int iRow);
        // Sets the region [left, right, bottom,top] to generate contour
        void SetLimits(double pLimits[4]);
        // Sets the isocurve values
        void SetPlanes(const std::vector<double>& vPlanes);
        // Sets the pointer to the F(x,y) function
        void SetFieldFcn(double (*_pFieldFcn)(double, double));
        // Sets the block to the F(x,y) function
        void SetFieldBlk(double (^_pFieldBlk)(double, double));
        // sets the number of isocurves to look at
        void SetNoIsoCurves(int _noPlanes);

        // Retrieve dimension of grids, contouring region and isocurve
        int GetColFir() const        { return m_iColFir;}
        int GetRowFir() const        { return m_iRowFir;}
        int GetColSec() const        { return m_iColSec;}
        int GetRowSec() const        { return m_iRowSec;}
        void GetLimits(double pLimits[4]);
        uint GetNPlanes() const      { return static_cast<uint>(m_vPlanes.size());}
        const std::vector<double>& GetPlanes() const { return m_vPlanes;}
        double GetPlane(uint i) const { assert(i>=0); assert(i<m_vPlanes.size()); return m_vPlanes[i]; }

        // For an indexed point i on the sec. grid, returns x(i)
        double GetXi(int i) const {    return m_pLimits[0] +  i%(m_iColSec+1)*(m_pLimits[1]-m_pLimits[0])/static_cast<double>( m_iColSec );}
        // For an indexed point i on the fir. grid, returns y(i)
        double GetYi(int i) const { assert(i>=0); return m_pLimits[2] +  i/(m_iColSec+1)*(m_pLimits[3]-m_pLimits[2])/static_cast<double>( m_iRowSec );}

    protected:
        // Accessibles variables
        std::vector<double> m_vPlanes;            // value of contour planes
        double m_pLimits[4];                        // left, right, bottom, top
        int m_iColFir;                                // primary    grid, number of columns
        int m_iRowFir;                                // primary    grid, number of rows
        int m_iColSec;                                // secondary grid, number of columns
        int m_iRowSec;                                // secondary grid, number of rows
        double (*m_pFieldFcn)(double x, double y); // pointer to F(x,y) function
        double (^m_pFieldBlk)(double x, double y); // block to F(x,y) function
        
        int noPlanes;     // no of isocurves to breakdown

        // Protected function
        virtual void ExportLine(int iPlane, int x1, int y1, int x2, int y2) = 0; // plots a line from (x1,y1) to (x2,y2)

        // Work functions and variables
        int dummy;
        double m_dDx;
        double m_dDy;
        CFnStr** m_ppFnData;    // pointer to mesh parts
        CFnStr* FnctData(int i,int j)  {    return (m_ppFnData[i]+j);}
        double Field(int x, int y);     /* evaluate funct if we must,    */
        void Cntr1(int x1, int x2, int y1, int y2);
        void Pass2(int x1, int x2, int y1, int y2);      /* draws the contour lines */
    };
};
