//
//  Contours.h
//  Coreplot-Contours
//
//  Created by Steve Wainwright on 01/01/2021.
//
#include "ListContour.h"

namespace COREPLOT_CONTOURS {

    class CListContour;
    class CContour;

    const int NOPLANES = 21;
    
    class CContours {
    
        public:
            
            /**
             *  The constructor sets the initial state of the contours generator
             *
             *  noPlanes - number of isocurves NOPLANES
             *  limits - the limit in x-y coordinates 0,5,0,5
             *
             */
            CContours();
        
            /**
             *  The constructor sets the initial state of the contours generator
             *
             * @param[in] noPlanes - number of isocurves
             * @param[in] limits - the limit in x-y coordinates
             * @param[in] vPlanes - the isoCurve values
             *
             */
            CContours(const int noPlanes, double* limits, double vPlanes[]);
        
            /**
             *  The constructor sets the initial state of the contours generator
             *
             * deconstructor
             *
             */
            ~CContours( void );
            
            /**
             *  Make the contours list available publically
             *
             * @return the list of contours
             */
            CListContour* getListContour() { return p_listContour; }
            
            /**
             *  The generator of the  contours list
             */
            void generate();
        
            /**
             *   Sets the pointer to the F(x,y) function
             *
             * @param[in] _pFieldFcn pointer to  the function
             *
             */
            void setFieldFunction(double (*_pFieldFcn)(double, double));
            
            /**
             *   Sets the block with the F(x,y) function
             *
             * @param[in] _pfieldBlk block of the function
             *
             */
            void setFieldBlock(double (^_pfieldBlk)(double x, double y));
            
            /**
             *   Gets the limits
             *
             * @param[in] pLimits - the limits in x-y coordinates
             *
             */
            void setLimits(double pLimits[]);
        
            /**
             *  Gets the limits
             *
             * @param[in] pLimits - the limits in x-y coordinates
             *
             */
            void getLimits(double pLimits[]);
        
            /**
             *  get the number of isocurves (Planes)
             *
             * @return the number in Planes
             *
             */
            unsigned int getNPlanes();
        
            /**
             *  get the number of isocurves (Planes)
             *
             * @param[in] i - index in  Planes
             * @return the value of that isocurve  Plane
             *
             */
            double getPlane(unsigned int i);
        
            /**
             *  get the number of isocurves (Planes)
             *
             * @param[in] number of IsoCurves
             *
             */
            void setNoIsoCurves(unsigned int number);
        
            /**
             *  The dumps the contours list for a specified plane index
             *
             * @param[in] iPlane - the plane index
             *
             */
            void dumpPlane(unsigned int iPlane);

        private:
        
            CListContour *p_listContour;
            int noPlanes;
            int dummy;
            double pLimits[4];
            
    };
};
