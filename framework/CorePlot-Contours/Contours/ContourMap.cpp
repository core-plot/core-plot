/***************************************************************************
 *   Copyright (C) 2007 by Bjorn Harpe,,,   *
 *   bjorn@ouelong.com   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

// based on the work of Paul Bourke and Nicholas Yue
#include <stdio.h>
#include <math.h>
#include "contours.h"

//bool operator <(SPoint p1,SPoint p2){return((p1.x<p2.x));}
bool operator <(SPoint p1, SPoint p2){return(((p1.x*(unsigned int)0xFFFFFFFF)+p1.y)<((p2.x*(unsigned int)0xFFFFFFFF)+p2.y));}
bool operator <(SPair p1,SPair p2){return(p1.p1<p2.p1);}
bool operator ==(SPoint p1,SPoint p2){return((EQ(p1.x,p2.x))&&(EQ(p1.y,p2.y)));}
bool operator !=(SPoint p1,SPoint p2){return(!(EQ(p1.x,p2.x)&&!(EQ(p1.y,p2.y))));}
SPoint operator +=(SPoint p, SVector v){return(SPoint(p.x+=v.dx,p.y+=v.dy));}


int CContourMap::contour(CRaster *r)
{
/*
   this routine is coppied almost verbatim form Nicholas Yue's C++ implememtation
   of Paul bourkes CONREC routine. for deatails on the theory and implementation
   of this routine visit http://local.wasp.uwa.edu.au/~pbourke/papers/conrec/
      
   quick summary of the changes made
   - all the data passed in to the function is in a CRaster object and accessed
     thru a method (double value(double x, double y)). This class can be subclassed
     to calculate values based on a formula or retrieve values from a table.
   - as retrieval of values is now in the class supplied by the user we don't care
     if the data is regularly spaced or not, we assume that the class takes care of
     these details.
   - upper and lower bounds are similarly provided but the upper_bound and lower_bound
     methods in the class.
   - it is not assumed that this data is being immediatly output, rather it is all stored
     in a structure for later processing/display.
   
   yet to be done
   - realisticly we should replace the i and j indices with iterators, decouple this
     function from any sort of assumption entirely. this would require being able to
     retrieve x and y values from the iterator as well as the value. something like
     returning a pointer to a structure that contains the x and y values of the given
     point as well as the value. As this is not really required in my application it
     may or may not be done.
   
//=============================================================================
//
//     CONREC is a contouring subroutine for rectangularily spaced data.
//
//     It emits calls to a line drawing subroutine supplied by the user
//     which draws a contour map corresponding to real*4data on a randomly
//     spaced rectangular grid. The coordinates emitted are in the same
//     units given in the x() and y() arrays.
//
//     Any number of contour levels may be specified but they must be
//     in order of increasing value.
//
//     As this code is ported from FORTRAN-77, please be very careful of the
//     various indices like ilb,iub,jlb and jub, remeber that C/C++ indices
//     starts from zero (0)
//
//===========================================================================*/

   int m1,m2,m3,case_value;
   double dmin,dmax,x1,x2,y1,y2;
   register int i,j,k,m;
   double h[5];
   int sh[5];
   double xh[5],yh[5];
  //===========================================================================
  // The indexing of im and jm should be noted as it has to start from zero
  // unlike the fortran counter part
  //===========================================================================
   int im[4] = {0,1,1,0},jm[4]={0,0,1,1};
  //===========================================================================
  // Note that castab is arranged differently from the FORTRAN code because
  // Fortran and C/C++ arrays are transposed of each other, in this case
  // it is more tricky as castab is in 3 dimension
  //===========================================================================
   int castab[3][3][3] =
   {
      {
         {0,0,8},{0,2,5},{7,6,9}
      },
      {
         {0,3,4},{1,3,1},{4,3,0}
      },
      {
         {9,6,7},{5,2,0},{8,0,0}
      }
   };
   for (j=((int)r->upper_bound().x-1);j>=(int)r->lower_bound().x;j--) {
      for (i=(int)r->lower_bound().y;i<=(int)r->upper_bound().y-1;i++) {
         double temp1,temp2;
         temp1 = min(r->value(i,j),r->value(i,j+1));
         temp2 = min(r->value(i+1,j),r->value(i+1,j+1));
         dmin = min(temp1,temp2);
         temp1 = max(r->value(i,j),r->value(i,j+1));
         temp2 = max(r->value(i+1,j),r->value(i+1,j+1));
         dmax = max(temp1,temp2);
         if (dmax>=levels[0]&&dmin<=levels[n_levels-1]) {
            for (k=0;k<n_levels;k++) {
               if (levels[k]>=dmin&&levels[k]<=dmax) {
                  for (m=4;m>=0;m--) {
                     if (m>0) {
        //=============================================================
        // The indexing of im and jm should be noted as it has to
        // start from zero
        //=============================================================
                        h[m] = r->value(i+im[m-1],j+jm[m-1])-levels[k];
                        xh[m] = i+im[m-1];
                        yh[m] = j+jm[m-1];
                     } else {
                        h[0] = 0.25*(h[1]+h[2]+h[3]+h[4]);
                        xh[0]=0.5*(i+i+1);
                        yh[0]=0.5*(j+j+1);
                     }
                     if (h[m]>0.0) {
                        sh[m] = 1;
                     } else if (h[m]<0.0) {
                        sh[m] = -1;
                     } else
                        sh[m] = 0;
                  }
        //=================================================================
                  //
        // Note: at this stage the relative heights of the corners and the
        // centre are in the h array, and the corresponding coordinates are
        // in the xh and yh arrays. The centre of the box is indexed by 0
        // and the 4 corners by 1 to 4 as shown below.
        // Each triangle is then indexed by the parameter m, and the 3
        // vertices of each triangle are indexed by parameters m1,m2,and
        // m3.
        // It is assumed that the centre of the box is always vertex 2
        // though this isimportant only when all 3 vertices lie exactly on
        // the same contour level, in which case only the side of the box
        // is drawn.
                  //
                  //
        //      vertex 4 +-------------------+ vertex 3
        //               | \               / |
        //               |   \    m-3    /   |
        //               |     \       /     |
        //               |       \   /       |
        //               |  m=2    X   m=2   |       the centre is vertex 0
        //               |       /   \       |
        //               |     /       \     |
        //               |   /    m=1    \   |
        //               | /               \ |
        //      vertex 1 +-------------------+ vertex 2
                  //
                  //
                  //
        //               Scan each triangle in the box
                  //
        //=================================================================
                  for (m=1;m<=4;m++) {
                     m1 = m;
                     m2 = 0;
                     if (m!=4)
                        m3 = m+1;
                     else
                        m3 = 1;
                     case_value = castab[sh[m1]+1][sh[m2]+1][sh[m3]+1];
                     if (case_value!=0) {
                        switch (case_value) {
          //===========================================================
          //     Case 1 - Line between vertices 1 and 2
          //===========================================================
                           case 1:
                              x1=xh[m1];
                              y1=yh[m1];
                              x2=xh[m2];
                              y2=yh[m2];
                              break;
          //===========================================================
          //     Case 2 - Line between vertices 2 and 3
          //===========================================================
                           case 2:
                              x1=xh[m2];
                              y1=yh[m2];
                              x2=xh[m3];
                              y2=yh[m3];
                              break;
          //===========================================================
          //     Case 3 - Line between vertices 3 and 1
          //===========================================================
                           case 3:
                              x1=xh[m3];
                              y1=yh[m3];
                              x2=xh[m1];
                              y2=yh[m1];
                              break;
          //===========================================================
          //     Case 4 - Line between vertex 1 and side 2-3
          //===========================================================
                           case 4:
                              x1=xh[m1];
                              y1=yh[m1];
                              x2=xsect(m2,m3);
                              y2=ysect(m2,m3);
                              break;
          //===========================================================
          //     Case 5 - Line between vertex 2 and side 3-1
          //===========================================================
                           case 5:
                              x1=xh[m2];
                              y1=yh[m2];
                              x2=xsect(m3,m1);
                              y2=ysect(m3,m1);
                              break;
          //===========================================================
          //     Case 6 - Line between vertex 3 and side 1-2
          //===========================================================
                           case 6:
                              x1=xh[m3];
                              y1=yh[m3];
                              x2=xsect(m1,m2);
                              y2=ysect(m1,m2);
                              break;
          //===========================================================
          //     Case 7 - Line between sides 1-2 and 2-3
          //===========================================================
                           case 7:
                              x1=xsect(m1,m2);
                              y1=ysect(m1,m2);
                              x2=xsect(m2,m3);
                              y2=ysect(m2,m3);
                              break;
          //===========================================================
          //     Case 8 - Line between sides 2-3 and 3-1
          //===========================================================
                           case 8:
                              x1=xsect(m2,m3);
                              y1=ysect(m2,m3);
                              x2=xsect(m3,m1);
                              y2=ysect(m3,m1);
                              break;
          //===========================================================
          //     Case 9 - Line between sides 3-1 and 1-2
          //===========================================================
                           case 9:
                              x1=xsect(m3,m1);
                              y1=ysect(m3,m1);
                              x2=xsect(m1,m2);
                              y2=ysect(m1,m2);
                              break;
                           default:
                              break;
                        }
        //=============================================================
        // Put your processing code here and comment out the printf
        //=============================================================
                        add_segment(SPair(SPoint(x1,y1),SPoint(x2,y2)),k);
                     }
                  }
               }
            }
         }
      }
   }
   return 0;
}

int CContourMap::generate_levels(double min, double max, int num)
{
   double step=(max-min)/(num-1);
   if(levels) delete levels;
   levels=new double[num];
   n_levels=num;
   for(int i=0;i<num;i++)
   {
      levels[i]=min+step*i;
   }
   return num;
}

CContourMap::CContourMap()
{
   levels=NULL;
   n_levels=0;
   contour_level=NULL;
}

int CContourMap::add_segment(SPair t, int level)
{
// ensure that the object hierarchy has been allocated
   if(!contour_level) contour_level=new vector<CContourLevel*>(n_levels);
   if(!(*contour_level)[level])
      (*contour_level)[level]=new CContourLevel;
   if(!(*contour_level)[level]->raw)
      (*contour_level)[level]->raw=new vector<SPair>;
// push the value onto the end of the vector
   (*contour_level)[level]->raw->push_back(t);
   return(0);
}

int CContourMap::dump()
{
   //sort the raw vectors if they exist
   vector<CContourLevel*>::iterator it=contour_level->begin();
   int l=0;
   while(it!=contour_level->end())
   {
      printf("Contour data at level %d [%f]\n",l,levels[l]);
      if(*it) (*it)->dump();
      it++;l++;
   }
   fflush(NULL);
   return(0);
}

int CContourMap::consolidate()
{
   //sort the raw vectors if they exist
   vector<CContourLevel*>::iterator it=contour_level->begin();
   while(it!=contour_level->end())
   {
      if(*it) (*it)->consolidate();
      it++;
   }
   return(0);
}

CContourMap::~CContourMap()
{
   if(levels) delete levels;
   if(contour_level)
   {
      vector<CContourLevel*>::iterator it=contour_level->begin();
      while(it!=contour_level->end())
      {
         delete(*it);
         it=contour_level->erase(it);
      }
      contour_level->clear();
      delete contour_level;
   }
}
/*
===============================================================================
the CContourLevel class contains all the contour data for any given contour
level. initially this data is storred in point to point format in the raw
vector, however functions exist to combine these vectors into groups (CContour)
representing lines.
*/

int CContourLevel::dump()
{
// iterate thru the vector dumping values to STDOUT as we go
// this function is intended for debugging purposes only
   printf("======================================================================\n");
   if(raw)
   {
      printf("Raw vector data\n\n");
      vector<SPair>::iterator it;
      it=raw->begin();
      while(it!=raw->end())
      {
         SPair t=*it;
         printf("\t(%f, %f)\t(%f, %f)\n",t.p1.x,t.p1.y,t.p2.x,t.p2.y);
         it++;
      }
   }
   if(contour_lines)
   {
      printf("Processed contour lines\n\n");
      vector<CContour*>::iterator it=contour_lines->begin();
      int c=1;
      while(it!=contour_lines->end())
      {
         printf("Contour line %d:\n",c);
         (*it)->dump();
         c++;it++;
      }
   }
   printf("======================================================================\n");
   return(0);
}

int CContourLevel::consolidate()
{
   vector<SPair>::iterator it;
   CContour *contour;
   int c=0;
   if(!raw) return(0);
   if (!contour_lines) contour_lines=new vector<CContour*>;
   std::sort(raw->begin(),raw->end());
   while(!raw->empty())
   {
      c++;
      it=raw->begin();
      contour=new CContour();
      contour->add_vector((*it).p1,(*it).p2);
      it=raw->erase(it);
      while(it!=raw->end())
      {
         if((*it).p1==contour->end())
         {
            contour->add_vector((*it).p1,(*it).p2);
            raw->erase(it);
            it=raw->begin();
         }
         else it++;
      }
      contour_lines->push_back(contour);
   }
   delete raw;raw=NULL;
   fflush(NULL);
   c-=merge();
   vector<CContour*>::iterator cit=contour_lines->begin();
   while(cit!=contour_lines->end())
   {
      (*cit)->condense();
      cit++;
   }
   return(c);
}

int CContourLevel::merge()
{
   vector<CContour*>::iterator it,jt;
   int c=0;
   if(contour_lines->size()<2) return(0);
   it=contour_lines->begin();
   /*
   using two iterators we walk through the entire vector testing to
   see if some combination of the start and end points match. If we
   find matching points the two vectorsrs are merged. since when we go
   thru the vector once we are garanteed that all vectors that can
   connect to that oone have been merged we only have to merge the
   vector less the processed nodes at the begining. every merge does
   force jt back to the beginning of the search tho since a merge will
   change either the start or the end of the vector
   */
   while(it!=contour_lines->end())
   {
      jt=it+1;
      while(jt!=contour_lines->end())
      {
         /*
         if the end of *it matches the start ot *jt we can copy
         *jt to the end of *it and remove jt, the erase funtion
         does us a favour and increments the iterator to the
         next element so we continue to test the next element
         */
         if((*it)->end()==(*jt)->start())
         {
            (*it)->merge(*jt);
            delete(*jt);
            contour_lines->erase(jt);
            jt=it+1;
            c++;
         }
         /*
         similarily if the end of *jt matches the start ot *it we can copy
         *it to the end of *jt and remove it,replacing it with jt, we then
         neet to update it to point at the just inserted record.
         */
         else if((*jt)->end()==(*it)->start())
         {
            (*jt)->merge(*it);
            delete(*it);
            (*it)=(*jt);
            contour_lines->erase(jt);
            jt=it+1;
            c++;
         }
         /*
         if both segments end at the same point we reverse one and merge
         it to the other, then remove the one we merged.
         */
         else if((*it)->end()==((*jt)->end()))
         {
            (*jt)->reverse();
            (*it)->merge(*jt);
            delete(*jt);
            contour_lines->erase(jt);
            jt=it+1;
            c++;
         }
         /*
         if both segments start at the same point reverse it, then merge
         it with jt, removing jt and reseting jt to the start of the search
         sequence
         */
         else if((*it)->start()==((*jt)->start()))
         {
            (*it)->reverse();
            (*it)->merge(*jt);
            delete(*jt);
            jt=contour_lines->erase(jt);
            c++;
         }
         else
         {
            jt++;
         }
      }
      it++;
   }
   return(c);
}

CContourLevel::~CContourLevel()
{
   if(raw)
   {
      raw->clear();
      delete raw;
   }
   
   if(contour_lines)
   {
      vector<CContour*>::iterator it=contour_lines->begin();
      while(it!=contour_lines->end())
      {
         delete (*it);
         it=contour_lines->erase(it);
      }
      contour_lines->clear();
      delete contour_lines;
   }
}

/*
===============================================================================
the CContour class stores actual individual contour lines in a vector,addition
to the vector is handled by the add_vector function for individual vector
components. in the case that one contour needs to be coppied to the end of
another contour there is a merge function that will copy the second onto the
end of the first. individual accessors are provided for the start and end points
and the actual vector is publicly available.
*/

int CContour::add_vector(SPoint p1, SPoint p2)
{

// move the vector to the orgin
   SVector v;
   v.dx=p2.x-p1.x;
   v.dy=p2.y-p1.y;
// if the contour vector does not exist create it
// and set the starting point for this contour
   if(!contour)
   {
      contour=new vector<SVector>;
      _start=p1;
   }
// insert the new vector to the end of the contour
// and update the end point for this contour
   contour->push_back(v);
   _end=p2;
   return(0);
}

int CContour::reverse()
{
// swap the start and end points
   SPoint t=_end;
   _end=_start;
   _start=t;
// iterate thru the entire vector and reverse each individual element
// inserting them into a new vector as we go
   vector<SVector> *tmp=new vector<SVector>;
   vector<SVector>::iterator it=contour->begin();
   while(it!=contour->end())
   {
      (*it).dx*=-1;
      (*it).dy*=-1;
      tmp->insert(tmp->begin(),(*it));
      it++;
   }
// swap the old contour vector with the new reversed one we just generated
   delete contour;
   contour=tmp;
   return (0);
}

int CContour::merge(CContour *c)
{
   this->contour->insert(this->contour->end(),c->contour->begin(),c->contour->end());
   this->_end=c->_end;
   return(0);
}

int CContour::dump()
{
   printf("\tStart: [%f, %f]\n\tEnd: [%f, %f]\n\tComponents>\n",
          _start.x,_start.y,_end.x,_end.y);
   vector<SVector>::iterator cit=contour->begin();
   int c=1;
   SPoint p=_start;
   while(cit!=contour->end())
   {
      p.x+=(*cit).dx;
      p.y+=(*cit).dy;
      printf("\t\t{%f, %f}\t[%f,%f]\n",(*cit).dx,(*cit).dy,p.x,p.y);
      c++,cit++;
   }
   return(0);
}

int CContour::condense(double difference)
{
   /*
   at this time we potentially have multiple SVectors in the contour vector that
   are colinear and could be condensed into one SVector with, to determine if two
   successive vectors are colinear we take each vector and divide the y component
   of the vector by the x component, giving us the slope. we pass in a difference
   if the difference between th two slopes is less than the difference that we
   pass in and since we already know that both segments share a common point they
   can obviously be condensed. in the sample code on this page this is evident it
   the bounding rectangle. another possibility is modifying the code to allow
   point intersections on the plane. In this instance we may have multiple
   identical vectors with no magnitude that can be reduced to a single data point.
   */
   
   vector<SVector>::iterator it,jt;
   double m1,m2;
   it=contour->begin();
   jt=it+1;
   while(jt!=contour->end())
   {
      if(((*jt).dx)&&((*it).dx))
      {
         m1=(*jt).dy/(*jt).dx;
         m2=(*it).dy/(*jt).dx;
      }
      else if(((*jt).dy)&&((*it).dy))
      {
         m1=(*jt).dx/(*jt).dy;
         m2=(*it).dx/(*jt).dy;
      }
      else
      {
         it++;jt++;
         continue;
      }
      if ((m1-m2<difference)&&(m2-m1<difference))
      {
         (*it).dy+=(*jt).dy;
         (*it).dx+=(*jt).dx;
         jt=contour->erase(jt);
      }
      else
      {
         it++;jt++;
      }
   }
   return(0);
}

CContour::~CContour()
{
   this->contour->clear();
   delete this->contour;
}


#ifdef STANDALONE
/*
=============================================================================
the following is just test code to try to test that everything works together
alright, we need to create an object that inherits from CRaster (ToMap in
this case) that defines three functions, two returning each the lower and
upper bounds respectively, and a third that returns the value at a given
point. As we are assuming that data is regularly spaced we do not need to
determine the x or y coordinate at this point as the original code did,
rather we leave that for the rendering step to do by scaling the values as
needed.
=============================================================================
*/

class ToMap:public CRaster
{
   public:
      double value(double x,double y);
      SPoint upper_bound();
      SPoint lower_bound();
};

double ToMap::value(double x, double y)
{
   if(((int)x==1)&&((int)y==1)) return 1;
   else return 0;
}

SPoint ToMap::lower_bound()
{
   return SPoint(0,0);
}

SPoint ToMap::upper_bound()
{
   return SPoint(2,2);
}

int main(int argc, char *argv[])
{
   ToMap *m=new ToMap;
   CContourMap *map=new CContourMap;
   map->generate_levels(0,1,3);
   printf("Attempting to contour \n");
   map->contour(m);
   map->dump();
   printf("Consolidating Vectors\n");
   map->consolidate();
   printf("\n\n\n\t\tDumping Contour Map\n");
   map->dump();
}
#endif
