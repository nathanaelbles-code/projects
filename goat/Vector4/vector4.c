#include "vector4.h"


Vec4 vecZero()
{
    Vec4 res = {.x = 0.0, .y = 0.0, .z = 0.0, .w = 0.0};
    return res;
}

Vec4 addVec(Vec4 _vec1, Vec4 _vec2)
{
    Vec4 res = {.x = _vec1.x + _vec2.x, .y = _vec1.y + _vec2.y, .z = _vec1.z + _vec2.z, .w = _vec1.w + _vec2.w};
    return res;
}

Vec4 subVec(Vec4 _vec1, Vec4 _vec2)
{
    Vec4 res = {.x = _vec1.x - _vec2.x, .y = _vec1.y - _vec2.y, .z = _vec1.z - _vec2.z, .w = _vec1.w - _vec2.w};
    return res;
}

Vec4 multVec(Vec4 _vec, float _factor)
{
    Vec4 res = {.x = _vec.x * _factor, .y = _vec.y * _factor, .z = _vec.z * _factor, .w = _vec.w * _factor};
    return res;
}

void printVec(Vec4 _vec)
{
    printf("(%f, %f)\n", _vec.x, _vec.y);
}

bool sameVec(Vec4 _vec1, Vec4 _vec2)
{
    return (_vec1.x - _vec2.x) < 1e-8f && (_vec1.y - _vec2.y) < 1e-8f && (_vec1.z - _vec2.z) < 1e-8f && (_vec1.w - _vec2.w) < 1e-8f;
}

float distance(Vec4 _position1, Vec4 _position2)
{
    float xCoord = (_position2.x - _position1.x) * (_position2.x - _position1.x);
    float yCoord = (_position2.y - _position1.y) * (_position2.y - _position1.y);
    return sqrt(xCoord + yCoord);
}

float norm(Vec4 _vector)
{
    float root = (_vector.x * _vector.x) + (_vector.y * _vector.y);
    return sqrt(root);
}

Vec4 normalized(Vec4 _vector)
{
    return multVec(_vector, 1/norm(_vector));
}

float scalarProduct(Vec4 _vec1, Vec4 _vec2)
{
    return _vec1.x * _vec2.x + _vec1.y * _vec2.y;
}