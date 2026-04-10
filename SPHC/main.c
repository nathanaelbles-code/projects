//gcc main.c Vector4/vector4.c Tools/tools.c Equations/equations.c Particle/particle.c SpatialGrid/spatialGrid.c -o executable -lSDL2 -lGLEW -lGL -lm
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h> 
#include <time.h>

#include <SDL2/SDL.h>
#include <GL/glew.h>

#include "constants.h"
#include "Equations/equations.h"
#include "Particle/particle.h"
#include "Vector4/vector4.h"
#include "Tools/tools.h"
#include "SpatialGrid/spatialGrid.h"


#pragma region SDL/OpenGL

void sdlOpenGlInit()
{
    SDL_Init(SDL_INIT_VIDEO);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
}

SDL_Window* windowCreation(char* _name)
{
    SDL_Window* window = NULL;
    window = SDL_CreateWindow(_name, 0, 0, 1920, 1080, SDL_WINDOW_OPENGL);
 
    if(!window)
    {
        fprintf(stderr,"Erreur de création de la fenêtre: %s\n",SDL_GetError());
        return NULL;
    }

    return window;
}

SDL_GLContext contextCreation(SDL_Window* _window)
{
    SDL_GLContext context = SDL_GL_CreateContext(_window);
    SDL_GL_SetSwapInterval(1); // V-Sync

    glewExperimental = GL_TRUE;
    if (glewInit() != GLEW_OK) {
        fprintf(stderr, "Erreur initialisation GLEW\n");
        return NULL;
    }

    return context;
}

SDL_Renderer* rendererCreation(SDL_Window* _window)
{
    SDL_Renderer* renderer = NULL;
    renderer = SDL_CreateRenderer(_window, -1, 0);

    if (renderer)
    {
        return renderer;
    }
    else
    {
        fprintf(stderr,"Erreur de création du renderer: %s\n",SDL_GetError());
        return NULL;
    }
}

void events(SDL_Event _currentEvent, bool* _looping)
{
    if (SDL_PollEvent(&_currentEvent))
            {
                switch (_currentEvent.type)
                {
                    case SDL_KEYDOWN:
                        if (_currentEvent.key.keysym.scancode == SDL_SCANCODE_ESCAPE)
                            *_looping = false;
                        break;
                    
                    /*case SDL_MOUSEMOTION:
                        mousePosition.x = _currentEvent.motion.x; 
                        mousePosition.y = _currentEvent.motion.y;
                    break;      

                    case SDL_MOUSEBUTTONDOWN:
                        if (_currentEvent.button.button == SDL_BUTTON_LEFT)
                            clicked = true;
                        break;
                        /*default:
                        fprintf(stdout, "Touche %d non attribuée.\n", currentEvent.type);
                     }     break;*/
                }
            }
}

char* load_shader_source(const char* path) {
    FILE* file = fopen(path, "r");
    if (!file) {
        fprintf(stderr, "Erreur ouverture fichier: %s\n", path);
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    long length = ftell(file);
    rewind(file);

    char* source = malloc(length + 1);
    fread(source, 1, length, file);
    source[length] = '\0';

    fclose(file);
    return source;
}

GLuint compile_shader(const char* path, GLenum type) {
    char* source = load_shader_source(path);
    if (!source) return 0;

    GLuint shader = glCreateShader(type);
    glShaderSource(shader, 1, (const char* const*)&source, NULL);
    glCompileShader(shader);
    free(source);

    GLint success;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if (!success) {
        char infoLog[512];
        glGetShaderInfoLog(shader, 512, NULL, infoLog);
        fprintf(stderr, "Erreur compilation shader (%s):\n%s\n", path, infoLog);
    }

    return shader;
}

GLuint shadersSetup()
{
     GLuint vertexShader = compile_shader("vertex.glsl", GL_VERTEX_SHADER);
     GLuint fragmentShader = compile_shader("fragment.glsl", GL_FRAGMENT_SHADER);
 
     GLuint shaderProgram = glCreateProgram();
     glAttachShader(shaderProgram, vertexShader);
     glAttachShader(shaderProgram, fragmentShader);
     glLinkProgram(shaderProgram);
 
     GLint success;
     glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
     if (!success) {
         char infoLog[512];
         glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
         fprintf(stderr, "Erreur linkage shader program:\n%s\n", infoLog);
     }
 
     glDeleteShader(vertexShader);
     glDeleteShader(fragmentShader);

     return shaderProgram;
}

#pragma endregion



int main(int argc, char** argv)
{
    
    generateParticles();
    
    #pragma region SDL et Shaders

    // Que du setup de sdl et OpenGL (fenêtres, linkage des shaders...)
    sdlOpenGlInit();

    SDL_Window* window = windowCreation("Window");
    if (window == NULL)
        return -1;

    SDL_GLContext context = contextCreation(window);

    SDL_Renderer* renderer = rendererCreation(window);
    if (renderer == NULL)
        return -1;

    GLuint shaderProgram = shadersSetup();

    // Pour dessiner sur chaque pixel de l'écran
    float canvas[12] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        1.0f,  1.0f,

        -1.0f, -1.0f,
        1.0f,  1.0f,
        -1.0f, 1.0f
    };

    // Tout ça juste pour dessiner deux triangles qui recouvrent l'écran
    GLuint VAO, VBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(canvas), canvas, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, 0); 
    glBindVertexArray(0);


    // Créer le UBO qui contient le tableau de particules
    GLuint ubo;
    glGenBuffers(1, &ubo);
    glBindBuffer(GL_UNIFORM_BUFFER, ubo);

    Vec4* particlesPositions = onlyParticlesPositions();

    /*for (int i = 0; i < particlesNumber; i++)
    {
        printVec(particlesPositions[i]);
    }*/


    glBufferData(GL_UNIFORM_BUFFER, particlesNumber * sizeof(Vec4), particlesPositions, GL_DYNAMIC_DRAW);
    free(particlesPositions);

    // Lier le UBO au binding point 0
    glBindBufferBase(GL_UNIFORM_BUFFER, 0, ubo);

    #pragma endregion

    bool* looping = malloc(sizeof(bool));
    *looping = true;

    SDL_Event currentEvent;



    int** neighbors = malloc(particlesNumber * sizeof(int*));

    for (int i = 0; i < particlesNumber; i++)
    {
        neighbors[i] = malloc(sizeof(int) * particlesNumber);
    }


    while (*looping)
    {
        events(currentEvent, looping);
    
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);

        glDrawArrays(GL_TRIANGLES, 0, 12);

        SDL_GL_SwapWindow(window);

        // Passage des constantes au fragment shader
        GLint radiusLocation = glGetUniformLocation(shaderProgram, "smoothing_radius");
        glUniform1i(radiusLocation, SMOOTHING_RADIUS);


        GLint numberLocation = glGetUniformLocation(shaderProgram, "particleNumber");
        glUniform1i(numberLocation, particlesNumber);


        updateSpatialLookup();


        for (int i = 0; i < particlesNumber; i++)
        {
            pointsInRange(i, neighbors[i]);
        }


        for (int i = 0; i < particlesNumber; i++)
        {
            particles[i].density = calculateDensity(&particles[i], neighbors[i]);
        }


        for (int i = 0; i < particlesNumber; i++)
        {

            particles[i].pressure = calculatePressure(&particles[i]);
        }


        for (int i = 0; i < particlesNumber; i++)
        {
            Vec4 force = vecZero();

            Vec4 sV = speedVariation(&particles[i], neighbors[i]);

            force = addVec(force, sV);
            force = addVec(force, calculateViscosity(&particles[i], neighbors[i]));
            particles[i].acceleration = force;
        }


        for (int i = 0; i < particlesNumber; i++)
        {
            particles[i].speed = addVec(particles[i].speed, multVec(particles[i].acceleration, DELTA_TIME));
        }


        for (int i = 0; i < particlesNumber; i++)
        {
            particles[i].speed = addVec(particles[i].speed, calculateXSPH(&particles[i], neighbors[i]));
        }


        for (int i = 0; i < particlesNumber; i++)
        {
            particles[i].position = addVec(particles[i].position, multVec(particles[i].speed, DELTA_TIME));
            collisions(&particles[i]);
        }

        // On update le UBO
        glBindBuffer(GL_UNIFORM_BUFFER, ubo); 

        Vec4* particlesPositions = onlyParticlesPositions();
        glBufferData(GL_UNIFORM_BUFFER, particlesNumber * sizeof(Vec4), particlesPositions, GL_DYNAMIC_DRAW);
        free(particlesPositions);

        glBindBuffer(GL_UNIFORM_BUFFER, 0);

    }
    
    free(looping);
    free(particles);
    free(spatialLookup);
    free(startIndices);
    for (int i = 0; i < particlesNumber; i++)
    {
        free(neighbors[i]); 
    }
    free(neighbors);



    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);

    SDL_GL_DeleteContext(context);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}