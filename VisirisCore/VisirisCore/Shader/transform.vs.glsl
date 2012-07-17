#version 110

attribute vec4 position;

uniform float scale;

varying vec2 texcoord;



mat4 view_frustum(
    float angle_of_view,
    float aspect_ratio,
    float z_near,
    float z_far
) {
    return mat4(
        vec4(1.0/tan(angle_of_view),           0.0, 0.0, 0.0),
        vec4(0.0, aspect_ratio/tan(angle_of_view),  0.0, 0.0),
        vec4(0.0, 0.0,    (z_far+z_near)/(z_far-z_near), 1.0),
        vec4(0.0, 0.0, -2.0*z_far*z_near/(z_far-z_near), 0.0)
    );
}

mat4 scale(float x, float y, float z)
{
    return mat4(
        vec4(x,   0.0, 0.0, 0.0),
        vec4(0.0, y,   0.0, 0.0),
        vec4(0.0, 0.0, z,   0.0),
        vec4(0.0, 0.0, 0.0, 1.0)
    );
}

mat4 translate(float x, float y, float z)
{
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(x,   y,   z,   1.0)
    );
}

mat4 rotate_x(float theta)
{
    return mat4(
        vec4(1.0,         0.0,         0.0, 0.0),
        vec4(0.0,  cos(theta),  sin(theta), 0.0),
        vec4(0.0, -sin(theta),  cos(theta), 0.0),
        vec4(0.0,         0.0,         0.0, 1.0)
    );
}

void main()
{

    float timer = 0.0;

    gl_Position = view_frustum(radians(45.0), 4.0/3.0, 0.1, 10.0)
        * translate(0.0, 0.0, 1.0)
        * rotate_x(timer)
        * scale(4.0/3.0, scale , 1.0)
        * position;
    
    texcoord = position.xy * vec2(0.5) + vec2(0.5);
    
   // gl_Position = projection * rotation * scale * position;
    
    
 //   texcoord = position.xy * vec2(0.5) + vec2(0.5);
  //  fade_factor = sin(timer) * 0.5 + 0.5;
    
    
  //  gl_Position = position;
  //  texcoord = position.xy * vec2(0.5) + vec2(0.5);
}


