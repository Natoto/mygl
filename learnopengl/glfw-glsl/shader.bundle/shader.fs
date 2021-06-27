#version 330 core
in vec3 vertexColor;
in vec4 outPos;
out vec4 color;
void main(){
//   color = vec4(vertexColor,1.0f);
    color = outPos;
}
