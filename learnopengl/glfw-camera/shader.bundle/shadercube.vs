#version 330 core
layout (location = 0) in vec3 position;
//layout (location = 1) in vec3 color;
layout (location = 1) in vec2 texCoord;

//out vec3 ourColor;
out vec2 TexCoord;
out vec4 outPos;

uniform float offset;
uniform mat4 transform;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    outPos = vec4(position.x + offset, position.y, position.z, 1.0);
//    gl_Position = vec4(position,1.0);
//    gl_Position = outPos;
//    gl_Position = transform * outPos;
    gl_Position = projection * view * model * outPos;
//    ourColor = color;
    TexCoord = vec2(texCoord.x, texCoord.y);
}