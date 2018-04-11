#version 430

// Greater than and less than functions to avoid using conditionals.
float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}

float when_le(float x, float y) {
  return 1.0 - when_gt(x, y);
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

float colourClamp [8] = { 0.00, 0.14, 0.28, 0.42, 0.58, 0.72, 0.86, 1.00};

// Clamps the colour values without using conditionals.
float setToonColour( in float colour )
{

  int i;

  float outColour = 0;

  for(i = 1; i < 8; i++ )
  {
    outColour += colourClamp[i] * (when_gt(colour, colourClamp[i-1]) * when_le(colourClamp[i], colour));
  }
  
  return outColour;

}

// Structure for holding light parameters
struct LightInfo {
    vec4 Position; // Light position in eye coords.
    vec3 La;       // Ambient light intensity
    vec3 Ld;       // Diffuse light intensity
    vec3 Ls;       // Specular light intensity
};

// We'll have a single light in the scene with some default values
uniform LightInfo Light = LightInfo(
            vec4(2.0, 2.0, 10.0, 1.0),  // position
            vec3(0.2, 0.2, 0.2),        // La
            vec3(1.0, 0.2, 0.2),        // Ld
            vec3(1.0, 1.0, 1.0)         // Ls
            );

// The material properties of our object
struct MaterialInfo {
    vec3 Ka; // Ambient reflectivity
    vec3 Kd; // Diffuse reflectivity
    vec3 Ks; // Specular reflectivity
    float Shininess; // Specular shininess factor
};

// The object has a material
uniform MaterialInfo Material = MaterialInfo(
            vec3(0.1, 0.1, 0.1),    // Ka
            vec3(1.0, 1.0, 1.0),    // Kd
            vec3(1.0, 1.0, 1.0),    // Ks
            10.0                    // Shininess
            );

uniform mat4 MVP;

// This is passed on from the vertex shader
in vec3 LightIntensity;
in vec3 wsVertexNormal;
in vec4 gl_FragCoord;
in vec4 wsVertexPosition;

vec3 newLight;

// This is no longer a built-in variable
layout (location=0) out vec4 FragColor;

void main() {

    //float isSilhouette = dot( (vec4( 0, 0, 0, 0 ) - wsVertexPosition), vec4(wsVertexNormal, 0) );

    vec3 wsVertexPosition = normalize(vec3(-gl_FragCoord.xyz));

    vec3 LightVector      = normalize( vec3(Light.Position) - wsVertexPosition.xyz );

    vec3 Reflected        = reflect( -LightVector, normalize(wsVertexNormal) );

    // Compute the light from the ambient, diffuse and specular components
    newLight = (
        Light.La * Material.Ka +
        Light.Ld * Material.Kd * max( dot(LightVector, normalize(wsVertexNormal)), 0.0 ) +
        Light.Ls * Material.Ks * pow( max( dot(Reflected,wsVertexPosition), 0.0 ), Material.Shininess ));

    // Set the output color of our current pixel
    FragColor = vec4(newLight,1.0);

    FragColor.r = setToonColour( FragColor.r );
    FragColor.g = setToonColour( FragColor.g );
    FragColor.b = setToonColour( FragColor.b );

}
