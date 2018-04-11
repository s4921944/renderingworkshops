#version 430

// Structure for holding light parameters
struct LightInfo {
    vec4 Position; // Light position in eye coords.
    vec3 La; // Ambient light intensity
    vec3 Ld; // Diffuse light intensity
    vec3 Ls; // Specular light intensity
};

// We'll have a single light in the scene with some default values
uniform LightInfo Light = LightInfo(
            vec4(2.0, 2.0, 10.0, 1.0),   // position
            vec3(0.2, 0.2, 0.2),        // La
            vec3(1.0, 1.0, 1.0),        // Ld
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
            vec3(0.8, 0.2, 0.2),    // Kd
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

    vec3 wsVertexPosition = normalize(vec3(-gl_FragCoord.xyz));

    vec3 LightVector = normalize( vec3(Light.Position) - wsVertexPosition.xyz );

    vec3 Reflected = reflect( -LightVector, normalize(wsVertexNormal) );

    // Compute the light from the ambient, diffuse and specular components
    newLight = (
        Light.La * Material.Ka +
        Light.Ld * Material.Kd * max( dot(LightVector, normalize(wsVertexNormal)), 0.0 ) +
        Light.Ls * Material.Ks * pow( max( dot(Reflected,wsVertexPosition), 0.0 ), Material.Shininess ));

    // Set the output color of our current pixel
    FragColor = vec4(newLight,1.0);
}
