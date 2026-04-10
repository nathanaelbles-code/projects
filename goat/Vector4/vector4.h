#ifndef VECTOR4
#define VECTOR4


#include <stdbool.h> 
#include <math.h>
#include <stdio.h>


typedef struct{
    
    float x;
    float y;
    float z;
    float w;
} Vec4;



Vec4 vecZero();

Vec4 addVec(Vec4 _vec1, Vec4 _vec2);

Vec4 subVec(Vec4 _vec1, Vec4 _vec2);

Vec4 multVec(Vec4 _vec, float _factor);

void printVec(Vec4 _vec);

bool sameVec(Vec4 _vec1, Vec4 _vec2);

float distance(Vec4 _position1, Vec4 _position2);

float norm(Vec4 _vector);

Vec4 normalized(Vec4 _vector);

float scalarProduct(Vec4 _vec1, Vec4 _vec2);

#endif 