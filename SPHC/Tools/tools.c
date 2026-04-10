#include "tools.h"

float max(float _float1, float _float2)
{
    if (_float1 > _float2)
        return _float1;
    else
        return _float2;
}

int sign(float _value)
{
    if (_value >= 0)
        return 1;
    else
        return -1;
}