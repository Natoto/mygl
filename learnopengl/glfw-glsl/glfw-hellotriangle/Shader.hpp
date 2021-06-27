//
//  Shader.hpp
//  glfw-glsl
//
//  Created by boob on 2021/6/27.
//

#ifndef Shader_hpp
#define Shader_hpp
#ifndef SHADER_H
#define SHADER_H

#include <string>
#include <fstream>
#include <sstream>
#include <iostream>

#include "glad.h"
//#include "glew.h"; // 包含glew来获取所有的必须OpenGL头文件

#include <stdio.h>


class Shader
{
public:
    // 程序ID
    GLuint Program;
    // 构造器读取并构建着色器
    Shader(const GLchar* vertexPath, const GLchar* fragmentPath);
    // 使用程序
    void Use();

private:
    Shader();
    ~Shader();
};

#endif

#endif /* Shader_hpp */
