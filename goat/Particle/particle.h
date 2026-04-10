#ifndef PARTICLE
#define PARTICLE

#include "../constants.h"
#include "../Vector4/vector4.h"
// #include "../Equations/equations.h"
#include "../SpatialGrid/spatialGrid.h"
#include <stdlib.h>
#include <time.h>

typedef struct
{
    Vec4 position;
    Vec4 speed;
    Vec4 acceleration;
    float density;
    float volume;
    float pressure;
    float mass;
} Particle;

extern int particlesNumber;

extern Particle* particles;


void generateParticles();

Vec4* onlyParticlesPositions();

void collisions();

#endif