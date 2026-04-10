#include "particle.h"
#include "../Equations/equations.h"

int particlesNumber = 0;

Particle* particles;


void generateParticles()
{
    int offsetX = 2;
    int offsetY = 2;

    // int horizontalNumber = (WIDTH - offsetX*1.5);
    // int verticalNumber = (HEIGHT - offsetY*1.5);
    int horizontalNumber = WIDTH/DELTA_VOLUME_X - offsetX;
    int verticalNumber = HEIGHT/DELTA_VOLUME_Y - offsetY;


    particlesNumber = horizontalNumber * verticalNumber;

    particles = malloc(sizeof(Particle) * particlesNumber);
    spatialLookup = malloc(sizeof(Vec4) * particlesNumber);
    startIndices = malloc(sizeof(Vec4) * particlesNumber);


    int index = 0;
    for (int x = offsetX; x < horizontalNumber; x++)
    {
        for (int y = offsetY; y < verticalNumber; y++)
        {
            Vec4 newPosition = {.x = x * DELTA_VOLUME_X + 100, .y = 100 + y * DELTA_VOLUME_Y, .z = 0, .w = 0};
            Particle newPart = {.position = newPosition, .speed = vecZero(), .acceleration = vecZero(), .density = NOMINAL_DENSITY, .volume = DELTA_VOLUME_X * DELTA_VOLUME_Y, .mass = NOMINAL_DENSITY * DELTA_VOLUME_X * DELTA_VOLUME_Y, .pressure = 0};
            
            particles[index] = newPart;
            index++;
        }
    }


    for (int index = 0; index < particlesNumber; index++)
    {
        particles[index].pressure = calculatePressure(&particles[index]);
    }
}


void collisions(Particle* _particle)
{
    Vec4* position = &_particle->position;
    if (position->x < 100)
    {
        position->x = 100;
        _particle->speed.x *= -COLLISION_DAMPING;
    }
    else if (position->x > WIDTH + 100)
    {
        position->x = WIDTH + 100;
        _particle->speed.x *= -COLLISION_DAMPING;
    }


    if (position->y < 100)
    {
        position->y = 100;
        _particle->speed.y *= -COLLISION_DAMPING;
    }
    else if (position->y > HEIGHT + 100)
    {
        position->y = HEIGHT + 100;
        _particle->speed.y *= -COLLISION_DAMPING;
    }
}


Vec4 gridCell(Vec4 _position)
{
    Vec4 gridPos = {.x = (int)(_position.x/SMOOTHING_RADIUS), .y = (int)(_position.y/SMOOTHING_RADIUS), .z = 0, .w = 0};
    return gridPos;
}


Vec4* onlyParticlesPositions()
{
    Vec4* particlesPosition = malloc(sizeof(Vec4)*particlesNumber);
    for (int index = 0; index < particlesNumber; index++)
    {
        Vec4 new = {.x = particles[index].position.x, .y = particles[index].position.y, .z = particles[index].speed.x, .w = particles[index].speed.w};
        particlesPosition[index] = new;
    }

    return particlesPosition;
}