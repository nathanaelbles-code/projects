#ifndef SPATIALGRID
#define SPATIALGRID


#include <stdio.h>

#include "../constants.h"
#include "../Particle/particle.h"


extern Vec4* spatialLookup;
extern int* startIndices;

Vec4 positionToGridCell(Vec4 _position);

int HashCell(Vec4 _position);

int hashToKey(int _value);

void updateSpatialLookup();

void pointsInRange(int _index, int* _result);


#endif