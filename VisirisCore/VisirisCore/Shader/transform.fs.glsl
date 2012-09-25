//Basic Fragment Shader - It doesn't alter the color, just shows it.

#version 120

uniform sampler2D texture;
uniform float alpha;

varying vec2 texcoord;

void main()
{    
    vec4 color = texture2D(texture, texcoord);
    
    color.a *= alpha;
   // color.b += 1.0-color.a;
    gl_FragColor = color;
}
