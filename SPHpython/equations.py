from constants import SMOOTHING_RADIUS, GRAVITY, NOMINAL_DENSITY, POLYTROPIC_INDEX, NOMINAL_SOUND_SPEED, VISCOSITY, XSPH
import particleLib as prtk
from vector2 import Vector2
from math import pi


def smoothingKernel(_distance):
    if _distance >= SMOOTHING_RADIUS:
        return 0.0

    factor = 4 / (pi * pow(SMOOTHING_RADIUS, 8))
    cube = SMOOTHING_RADIUS*SMOOTHING_RADIUS - _distance*_distance
    return factor * cube * cube * cube


def smoothingKernelDerivative(_distance):
    if _distance >= SMOOTHING_RADIUS or _distance == 0:
        return 0.0
    
    coef = -24 / (pi * pow(SMOOTHING_RADIUS, 8))
    square = SMOOTHING_RADIUS*SMOOTHING_RADIUS - _distance*_distance
    return coef * _distance * square*square


def volumeGradient(_particle, _other):
    result = Vector2(0, 0)

    direction = _particle.position - _other.position

    distance = direction.norm()

    if distance > 0:
        direction *= 1/distance

        influence = smoothingKernelDerivative(distance);

        result += direction * _other.volume * influence
        # result += direction * _other.mass * influence

    return result;


def densityVariation(_particle):

    sum = 0.0
    for other in prtk.particles:
        if other == _particle:
            continue

        if other.density > 1:
            factor = other.mass / other.density

            speedDiff = other.speed - _particle.speed
            gradient = volumeGradient(_particle, other)

            scalar = speedDiff * gradient
            sum += factor * scalar

    return -_particle.density * sum


def calculateDensity(_particle):
    density = 0.0

    for index in prtk.particlesInRange(_particle):
        other = prtk.particles[index]

        distance = (_particle.position - other.position).norm()
        density += other.mass * smoothingKernel(distance)

    return density


def smoothingKernelLaplacian(_distance):
    if _distance >= SMOOTHING_RADIUS:
        return 0.0

    squareRadius = SMOOTHING_RADIUS * SMOOTHING_RADIUS
    squareDistance = _distance * _distance

    coef = 24 / (pi * pow(SMOOTHING_RADIUS, 8))
    return coef * (squareRadius - squareDistance) * (3*squareDistance - squareRadius)


def calculateViscosity(_particle):
    force = Vector2(0, 0)

    for index in prtk.particlesInRange(_particle):
        other = prtk.particles[index]

        distance = (_particle.position - other.position).norm()

        if distance < SMOOTHING_RADIUS and other.density > 0:
            speedDiff = other.speed - _particle.speed

            force += speedDiff * (other.mass/other.density) * smoothingKernelLaplacian(distance)

    return force * VISCOSITY


def speedVariation(_particle):
    sum = Vector2(0, 0)

    for index in prtk.particlesInRange(_particle):
        other = prtk.particles[index]

        if other == _particle or _particle.position == other.position:
            continue

        #distance = (other.position - _particle.position).norm()
        gradient = volumeGradient(_particle, other)

        if abs(_particle.density * other.density) > 1:
            factor = (_particle.pressure + other.pressure) / (_particle.density * other.density)
            factor *= other.mass

            sum += gradient * factor

    gravity = Vector2(0, GRAVITY)
    return gravity - sum 


def calculatePressure(_particle):
    # print(_particle.density)

    rhoRatio = _particle.density / NOMINAL_DENSITY


    diff = pow(rhoRatio, POLYTROPIC_INDEX) - 1.0
    factor = (NOMINAL_DENSITY * NOMINAL_SOUND_SPEED * NOMINAL_SOUND_SPEED) / POLYTROPIC_INDEX
    return factor * diff


def calculateXSPH(_particle):
    sum = Vector2(0, 0)
    for index in prtk.particlesInRange(_particle):
        other = prtk.particles[index]

        distance = (other.position - _particle.position).norm()

        if distance < SMOOTHING_RADIUS and other.density > 0:
            speedDiff = other.speed - _particle.speed
            volume = other.mass/other.density
            sum += speedDiff * volume * smoothingKernel(distance)

    return sum * XSPH


def computeCompressibilityFactor(_particle):
    C = (_particle.density/NOMINAL_DENSITY) - 1

    sum = 0
    for index in prtk.particlesInRange(_particle):
        other = prtk.particles[index]

        distance = (other.position - _particle.position).norm()
        sum += (smoothingKernelDerivative(distance)) * (smoothingKernelDerivative(distance))

    return -C/(sum + 1e-3)