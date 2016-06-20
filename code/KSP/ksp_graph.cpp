/************************************************************************/
/* (c) 2009-2011 Ecole Polytechnique Federale de Lausanne               */
/* All rights reserved.                                                 */
/*                                                                      */
/* EPFL grants a non-exclusive and non-transferable license for non     */
/* commercial use of the Software for education and research purposes   */
/* only. Any other use of the Software is expressly excluded.           */
/*                                                                      */
/* Redistribution of the Software in source and binary forms, with or   */
/* without modification, is not permitted.                              */
/*                                                                      */
/* Written by Engin Turetken.                                           */
/*                                                                      */
/* http://cvlab.epfl.ch/research/body/surv                              */
/* Contact <pom@epfl.ch> for comments & bug reports.                    */
/************************************************************************/

#include "ksp_graph.h"
#include <stdio.h>
#include <set>
using namespace std;

KShorthestPathGraph::KShorthestPathGraph( 
                                         float* pfData,
                                         int nDataWidth,
                                         int nDataHeight,
                                         int nDataDepth,
                                         int nNodeNeighborhoodSize,
                                         std::vector<int> &pnSrcAndDstNeighIndices,
                                         float ss_cost_prob_log)
{
  // Declarations
  typedef std::pair<int, int> Edge;
  int nNoOfGridLocs;
  int nNoOfNodes;
  int nNoOfEdges;
  float* pfEdgeWeights;
  float* pfEdgeWeightPtr;
  int nSearchRadious;
  int nGridIndx;
  int nX;
  int nY;
  int nOffsetX;
  int nOffsetY;
  int nTimeIndx;
  int nLogeIndx;
  int nEdgeIndx;
  int nArrayOffset;
  int* pnSrcEdgesBtw2ConsecTimes;
  int* pnDstEdgesBtw2ConsecTimes;
  int nNoOfEdgesBtw2ConsecTimes;
  int nArraySrcIndx;
  int nArrayDstIndx;
  int nEdgeCounter;
	
  // Initializations
  nNoOfGridLocs = nDataWidth * nDataHeight;
  nNoOfNodes = nDataWidth * nDataHeight * nDataDepth + 2;

  // Neighbourhood size must be odd, if not make it. 
  if( (nNodeNeighborhoodSize % 2) == 0 )
    {
      nNodeNeighborhoodSize++;
    }
  nNoOfEdges = (2 * nNoOfGridLocs) + (2 * pnSrcAndDstNeighIndices.size()) + (2 * (nDataDepth - 2) 
* pnSrcAndDstNeighIndices.size()) + (nDataDepth - 1) * nNoOfGridLocs * nNodeNeighborhoodSize * nNodeNeighborhoodSize;

  m_nSrcNodeIndx = nNoOfNodes - 2;
  m_nDstNodeIndx = nNoOfNodes - 1;
  std::vector< Edge > vEdges(nNoOfEdges);
  std::vector< Edge >::iterator vEdgeIter;
  pfEdgeWeights = new float[nNoOfEdges];
  nNoOfEdges = 0;
  nSearchRadious = (nNodeNeighborhoodSize - 1) / 2;
  pnSrcEdgesBtw2ConsecTimes = new int[nNoOfGridLocs * nNodeNeighborhoodSize * nNodeNeighborhoodSize];
  pnDstEdgesBtw2ConsecTimes = new int[nNoOfGridLocs * nNodeNeighborhoodSize * nNodeNeighborhoodSize];
  nNoOfEdgesBtw2ConsecTimes = 0;


  double addW = 0;
		
  // Filling in the edge array
  // Filling the edges outgoing from the source and incoming to terminal
  // Filling the edges between the source node and all the nodes in the first frame
  // and between the terminal node and all the nodes in the last frame
  vEdgeIter = vEdges.begin();
  pfEdgeWeightPtr = pfEdgeWeights;
  nArrayOffset = nNoOfGridLocs * ( nDataDepth - 1);
  for( nGridIndx = 0; nGridIndx < nNoOfGridLocs; nGridIndx++ )	
    {
      vEdgeIter->first = m_nSrcNodeIndx;
      vEdgeIter->second = nGridIndx;
      (*pfEdgeWeightPtr) = ss_cost_prob_log + addW;
      vEdgeIter++;
      pfEdgeWeightPtr++;
		
      vEdgeIter->first = nGridIndx + nArrayOffset;
      vEdgeIter->second = m_nDstNodeIndx;
      (*pfEdgeWeightPtr) = pfData[vEdgeIter->first] + addW;
      vEdgeIter++;
      pfEdgeWeightPtr++;
    }
  nNoOfEdges += 2 * nNoOfGridLocs;
	
  // Filling the edges between the terminal node and loge nodes in the first frame
  // and between the source node and loge nodes in the last frame
  for( nLogeIndx = 0; nLogeIndx < pnSrcAndDstNeighIndices.size(); nLogeIndx++ )
    {
      vEdgeIter->first = pnSrcAndDstNeighIndices[nLogeIndx];
      vEdgeIter->second = m_nDstNodeIndx;
      (*pfEdgeWeightPtr) = pfData[vEdgeIter->first] + addW;
      vEdgeIter++;
      pfEdgeWeightPtr++;
		
      vEdgeIter->first = m_nSrcNodeIndx;
      vEdgeIter->second = pnSrcAndDstNeighIndices[nLogeIndx] + nArrayOffset;
      (*pfEdgeWeightPtr) = ss_cost_prob_log + addW;
      vEdgeIter++;
      pfEdgeWeightPtr++;
    }
  nNoOfEdges += 2 * pnSrcAndDstNeighIndices.size();
	
  // Filling the edges 'from the source' or 'to the terminal' 
  // for all the nodes except those in the first and the last time frames.
  if( pnSrcAndDstNeighIndices.size() > 0 )
    {
      nArrayOffset = 0;
      nDataDepth--;
      for( nTimeIndx = 1; nTimeIndx < nDataDepth; nTimeIndx++ )
        {
          nArrayOffset += nNoOfGridLocs;
			
          for( nLogeIndx = 0; nLogeIndx < pnSrcAndDstNeighIndices.size(); nLogeIndx++ )
            {
              nGridIndx = pnSrcAndDstNeighIndices[nLogeIndx] + nArrayOffset;
				
              vEdgeIter->first = m_nSrcNodeIndx;
              vEdgeIter->second = nGridIndx;
              (*pfEdgeWeightPtr) = ss_cost_prob_log + addW;
              vEdgeIter++;
              pfEdgeWeightPtr++;
				
              vEdgeIter->first = nGridIndx;
              vEdgeIter->second = m_nDstNodeIndx;
              (*pfEdgeWeightPtr) = pfData[nGridIndx] + addW;
              vEdgeIter++;
              pfEdgeWeightPtr++;
            }
        }
      nDataDepth++;
      nNoOfEdges += 2 * (nDataDepth - 2) * pnSrcAndDstNeighIndices.size();
    }
	
	
  // Computing the array of edges (1D array indices of source and
  // destination nodes) binding two consecutive time frames.
  //

  set<int> goodEdge;

  nArraySrcIndx = 0;
  nEdgeCounter = 0;
  nArrayOffset = nNoOfGridLocs;
  for( nY = 0; nY < nDataHeight; nY++ )
    {
      for( nX = 0; nX < nDataWidth; nX++ )
        {			
          for( nOffsetY = -nSearchRadious; nOffsetY <= nSearchRadious; nOffsetY++ )
            {	
              if( ((nY + nOffsetY) >= 0) && ((nY + nOffsetY) < nDataHeight) )
                {
                  nArrayDstIndx = nArrayOffset + nOffsetY * nDataWidth;
					
                  for( nOffsetX = -nSearchRadious; nOffsetX <= nSearchRadious; nOffsetX++ )
                    {
                      if( ((nX + nOffsetX) >= 0) && ((nX + nOffsetX) < nDataWidth) )
                        {
                          pnSrcEdgesBtw2ConsecTimes[nEdgeCounter] = nArraySrcIndx;
                          pnDstEdgesBtw2ConsecTimes[nEdgeCounter] = nArrayDstIndx + nOffsetX;

                          if (nOffsetX == 0 && nOffsetY == 0) {
                              goodEdge.insert(nEdgeCounter);
                          }

                          nEdgeCounter++;
                        }
                    }
                }
            }
			
          nArraySrcIndx++;
          nArrayOffset++;
        }
    }
	
  // Filling all the remaining edges that are not outgoing from the source or
  // incoming to the terminal nodes.	
  nArrayOffset = 0;
  nDataDepth--;
  for( nTimeIndx = 0; nTimeIndx < nDataDepth; nTimeIndx++ )
    {	
      for( nEdgeIndx = 0; nEdgeIndx < nEdgeCounter; nEdgeIndx++ )
        {
          vEdgeIter->first = pnSrcEdgesBtw2ConsecTimes[nEdgeIndx] + nArrayOffset;
          vEdgeIter->second = pnDstEdgesBtw2ConsecTimes[nEdgeIndx] + nArrayOffset;
          double curW = addW; 
          if (goodEdge.count(nEdgeIndx)) {
              curW = 0;
          }
          (*pfEdgeWeightPtr) = pfData[vEdgeIter->first] + curW;
          vEdgeIter++;
          pfEdgeWeightPtr++;
        }
		
      nArrayOffset += nNoOfGridLocs;
    }
  nDataDepth++;
  nNoOfEdges += (nDataDepth - 1) * nEdgeCounter;
	
	
  //Constructing the graph
  m_pG = new KShorthestPathGraph::BaseGraphType(
                                                vEdges.begin(), 
                                                vEdges.begin() + nNoOfEdges, 
                                                pfEdgeWeights, nNoOfNodes);
	
  //Deallocations
  vEdges.clear();
  delete[] pfEdgeWeights;
  delete[] pnSrcEdgesBtw2ConsecTimes;
  delete[] pnDstEdgesBtw2ConsecTimes;
}

KShorthestPathGraph::~KShorthestPathGraph()
{
  delete m_pG;
}
