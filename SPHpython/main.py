import cv2
import numpy as np
import particleLib as prtk
from constants import WIDTH, HEIGHT, DELTA_TIME
from equations import*

def color(_value, _scale):
    return (0, 255 - (particle.speed.norm() * 255 // scale), (particle.speed.norm() * 255 // scale), (particle.speed.norm() * 255 // scale))


prtk.generateParticles()

newImg = 255 * np.ones((HEIGHT, WIDTH, 3), np.uint8)

for particle in prtk.particles:
    cv2.circle(newImg, (particle.position.x, particle.position.y), 4, (180, 0, 0), -1)


running = True
while running:
    prtk.updatePartitionning()

    minSpeed = prtk.particles[0].speed.norm()
    maxSpeed = prtk.particles[0].speed.norm()


    newImg = 255 * np.ones((HEIGHT, WIDTH, 3), np.uint8)

    if cv2.waitKey(1) != -1:
        running = False

    # DENSITÉ
    for p in prtk.particles:
        p.density = calculateDensity(p)

    # PRESSION
    for p in prtk.particles:
        p.pressure = calculatePressure(p)

    # FORCES → ACCÉLÉRATION
    for p in prtk.particles:
        a = Vector2(0, 0)

        a += speedVariation(p)        # pression + gravité
        a += calculateViscosity(p)    # viscosité (Laplacien)

        p.acceleration = a

    # INTÉGRATION DES VITESSES
    for p in prtk.particles:
        p.speed += p.acceleration * DELTA_TIME

    # XSPH (APRÈS intégration)
    for p in prtk.particles:
        p.speed += calculateXSPH(p)

    # INTÉGRATION DES POSITIONS
    for p in prtk.particles:
        p.position += p.speed * DELTA_TIME
        prtk.collisions(p)

        if particle.speed.norm() < minSpeed:
            minSpeed = particle.speed.norm()

        if particle.speed.norm() > maxSpeed:
            maxSpeed = particle.speed.norm()

    scale = maxSpeed - minSpeed
    for particle in prtk.particles:
        cv2.circle(newImg, (int(particle.position.x), int(particle.position.y)), 4, color(particle.speed.norm(), scale), -1)

    cv2.imshow("Image", newImg)




running = True
while running:

    if cv2.waitKey(1) != -1:
        running = False

cv2.destroyAllWindows()