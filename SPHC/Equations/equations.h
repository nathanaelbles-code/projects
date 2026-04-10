#ifndef EQUATIONS
#define EQUATIONS

#include "../Particle/particle.h"
#include "../constants.h"
// #include "../Vector4/vector4.h"


float smoothingKernel(float d);

float smoothingKernelDerivative(float d);

Vec4 volumeGradient(Particle *p, Particle *o);

float densityVariation(Particle _particle, int* _mask);

float calculateDensity(Particle *p, int *mask);

float smoothingKernelLaplacian(float _distance);

Vec4 calculateViscosity(Particle *p, int *mask);

Vec4 speedVariation(Particle *p, int *mask);

float calculatePressure(Particle *p);

Vec4 calculateXSPH(Particle *p, int *mask);

float computeCompressibilityFactor(Particle *p, int *mask);

#endif