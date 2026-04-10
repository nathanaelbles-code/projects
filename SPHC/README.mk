# Simulateur de fluides SPH (Surface Particle Hydrodynamics) – Python

Voici la version en C de mon simulateur de fluides en surface libre SPH.

## Objectif
Ce projet vise à simuler le comportement de fluides à l’aide de la méthode SPH. Il m’a permis de travailler sur :
- La modélisation physique de fluides
- La programmation orientée performance
- Le débogage et l’optimisation des paramètres physiques (viscosité, pression…)

## Contexte
Suite à une réussite en python, je me suis lancé dans la finition de cette version en C plus performante.
Bien que le résultat soit déçent, il reste encore des instabilités et des comportements étranges (observables sur les bords).

## Comment exécuter
1. Installer SDL2 et s'assurer d'avoir OpenGL compris avec.
2. On compile dans le terminal avec gcc main.c Vector4/vector4.c Tools/tools.c Equations/equations.c Particle/particle.c SpatialGrid/spatialGrid.c -o executable -lSDL2 -lGLEW -lGL -lm
3. On exécute avec ./executable
