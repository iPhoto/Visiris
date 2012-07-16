#version 110

uniform sampler2D textures;

varying vec2 texcoord;

void main()
{

//das ist bullshit
    gl_FragColor = mix(
        texture2D(textures, texcoord),
        texture2D(textures, texcoord),
        0.5f
    );
}
