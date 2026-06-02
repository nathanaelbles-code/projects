# Simulateur de fluides SPH — C / OpenGL

Simulateur de fluides en surface libre implémenté from scratch en C,
avec rendu temps réel via SDL2 et OpenGL.

## Fonctionnalités
- Méthode SPH (Smoothed Particle Hydrodynamics) complète
- Modélisation de fluides à surface libre
- Interaction en temps réel avec forces externes
- Grille spatiale pour l'optimisation de la recherche de voisinage
- Paramètres physiques configurables (viscosité, pression, densité)

## Limitations connues
- Instabilités numériques observables sur les bords du domaine
- Performances non optimales pour N > ~2000 particules

## Comment exécuter
1. Installer SDL2 et OpenGL/GLEW
2. Compiler :
gcc main.c Vector4/vector4.c Tools/tools.c \
    Equations/equations.c Particle/particle.c \
    SpatialGrid/spatialGrid.c \
    -o executable -lSDL2 -lGLEW -lGL -lm
3. Lancer : ./executable
