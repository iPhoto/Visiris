#version 120

uniform sampler2D texture;

varying vec2 texcoord;

#define BlendNormal(base, blend)        (blend + base*(1.0 - blend.a))

void main()
{
    vec4 blend = texture2D(texture, texcoord);
    blend *= vec4(blend.a);
    
    
    vec4 base = vec4(0.0f,0.0f,0.0f,1.0f);
    gl_FragColor = BlendNormal(base,blend);
    gl_FragColor = blend;
    
}
