shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depthTexture: hint_depth_texture, filter_linear_mipmap;
uniform sampler2D normalTexture : hint_normal_roughness_texture;


group_uniforms Outline;

uniform vec3 outlineColor : source_color;
uniform float depthTreshold = 0.05;


group_uniforms Imported;

uniform vec3 lightDirection;


vec3 get_original(vec2 screen_uv)
{
	return texture(screen_texture, screen_uv).rgb;
}

float get_depth(vec2 screen_uv, mat4 inv_projection_matrix)
{
	float depth = texture(depthTexture, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= -view.w;
	return view.z;
}

vec2[80] neighborPixels(vec2 _screenUV, int _radius, vec2 _viewportSize)
{
    vec2 texel_size = 1.0 / _viewportSize;

    // Calcul du nombre total de voisins (excluant le pixel central)
    int side = 2 * _radius + 1;
    int totalNeighbors = side * side - 1;

    vec2 result[80];
    int index = 0;

    // Boucle sur le carré de voisins
    for (int dx = -_radius; dx <= _radius; dx++)
    {
        for (int dy = -_radius; dy <= _radius; dy++)
        {
            if (dx == 0 && dy == 0)
                continue;

            result[index] = _screenUV + vec2(float(dx) * texel_size.x, float(dy) * texel_size.y);
            index++;
        }
    }

    return result;
}

void vertex()
{
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment()
{
	// Screen texture
	vec3 original = get_original(SCREEN_UV);


	// Depth
	float depth = get_depth(SCREEN_UV, INV_PROJECTION_MATRIX);

	int outlineSize = 3;

	int side = 2 * outlineSize + 1;
    int totalNeighbors = side * side - 1;

	vec2 uvs[80] = neighborPixels(SCREEN_UV, outlineSize, VIEWPORT_SIZE);


	// Edge detection
	float depthDiff = 0.0;
	for (int i = 0; i < totalNeighbors; i++)
	{
		float d = get_depth(uvs[i], INV_PROJECTION_MATRIX);

		depthDiff += depth - d;
	}
	float depthEdge = step(depthTreshold, depthDiff);

	ALBEDO = mix(original, outlineColor, depthEdge);
}
