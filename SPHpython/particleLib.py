from constants import WIDTH, HEIGHT, DELTA_VOLUME_X, DELTA_VOLUME_Y, NOMINAL_DENSITY, COLLISION_DAMPING, SMOOTHING_RADIUS
from vector2 import Vector2
from equations import calculatePressure


class MyParticle:
    def __init__(self, _position):
        self.position = _position
        self.speed = Vector2(0, 0)
        self.density = NOMINAL_DENSITY
        self.volume  = DELTA_VOLUME_X * DELTA_VOLUME_Y
        self.mass = self.density * self.volume
        self.pressure = 0
        

particlesNumber = 0
particles = []
partitionnedParticles = {}


def generateParticles():

    offsetX = 3*DELTA_VOLUME_X
    offsetY = 3*DELTA_VOLUME_Y

    horizontalNumber = (WIDTH - offsetX*1.5) // DELTA_VOLUME_X
    verticalNumber = (HEIGHT - offsetY*1.5) // DELTA_VOLUME_Y

    global particlesNumber 
    particlesNumber = horizontalNumber * verticalNumber

    index = 0
    for x in range(int(horizontalNumber)):
        for y in range(int(verticalNumber)):
            newPosition = Vector2(offsetX + x * DELTA_VOLUME_X, offsetY + y * DELTA_VOLUME_Y)
            particles.append(MyParticle(newPosition))

            index += 1

    for particle in particles:
        particle.pressure = calculatePressure(particle);

    print(particlesNumber)

def collisions(_particle):

    position = _particle.position
    if position.x < 0:
        position.x = 0
        _particle.speed.x *= -COLLISION_DAMPING

    if position.x > WIDTH:
        position.x = WIDTH
        _particle.speed.x *= -COLLISION_DAMPING

    if position.y < 0:
        position.y = 0
        _particle.speed.y *= -COLLISION_DAMPING

    if position.y > HEIGHT:
        position.y = HEIGHT
        _particle.speed.y *= -COLLISION_DAMPING


def gridCell(_position):
    return (_position.x//SMOOTHING_RADIUS, _position.y//SMOOTHING_RADIUS)


def updatePartitionning():
    for x in range(-1, int(WIDTH//SMOOTHING_RADIUS) + 2):
        for y in range(-1, int(HEIGHT//SMOOTHING_RADIUS) + 2):
            partitionnedParticles[(x, y)] = []

    for index in range(int(particlesNumber)):
        particle = particles[index]
        partitionnedParticles[gridCell(particle.position)].append(index)


def particlesInRange(_particle):
    OGcell = gridCell(_particle.position)

    cells = [OGcell, (OGcell[0], OGcell[1] + 1), (OGcell[0] + 1, OGcell[1] + 1), (OGcell[0] + 1, OGcell[1]), 
                   (OGcell[0] + 1, OGcell[1] - 1), (OGcell[0], OGcell[1] - 1), (OGcell[0] - 1, OGcell[1] - 1), 
                   (OGcell[0] - 1, OGcell[1]), (OGcell[0] - 1, OGcell[1] + 1)]

    res = []
    for cell in cells:
        res += partitionnedParticles[cell]

    return res