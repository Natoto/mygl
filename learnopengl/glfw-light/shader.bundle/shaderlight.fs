#version 330 core
//in vec3 ourColor;
in vec2 TexCoord;

out vec4 color;

uniform vec3 objectColor;
uniform vec3 lightColor;

void main(){

//    color = mix(texture(ourTexture1,TexCoord), texture(ourTexture2,TexCoord),mixvalue);
    color = vec4(lightColor * objectColor, 1.0f);
}
