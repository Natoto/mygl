#version 330 core
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 color;
layout (location = 2) in vec2 texCoord;
out vec3 ourColor;
out vec2 TexCoord;
uniform float offset;
out vec4 outPos;
void main()
{
    outPos = vec4(position.x + offset, position.y, position.z, 1.0);
    gl_Position = outPos;
    ourColor = color;
    TexCoord = vec2(texCoord.x,1.0-texCoord.y);
}
