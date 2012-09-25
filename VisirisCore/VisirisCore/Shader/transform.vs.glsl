//This Shader operates basic transformation.

#version 120

attribute vec4 position;

uniform float objectWidth;
uniform float objectHeight;
uniform float windowWidth;
uniform float windowHeight;
uniform float scaleX;
uniform float scaleY;
uniform float rotateX;
uniform float rotateY;
uniform float rotateZ;
uniform float translateX;
uniform float translateY;
uniform float translateZ;
uniform bool isQCPatch;

varying vec2 texcoord;

float pi180 = 0.0174532925;


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

//first x, then y, then z
mat4 rotate(float alpha, float beta, float gamma)
{
    return mat4(
                vec4(cos(beta)*cos(gamma),      cos(gamma)*sin(alpha)*sin(beta) - cos(alpha)*sin(gamma),    cos(alpha)*cos(gamma)*sin(beta) + sin(alpha)*sin(gamma),    0.0),
                vec4(cos(beta)*sin(gamma),      cos(alpha)*cos(gamma) + sin(alpha)*sin(beta)*sin(gamma),    -cos(gamma)*sin(alpha) + cos(alpha)*sin(beta)*sin(gamma),   0.0),
                vec4(-sin(beta),                cos(beta)*sin(alpha),                                       cos(alpha)*cos(beta),                                       0.0),
                vec4(0.0,                       0.0,                                                        0.0,                                                        1.0)
                );
}



void main()
{
    vec3 scaleFactor;
    
    if ((objectWidth/objectHeight) > (windowWidth/windowHeight)) {
        scaleFactor = vec3(1.0,(windowWidth/windowHeight) * (objectHeight/objectWidth),1.0);
    }
    else {
        scaleFactor = vec3((windowHeight/windowWidth) * (objectWidth/objectHeight),1.0,1.0);
    }
    
    scaleFactor.x *= scaleX;
    scaleFactor.y *= scaleY;
    
    
    float qcRotate = 0.0;
    
    
    //TODO create own program to delete this if or input variable from outside
    if (isQCPatch) {
        qcRotate = 180.0;
    }
    
    
    gl_Position = view_frustum(radians(45.0), 1.0, 0.1, 10.0)
    * translate(translateX, translateY, translateZ)
    * rotate((rotateX + qcRotate)*pi180,rotateY*pi180,rotateZ*pi180)
    * scale(scaleFactor.x,scaleFactor.y,1.0)
    * position;

    texcoord = position.xy * vec2(0.5) + vec2(0.5);
}


