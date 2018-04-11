#version 430

// The output colour. At location 0 it will be sent to the screen.
layout (location=0) out vec4 fragColor;

// The uv coordinates of this fragment
in vec2 FragmentUV;

// The time elapsed (by default there is no animation)
uniform float t = 0.0;

uniform int iter = 100;

// Define our color palette to make a nice colour ramp (more options are available at
// http://iquilezles.org/www/articles/palettes/palettes.htm
uniform vec3 ColorPalette[4] = vec3[](vec3(0.8, 0.5, 0.4), vec3(0.2, 0.4, 0.2), vec3(2.0, 1.0, 1.0), vec3(0.00, 0.25, 0.25));
//uniform vec3 ColorPalette[4] = vec3[](vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5), vec3(1.0, 1.0, 1.0), vec3(0.00, 0.33, 0.67));

// Cosine based palette from http://iquilezles.org/www/articles/palettes/palettes.htm
vec3 Palette(in float t) {
    return ColorPalette[0] + ColorPalette[1]*cos( 6.28318*(ColorPalette[2]*t+ColorPalette[3]) );
}

// ** Here you will have to implement some code to create Julia or Mandelbrot fractals. Appropriate this from the following link:
// ** http://nuclear.mutantstargoat.com/articles/sdr_fract/

vec3 mandelbrot(vec2 fracPos)
{

    vec2 position;
    int i;

    position = fracPos;

    for(i=0;i<iter;i++)
    {
        float x = (position.x * position.x - position.y * position.y) + fracPos.x;
        float y = (position.y * position.x + position.x * position.y) + fracPos.y;

        if (( x*x + y*y ) > 4.0) break;
        position.x = x;
        position.y = y;
    }

    return Palette((( i == iter ) ? 0.0 : float(i)) / iter);

}

vec3 julia( vec2 fracPos )
{

    vec2 position;
    int i;

    position.x = 3.0 * (FragmentUV.s - 0.5);
    position.y = 2.0 * (FragmentUV.t - 0.5);

    for(i=0;i<iter;i++)
    {
        float x = (position.x * position.x - position.y * position.y) + fracPos.x;
        float y = (position.y * position.x + position.x * position.y) + fracPos.y;

        if (( x*x + y*y ) > 4.0) break;
        position.x = x;
        position.y = y;
    }

    return Palette((( i == iter ) ? 0.0 : float(i)) / iter);

}

float sharedFractalFunction( position1, positon2 )
{

    int i;

    for(i=0;i<iter;i++)
    {
        float x = (position2.x * position2.x - position2.y * position2.y) + position1.x;
        float y = (position2.y * position2.x + position2.x * position2.y) + position1.y;

        if (( x*x + y*y ) > 4.0) break;
        position2.x = x;
        position2.y = y;
    }

    return Palette((( i == iter ) ? 0.0 : float(i)) / iter);

}

subroutine vec3 fractalType( vec2 );

subroutine ( fractalType ) vec3 mandelbrot( fracPos )
{

    sharedFractalFunction()

}

void main() 
{

    // Determine the fractal position from the fragment UV coordinates (these normally within [0,1] - they need to be rescaled
    // to [-0.5,0.5] for the fractal formula)

    vec2 fracPos = FragmentUV - vec2(0.5);

    float mixt  = fract(t)/3;
    vec2 center = vec2(mix(1.0, 1.31, mixt), 0.0);
    float scale = mix(0.75, 0.01, mixt);

    fracPos     = vec2(1.3333, 1.0) * fracPos * scale - center;
    
    fragColor   = vec4(mandelbrot( fracPos ), 1.0);

}