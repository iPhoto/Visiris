//Basic Fragment Shader - It doesn't alter the color, just shows it.

#version 120

uniform sampler2D texture;

varying vec2 texcoord;

void main()
{
    gl_FragColor = texture2D(texture, texcoord);
}
