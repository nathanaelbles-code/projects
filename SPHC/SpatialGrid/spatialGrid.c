#include "spatialGrid.h"


Vec4* spatialLookup;
int* startIndices;


Vec4 positionToGridCell(Vec4 _position)
{
    int cellX = (_position.x/SMOOTHING_RADIUS);
    int cellY = (_position.y/SMOOTHING_RADIUS);
    Vec4 cell = {.x = cellX, .y = cellY, .z = 0, .w = 0};
    return cell;
}


int HashCell(Vec4 _position) 
{
    const int prime1 = 73856093;
    const int prime2 = 19349663;

    int x = (int)_position.x;
    int y = (int)_position.y;

    int res = (x * prime1) ^ (y * prime2);
    return res;
}


int hashToKey(int _value)
{
    int key = _value % particlesNumber;
    if (key < 0)
        return key + particlesNumber;
    else
        return key;
}


void updateSpatialLookup()
{
    for (int index = 0; index < particlesNumber; index++)
    {
        startIndices[index] = -1;
    }

    for (int index = 0; index < particlesNumber; index++)
    {
        Vec4 current = particles[index].position;

        Vec4 cell = positionToGridCell(current);

        Vec4 entry = {.x = index, .y = hashToKey(HashCell(cell)), .z = 0, .w = 0};
        //printf("%f\n", entry.y);
        spatialLookup[index] = entry;
        
        // J'insère chaque couple pour que _spatialLookup soie triée
        int insertionIndex = index;
        while (insertionIndex > 0 && spatialLookup[insertionIndex - 1].y > entry.y)
        {            
            // On avance
            spatialLookup[insertionIndex] = spatialLookup[insertionIndex - 1];
            spatialLookup[insertionIndex - 1] = entry;
            insertionIndex--;
        }
    }

    int lastIndex = 0;
    startIndices[(int)spatialLookup[0].y] = 0;
    for (int index = 1; index < particlesNumber; index++)
    {
        Vec4 current = spatialLookup[index];
        if (current.y != spatialLookup[index - 1].y)
            startIndices[(int)current.y] = index;
    }
}


void pointsInRange(int _index, int* _result)
{
    // int* result = malloc(sizeof(int) * particlesNumber);
    int resultIndex = 0;

    Vec4 position = particles[_index].position;
    Vec4 targetCell = positionToGridCell(position);

    // On balaye le carré de cases 3 x 3 autour
    for (int x = targetCell.x - 1; x < targetCell.x + 2; x++)
    {
        for (int y = targetCell.y - 1; y < targetCell.y + 2; y++)
        {
            Vec4 currentCell = {.x = x, .y = y, .z = 0, .w = 0};
            int cellKey = hashToKey(HashCell(currentCell));

            // Si la case est vide on passe
            if (startIndices[cellKey] == -1)
                continue;

            // Dans spatial lookup on balaye toutes les particules comprises dans la case
            for (int i = startIndices[cellKey]; i < particlesNumber; i++)
            {
                // Si on arrive à la fin de la cellule/clé qui nous intéresse on sort de la boucle
                if (spatialLookup[i].y != cellKey)
                    break;

                // On regarde si la particule étrangère est dans le rayon d'action
                int particleIndex = spatialLookup[i].x;
                float dist = distance(particles[particleIndex].position, position);
                if (particleIndex != _index && dist < SMOOTHING_RADIUS)
                {
                    _result[resultIndex] = particleIndex;
                    resultIndex++;
                }
            }
        }
    }

    _result[resultIndex] = -1;
}