#version 420 core
out vec4 FragColor;


const int number = 3000;

const float pi = 3.14159265359f;
uniform int smoothing_radius;
float smoothing_volume = pi * pow(smoothing_radius, 8) / 4;

int particleSize = 3;
uniform float targetDensity;
uniform float pressureMultiplier;
uniform int particleNumber;

layout(std140, binding = 0) uniform Buffer {
    vec4 particles[number];
};


float distance(vec4 _position1, vec4 _position2)
{
    float xCoord = (_position2.x - _position1.x) * (_position2.x - _position1.x);
    float yCoord = (_position2.y - _position1.y) * (_position2.y - _position1.y);
    return sqrt(xCoord + yCoord);
}


int justPoints()
{
    for (int index = 0; index < particleNumber; index++)
    {
        if (distance(gl_FragCoord, particles[index]) <= particleSize)
            return index;
    }

    return -1;
}

// float smoothingKernel(float _distance)
// {
//     float squares = smoothing_radius * smoothing_radius - _distance * _distance;
//     float cube = squares * squares * squares;
//     return max(0.0, cube)/smoothing_volume;
// }

// float calculateDensity(vec4 _position)
// {
//     float density = 0;

//     for (int index = 0; index < number; index++)
//     {
//         float dist = distance(_position, particles[index]);
//         density += smoothingKernel(dist);;
//     }

//     return density;
// }

// float convertDensityToPressure(float _density)
// {
//     float error = _density - targetDensity;
//     return error * pressureMultiplier;
// }

float speedNorm(int index)
{
    return sqrt(particles[index].z * particles[index].z + particles[index].w * particles[index].w);
}

void main()
{
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    int point = justPoints();
    if (point != -1)
    {
        color = vec4(speedNorm(point)/60, 0.0, 0.0, 1.0);
    }

    FragColor = color;
} 