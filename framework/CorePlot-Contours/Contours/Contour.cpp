//
//  CContour.cpp
//  CorePlot-Contours Mac
//
//  Created by Steve Wainwright on 30/12/2020.
//

// Contour.cpp: implementation of the CContour class.
//
//////////////////////////////////////////////////////////////////////

#include "Contour.h"

using namespace COREPLOT_CONTOURS;

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

double TestFunction(double x,double y)
{
//    return 0.5*(cos(x+3.14/4)+sin(y+3.14/4));
    return sin(x) * sin(y);
};

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CContour::CContour() {
//    m_iColFir=m_iRowFir=32;
//    m_iColSec=m_iRowSec=256;
    m_iColFir=m_iRowFir=256;
    m_iColSec=m_iRowSec=2048;
    m_dDx=m_dDy=0;
    m_pFieldFcn=NULL;
    m_pFieldBlk=NULL;
    m_pLimits[0]=-6.0;
    m_pLimits[1]=6.0;
    m_pLimits[2]=-6.0;
    m_pLimits[3]=6.0;
    m_ppFnData=NULL;
    noPlanes = 21;

    // temporary stuff
//    m_pFieldFcn=TestFunction;
    m_vPlanes.resize(noPlanes);
    for (uint i=0;i<m_vPlanes.size();i++) {
        m_vPlanes[i]=(i-m_vPlanes.size()/2.0)*0.1;
    }
}

CContour::CContour(unsigned int _noPlanes, const std::vector<double>& vPlanes) {
    m_iColFir=m_iRowFir=256;
    m_iColSec=m_iRowSec=2048;
    m_dDx=m_dDy=0;
    m_pFieldFcn=NULL;
    m_pFieldBlk=NULL;
    m_pLimits[0]=-6.0;
    m_pLimits[1]=6.0;
    m_pLimits[2]=-6.0;
    m_pLimits[3]=6.0;
    m_ppFnData=NULL;

    noPlanes = _noPlanes;
    m_vPlanes.resize(noPlanes);
    for (uint i=0;i<m_vPlanes.size();i++) {
        m_vPlanes[i]=vPlanes[i];
    }
}

CContour::~CContour() {
    CleanMemory();
}

void CContour::InitMemory() {
    if (!m_ppFnData) {
        m_ppFnData=new CFnStr*[m_iColSec+1];
        for (int i=0;i<m_iColSec+1;i++) {
            m_ppFnData[i]=NULL;
        }
    }
}

void CContour::CleanMemory() {
    if (m_ppFnData) {
        int i;
        for (i=0;i<m_iColSec+1;i++) {
            if (m_ppFnData[i])
                delete[] (m_ppFnData[i]);
        }
        delete[] m_ppFnData;
        m_ppFnData=NULL;
    }
}

void CContour::Generate() {
    int i, j;
    int x3, x4, y3, y4, x, y, oldx3, xlow;
    const int cols=m_iColSec+1;
    const int rows=m_iRowSec+1;
    double xoff,yoff;
    
    // Initialize memroy if needed
    InitMemory();

    m_dDx = (m_pLimits[1]-m_pLimits[0])/(double)(m_iColSec);
    xoff = m_pLimits[0];
    m_dDy = (m_pLimits[3]-m_pLimits[2])/(double)(m_iRowSec);
    yoff = m_pLimits[2];

    xlow = 0;
    oldx3 = 0;
    x3 = (cols-1)/m_iRowFir;
    x4 = ( 2*(cols-1) )/m_iRowFir;
    for (x = oldx3; x <= x4; x++) {      /* allocate new columns needed
        */
        if (x >= cols)
            break;
        if (m_ppFnData[x]==NULL)
            m_ppFnData[x] = new CFnStr[rows];

        for (y = 0; y < rows; y++)
            FnctData(x,y)->m_sTopLen = -1;
    }

    y4 = 0;
    for (j = 0; j < m_iColFir; j++) {
        y3 = y4;
        y4 = ((j+1)*(rows-1))/m_iColFir;
        Cntr1(oldx3, x3, y3, y4);
    }

    for (i = 1; i < m_iRowFir; i++) {
        y4 = 0;
        for (j = 0; j < m_iColFir; j++) {
            y3 = y4;
            y4 = ((j+1)*(rows-1))/m_iColFir;
            Cntr1(x3, x4, y3, y4);
        }

        y4 = 0;
        for (j = 0; j < m_iColFir; j++) {
            y3 = y4;
            y4 = ((j+1)*(rows-1))/m_iColFir;
            Pass2(oldx3,x3,y3,y4);
        }

        if (i < (m_iRowFir-1)) {     /* re-use columns no longer needed */
            oldx3 = x3;
            x3 = x4;
            x4 = ((i+2)*(cols-1))/m_iRowFir;
            for (x = x3+1; x <= x4; x++) {
                if (xlow < oldx3) {
                    if (m_ppFnData[x])
                        delete[] m_ppFnData[x];
                    m_ppFnData[x] = m_ppFnData[xlow];
                    m_ppFnData[ xlow++ ] = NULL;
                }
                else
                    if (m_ppFnData[x]==NULL)
                        m_ppFnData[x] = new CFnStr[rows];

                for (y = 0; y < rows; y++)
                    FnctData(x,y)->m_sTopLen = -1;
            }
        }
    }

    y4 = 0;
    for (j = 0; j < m_iColFir; j++) {
        y3 = y4;
        y4 = ((j+1)*(rows-1))/m_iColFir;
        Pass2(x3,x4,y3,y4);
    }
}

void CContour::Cntr1(int x1, int x2, int y1, int y2) {
    double f11, f12, f21, f22, f33;
    int x3, y3, i, j;
    
    if ((x1 == x2) || (y1 == y2))    /* if not a real cell, punt */
        return;
    f11 = Field(x1, y1);
    f12 = Field(x1, y2);
    f21 = Field(x2, y1);
    f22 = Field(x2, y2);
    if ((x2 > x1+1) || (y2 > y1+1)) {    /* is cell divisible? */
        x3 = (x1+x2)/2;
        y3 = (y1+y2)/2;
        f33 = Field(x3, y3);
        i = j = 0;
        if (f33 < f11) i++; else if (f33 > f11) j++;
        if (f33 < f12) i++; else if (f33 > f12) j++;
        if (f33 < f21) i++; else if (f33 > f21) j++;
        if (f33 < f22) i++; else if (f33 > f22) j++;
        if ((i > 2) || (j > 2)) /* should we divide cell? */
        {
            /* subdivide cell */
            Cntr1(x1, x3, y1, y3);
            Cntr1(x3, x2, y1, y3);
            Cntr1(x1, x3, y3, y2);
            Cntr1(x3, x2, y3, y2);
            return;
        }
    }
    /* install cell in array */
    FnctData(x1,y2)->m_sBotLen = FnctData(x1,y1)->m_sTopLen = x2-x1;
    FnctData(x2,y1)->m_sLeftLen = FnctData(x1,y1)->m_sRightLen = y2-y1;
}

void CContour::Pass2(int x1, int x2, int y1, int y2) {
    int left = 0, right = 0, top = 0, bot = 0,old, iNew, i, j, x3, y3;
    double yy0 = 0.0, yy1 = 0.0, xx0 = 0.0, xx1 = 0.0, xx3, yy3;
    double v, f11, f12, f21, f22, f33, fold, fnew, f;
    double xoff=m_pLimits[0];
    double yoff=m_pLimits[2];
    
    if ((x1 == x2) || (y1 == y2))    /* if not a real cell, punt */
        return;
    f11 = FnctData(x1,y1)->m_dFnVal;
    f12 = FnctData(x1,y2)->m_dFnVal;
    f21 = FnctData(x2,y1)->m_dFnVal;
    f22 = FnctData(x2,y2)->m_dFnVal;
    if ((x2 > x1+1) || (y2 > y1+1)) {/* is cell divisible? */
        x3 = (x1+x2)/2;
        y3 = (y1+y2)/2;
        f33 = FnctData(x3, y3)->m_dFnVal;
        i = j = 0;
        if (f33 < f11) i++; else if (f33 > f11) j++;
        if (f33 < f12) i++; else if (f33 > f12) j++;
        if (f33 < f21) i++; else if (f33 > f21) j++;
        if (f33 < f22) i++; else if (f33 > f22) j++;
        if ((i > 2) || (j > 2)) /* should we divide cell? */
        {
            /* subdivide cell */
            Pass2(x1, x3, y1, y3);
            Pass2(x3, x2, y1, y3);
            Pass2(x1, x3, y3, y2);
            Pass2(x3, x2, y3, y2);
            return;
        }
    }

    for (i = 0; i < (int)m_vPlanes.size(); i++) {
        v = m_vPlanes[i];
        j = 0;
        if (f21 > v) j++;
        if (f11 > v) j |= 2;
        if (f22 > v) j |= 4;
        if (f12 > v) j |= 010;
        if ((f11 > v) ^ (f12 > v)) {
            if ((FnctData(x1,y1)->m_sLeftLen != 0) &&
                (FnctData(x1,y1)->m_sLeftLen < FnctData(x1,y1)->m_sRightLen)) {
                old = y1;
                fold = f11;
                while (1) {
                    iNew = old+FnctData(x1,old)->m_sLeftLen;
                    fnew = FnctData(x1,iNew)->m_dFnVal;
                    if ((fnew > v) ^ (fold > v))
                        break;
                    old = iNew;
                    fold = fnew;
                }
                yy0 = ((old-y1)+(iNew-old)*(v-fold)/(fnew-fold))/(y2-y1);
            }
            else
                yy0 = (v-f11)/(f12-f11);

            left = (int)(y1+(y2-y1)*yy0+0.5);
        }
        if ((f21 > v) ^ (f22 > v)) {
            if ((FnctData(x2,y1)->m_sRightLen != 0) &&
                (FnctData(x2,y1)->m_sRightLen < FnctData(x2,y1)->m_sLeftLen)) {
                old = y1;
                fold = f21;
                while (1) {
                    iNew = old+FnctData(x2,old)->m_sRightLen;
                    fnew = FnctData(x2,iNew)->m_dFnVal;
                    if ((fnew > v) ^ (fold > v))
                        break;
                    old = iNew;
                    fold = fnew;
                }
                yy1 = ((old-y1)+(iNew-old)*(v-fold)/(fnew-fold))/(y2-y1);
            }
            else
                yy1 = (v-f21)/(f22-f21);

            right = (int)(y1+(y2-y1)*yy1+0.5);
        }
        if ((f21 > v) ^ (f11 > v)) {
            if ((FnctData(x1,y1)->m_sBotLen != 0) &&
                (FnctData(x1,y1)->m_sBotLen < FnctData(x1,y1)->m_sTopLen)) {
                old = x1;
                fold = f11;
                while (1) {
                    iNew = old+FnctData(old,y1)->m_sBotLen;
                    fnew = FnctData(iNew,y1)->m_dFnVal;
                    if ((fnew > v) ^ (fold > v))
                        break;
                    old = iNew;
                    fold = fnew;
                }
                xx0 = ((old-x1)+(iNew-old)*(v-fold)/(fnew-fold))/(x2-x1);
            }
            else
                xx0 = (v-f11)/(f21-f11);

            bot = (int)(x1+(x2-x1)*xx0+0.5);
        }
        if ((f22 > v) ^ (f12 > v)) {
            if ((FnctData(x1,y2)->m_sTopLen != 0) &&
                (FnctData(x1,y2)->m_sTopLen < FnctData(x1,y2)->m_sBotLen)) {
                old = x1;
                fold = f12;
                while (1) {
                    iNew = old+FnctData(old,y2)->m_sTopLen;
                    fnew = FnctData(iNew,y2)->m_dFnVal;
                    if ((fnew > v) ^ (fold > v))
                        break;
                    old = iNew;
                    fold = fnew;
                }
                xx1 = ((old-x1)+(iNew-old)*(v-fold)/(fnew-fold))/(x2-x1);
            }
            else
                xx1 = (v-f12)/(f22-f12);

            top = (int)(x1+(x2-x1)*xx1+0.5);
        }

        switch (j) {
            case 7:
            case 010:
                ExportLine(i,x1,left,top,y2);
                break;
            case 5:
            case 012:
                ExportLine(i,bot,y1,top,y2);
                break;
            case 2:
            case 015:
                ExportLine(i,x1,left,bot,y1);
            break;
        case 4:
        case 013:
            ExportLine(i,top,y2,x2,right);
            break;
        case 3:
        case 014:
            ExportLine(i,x1,left,x2,right);
            break;
        case 1:
        case 016:
            ExportLine(i,bot,y1,x2,right);
            break;
        case 0:
        case 017:
            break;
        case 6:
        case 011:
            yy3 = (xx0*(yy1-yy0)+yy0)/(1.0-(xx1-xx0)*(yy1-yy0));
            xx3 = yy3*(xx1-xx0)+xx0;
            xx3 = x1+xx3*(x2-x1);
            yy3 = y1+yy3*(y2-y1);
            xx3 = xoff+xx3*m_dDx;
            yy3 = yoff+yy3*m_dDy;
            if (m_pFieldFcn != NULL) {
                f = (*m_pFieldFcn)(xx3, yy3);
            }
            else if (m_pFieldBlk != NULL) {
                f = m_pFieldBlk(xx3, yy3);
            }
            else {
                f = 0.0;
            }
            if (f == v) {
                ExportLine(i,bot,y1,top,y2);
                ExportLine(i,x1,left,x2,right);
            } else {
                if (((f > v) && (f22 > v)) || ((f < v) && (f22 < v))) {
                    ExportLine(i,x1,left,top,y2);
                    ExportLine(i,bot,y1,x2,right);
                } else {
                    ExportLine(i,x1,left,bot,y1);
                    ExportLine(i,top,y2,x2,right);
                }
            }
        }
    }
}

double CContour::Field(int x, int y) {   /* evaluate funct if we must,    */
    double x1, y1;
    
    if (FnctData(x,y)->m_sTopLen != -1)  /* is it already in the array */
        return(FnctData(x,y)->m_dFnVal);

    /* not in the array, create new array element */
    x1 = m_pLimits[0]+m_dDx*x;
    y1 = m_pLimits[2]+m_dDy*y;
    FnctData(x,y)->m_sTopLen = 0;
    FnctData(x,y)->m_sBotLen = 0;
    FnctData(x,y)->m_sRightLen = 0;
    FnctData(x,y)->m_sLeftLen = 0;
    if (m_pFieldFcn != NULL) {
        return (FnctData(x,y)->m_dFnVal = (*m_pFieldFcn)(x1, y1));
    }
    else if (m_pFieldBlk != NULL) {
        return (FnctData(x,y)->m_dFnVal = m_pFieldBlk(x1, y1));
    }
    else {
        return 0.0;
    }
}

void CContour::SetPlanes(const std::vector<double>& vPlanes) {
    // cleaning memory
    CleanMemory();
    
    m_vPlanes = vPlanes;
};

void CContour::SetFieldFcn(double (*_pFieldFcn)(double, double)) {
    m_pFieldFcn=_pFieldFcn;
};

void CContour::SetFieldBlk(double (^_pFieldBlk)(double, double)) {
    m_pFieldBlk=_pFieldBlk;
};

void CContour::SetFirstGrid(int iCol, int iRow) {
    m_iColFir=MAX(iCol,2);
    m_iRowFir=MAX(iRow,2);
}

void CContour::SetSecondaryGrid(int iCol, int iRow) {
    // cleaning work matrices if allocated
    CleanMemory();

    m_iColSec=MAX(iCol,2);
    m_iRowSec=MAX(iRow,2);
}

void CContour::SetLimits(double pLimits[]) {
    assert(pLimits[0]<pLimits[1]);
    assert(pLimits[2]<pLimits[3]);
    for (int i=0;i<4;i++) {
        m_pLimits[i]=pLimits[i];
    }
}

void CContour::SetNoIsoCurves(int _noPlanes) {
    noPlanes = _noPlanes;
}

void CContour::GetLimits(double pLimits[]) {
    for (int i=0;i<4;i++) {
        pLimits[i]=m_pLimits[i];
    }
}
