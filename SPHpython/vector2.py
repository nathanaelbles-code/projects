from math import sqrt

class Vector2:
    def __init__(self, _x=0, _y=0):
        self.x = _x
        self.y = _y

    def __add__(self, other):
        return Vector2(self.x + other.x, self.y + other.y)
    
    def __sub__(self, other):
        return Vector2(self.x - other.x, self.y - other.y)

    def __mul__(self, other):
        if type(other) == int or type(other) == float:
            return Vector2(self.x * other, self.y * other)
        else:
            return self.x * other.x + self.y * other.y
        
    def __equ__(self, other):
        return (self.x == other.x) and (self.y == other.y)

    def norm(self):
        return sqrt(self.x * self.x + self.y * self.y)