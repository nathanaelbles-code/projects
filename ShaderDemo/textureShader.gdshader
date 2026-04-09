shader_type spatial;
render_mode cull_disabled, unshaded;

group_uniforms Maps;

uniform sampler2D normalMap : hint_normal;
uniform sampler2D colorPalette : source_color;
uniform sampler2D colorLayers[5] : source_color;


group_uniforms Vertex;

uniform float size;
uniform float intensity;


group_uniforms Light;

uniform float highLightTreshold : hint_range(0.0, 1.0, 0.1);
uniform float shadowTreshold : hint_range(-1.0, 0.0, 0.1);
uniform float rimTreshold : hint_range(4.0, 14.0, 0.25);
uniform float fullRimTreshold : hint_range(0.0, 0.3, 0.01);
uniform float lightColorInfluence : hint_range(0.0, 1.0, 0.1);


group_uniforms Imported;

uniform vec3 lightDirection;
uniform float lightIntensity;
uniform vec3 lightColor;
uniform sampler2D hatch;
uniform float hatchSize;
uniform float frameTime;


float fresnel(vec3 _normal, vec3 view)
{
	//vec3 normal = texture(normalMap, _uv).rgb;
	return 1.0 - clamp(dot(normalize(_normal), normalize(view)), 0.0, 1.0);
}

float rimLight(vec3 _normal, vec3 _view)
{
	float rimLightPower = -1.0 * (fresnel(_normal, _view) - 1.0);
	rimLightPower = 1.0 - sqrt(1.0 - exp(-rimTreshold *  rimLightPower));
	if (rimLightPower < 0.01)
		rimLightPower = 0.0;

	rimLightPower *= clamp(dot(_normal, lightDirection), 0.0, 1.0);

	if (rimLightPower > fullRimTreshold)
		rimLightPower = 1.0;

	return rimLightPower;
}

vec3 colorPicker(float _index, float _shade)
{
    float u = floor(_index) + 0.5;
    u /= 6.0;

    float v = (_shade + 0.5) / 3.0;
    return texture(colorPalette, vec2(u, v)).rgb;
}

vec3 lightColoring(float _lightDot, vec2 _UV)
{
	float shade;
	if (_lightDot > highLightTreshold)
		shade = 0.0;
	else if (_lightDot < shadowTreshold)
		shade = 2.0;
	else
		shade = 1.0;

	vec3 color = colorPicker(0, shade);
	for (int layer = 0; layer < 5; layer++)
	{
		float factor = texture(colorLayers[layer], _UV).r;
		color = mix(colorPicker(float(layer+1), shade), color, factor);
	}

	return color;
}

float hatchingMask(float _lightDot, vec2 _UV)
{
	float roundedTime = round(TIME / frameTime) * frameTime;
	float mask = 1.0;
	if (_lightDot < 0.0)
	{
		mask = texture(hatch, _UV * hatchSize + roundedTime).r * 2.0 - 1.0;

		if (mask > 0.8)
			mask = 1.0;
		else
			mask = 0.0;
		//mask = clamp(mask, 0.0, 1.0);
	}

	return mask;
}

void vertex()
{
    //vec3 worldPos = NODE_POSITION_WORLD + VERTEX;
    //vec3 viewDir = normalize(CAMERA_POSITION_WORLD - worldPos);
//
    //float fresnelMask = fresnel(NORMAL, viewDir);
	//
	//if (fresnelMask > 0.90)
	//{
		//float roundedTime = round(TIME / frameTime) * frameTime;
	//
		//float heightX = pow(abs(cos(VERTEX.y * size + roundedTime * 10.0)), 0.5) * intensity
		 //- pow(abs(cos(VERTEX.z * size * 0.7 + roundedTime * 5.0)), 0.5) * intensity * 1.3;
		//float heightY = pow(abs(cos(VERTEX.x * size + roundedTime * 15.0)), 0.5) * intensity
		 //- pow(abs(cos(VERTEX.z * size * 0.7 + roundedTime * 10.0)), 0.5) * intensity * 1.3;
		//float heightZ = pow(abs(cos(VERTEX.y * size + roundedTime * 20.0)), 0.5) * intensity
		 //- pow(abs(cos(VERTEX.x * size * 0.7 + roundedTime * 15.0)), 0.5) * intensity * 1.3;
		//VERTEX += vec3(heightX, heightY, heightZ);
	//}
}

void fragment() {
	// IMPORTANT : Le calcul du fresnel doit se faire avant la modification de NORMAL
	// car il a besoin du NORMAL bizzare pour fonctionner.
	// On doit cepandant modifer NORMAL pour avoir la normal map au compositing.
	float rimLightEffect = rimLight(NORMAL, VIEW);

	NORMAL = texture(normalMap, UV).rgb * 2.0 - 1.0;

	float lightDot = dot(NORMAL,  lightDirection);

	ALBEDO = lightColoring(lightDot, UV);

	// Rimlight
	if (lightDot > highLightTreshold)
		ALBEDO = mix(ALBEDO, lightColor, rimLightEffect);
	else if (lightDot< shadowTreshold)
		ALBEDO = mix(vec3(0.0), ALBEDO, hatchingMask(lightDot, SCREEN_UV));
	else if (lightDot < -0.5)
		ALBEDO = mix(ALBEDO, vec3(0.0), rimLightEffect);
}
