#include "equations.h"


float smoothingKernel(float _distance)
{
    if (_distance >= SMOOTHING_RADIUS)
        return 0.0f;

    float factor = 4.0f / (PI * powf(SMOOTHING_RADIUS, 8));

    float x = SMOOTHING_RADIUS*SMOOTHING_RADIUS - _distance*_distance;
    return factor * x * x * x;
}


float smoothingKernelDerivative(float _distance)
{
    if (_distance >= SMOOTHING_RADIUS || _distance <= 0.0f)
        return 0.0f;

    float coef = -24.0f / (PI * powf(SMOOTHING_RADIUS, 8));

    float x = SMOOTHING_RADIUS*SMOOTHING_RADIUS - _distance*_distance;
    return coef * _distance * x * x;
}


float smoothingKernelLaplacian(float _distance)
{
    if (_distance >= SMOOTHING_RADIUS)
        return 0.0;

    float squareRadius = SMOOTHING_RADIUS * SMOOTHING_RADIUS;
    float squareDistance = _distance * _distance;

    float coef = 24 / (PI * pow(SMOOTHING_RADIUS, 8));
    return coef * (squareRadius - squareDistance) * (3*squareDistance - squareRadius);
}


Vec4 volumeGradient(Particle* _particle, Particle* _other)
{
    Vec4 result = vecZero();

    Vec4 direction = subVec(_particle->position, _particle->position);

    float dist = norm(direction);
    if (dist > 0.0f)
    {
        direction = multVec(direction, 1.0f / dist);

        float influence = smoothingKernelDerivative(dist);

        result = addVec(result,
            multVec(direction, _other->volume * influence));
    }

    return result;
}


float calculateDensity(Particle* _particle, int *mask)
{
    float density = 0.0f;

    int index = 0;
    while (mask[index] != -1)
    {
        Particle* other = &particles[mask[index]];

        float dist = distance(_particle->position, other->position);

        density += other->mass * smoothingKernel(dist);

        index++;
    }

    return density;
}


float calculatePressure(Particle* _particle)
{
    float rhoRatio = _particle->density / NOMINAL_DENSITY;

    float diff = powf(rhoRatio, POLYTROPIC_INDEX) - 1.0f;

    float factor = (NOMINAL_DENSITY * NOMINAL_SOUND_SPEED * NOMINAL_SOUND_SPEED)/ POLYTROPIC_INDEX;

    return factor * diff;
}


Vec4 speedVariation(Particle* _particle, int *mask)
{
    Vec4 sum = vecZero();

    int index = 0;
    while (mask[index] != -1)
    {
        Particle* other = &particles[mask[index]];

        if (other == _particle)
        {
            index++;
            continue;
        }

        Vec4 direction = subVec(_particle->position, other->position);
        float dist = norm(direction);

        if (dist > 0.0f && dist < SMOOTHING_RADIUS)
        {
            direction = multVec(direction, 1.0f / dist);

            float grad = smoothingKernelDerivative(dist);

            Vec4 gradVec = multVec(direction, grad);

            float factor =(_particle->pressure / (_particle->density * _particle->density)) + (other->pressure / (other->density * other->density));

            factor *= other->mass;

            sum = addVec(sum, multVec(gradVec, factor));
        }

        index++;
    }

    Vec4 gravity = {.x = 0, .y = -GRAVITY, .z = 0, .w = 0};

    return subVec(gravity, sum);
}


Vec4 calculateViscosity(Particle* _particle, int *mask)
{
    Vec4 force = vecZero();

    int index = 0;
    while (mask[index] != -1)
    {
        Particle* other = &particles[mask[index]];

        float dist = distance(_particle->position, other->position);

        if (dist < SMOOTHING_RADIUS && other->density > 0)
        {
            Vec4 speedDiff = subVec(other->speed, _particle->speed);

            float laplacian = smoothingKernelLaplacian(dist);
            laplacian = fmin(laplacian, 1000.0f);

            float clampedDensity = fmax(other->density, 0.0001f);

            force = addVec(force, multVec(speedDiff, (other->mass / clampedDensity) * laplacian));
        }

        index++;
    }

    return multVec(force, VISCOSITY);
}


Vec4 calculateXSPH(Particle* _particle, int *mask)
{
    Vec4 sum = vecZero();

    int index = 0;
    while (mask[index] != -1)
    {
        Particle* other = &particles[mask[index]];

        float dist = norm(subVec(other->position, _particle->position));

        if (dist < SMOOTHING_RADIUS && other->density > 0)
        {
            Vec4 speedDiff = subVec(other->speed, _particle->speed);

            float volume = other->mass / other->density;

            sum = addVec(sum, multVec(speedDiff, volume * smoothingKernel(dist)));
        }

        index++;
    }

    return multVec(sum, XSPH);
}


float computeCompressibilityFactor(Particle *p, int *mask)
{
    float C = (p->density / NOMINAL_DENSITY) - 1.0f;

    float sum = 0.0f;

    int i = 0;
    while (mask[i] != -1)
    {
        Particle *o = &particles[mask[i]];

        float d = norm(subVec(p->position, o->position));

        float k = smoothingKernelDerivative(d);

        sum += k * k;

        i++;
    }

    return -C / (sum + 1e-3f);
}