#ifndef CONSTANTS
#define CONSTANTS

// Volume initial d'une particule (rectangle)
#define DELTA_VOLUME_X 8
#define DELTA_VOLUME_Y 8


// Pour marquer des "murs" qui contiendraient mon fluide, en l'occurence les dimensions de mon écran
#define WIDTH 256
#define HEIGHT 256


// Le multiplicateur de la gravité et des rebonds sur le mur
#define GRAVITY 300
#define COLLISION_DAMPING 0.3

#define PI 3.14159265359f

#define SMOOTHING_RADIUS 16


#define NOMINAL_DENSITY 10 // Masse volumique nominale (on divise par 100)
#define NOMINAL_SOUND_SPEED 8 // Vitesse du son nominale (ça aussi on le divise sinon ça donne un int trop grand)
#define POLYTROPIC_INDEX 7 // Indice polytropique
#define VISCOSITY 0.05
#define XSPH 0.075

#define DELTA_TIME 0.01

#endif