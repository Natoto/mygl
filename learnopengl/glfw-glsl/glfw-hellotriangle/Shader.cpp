//
//  Shader.cpp
//  glfw-glsl
//
//  Created by boob on 2021/6/27.
//

#include "Shader.hpp"

Shader::Shader()
{
    
}
Shader::~Shader()
{
    
}
Shader::Shader(const GLchar* vertexPath, const GLchar* fragmentPath)
{
    // 1. 从文件路径中获取顶点/片段着色器
    std::string vertexCode;
    std::string fragmentCode;
    std::ifstream vShaderFile;
    std::ifstream fShaderFile;
    // 保证ifstream对象可以抛出异常：
    vShaderFile.exceptions(std::ifstream::badbit);
    fShaderFile.exceptions(std::ifstream::badbit);
    try
    {
        // 打开文件
        vShaderFile.open(vertexPath);
        fShaderFile.open(fragmentPath);
        std::stringstream vShaderStream, fShaderStream;
        // 读取文件的缓冲内容到流中
        vShaderStream << vShaderFile.rdbuf();
        fShaderStream << fShaderFile.rdbuf();
        // 关闭文件
        vShaderFile.close();
        fShaderFile.close();
        // 转换流至GLchar数组
        vertexCode = vShaderStream.str();
        fragmentCode = fShaderStream.str();
    }
    catch(std::ifstream::failure e)
    {
        std::cout << "ERROR::SHADER::FILE_NOT_SUCCESFULLY_READ" << std::endl;
    }
    const GLchar* vShaderCode = vertexCode.c_str();
    const GLchar* fShaderCode = fragmentCode.c_str();
//    [...]
    
    //MARK: create shader
    
    GLuint vertextShader;
    vertextShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertextShader,1,&vShaderCode, NULL);
    glCompileShader(vertextShader);
    
    GLint success;
    GLchar infoLog[512];
    glGetShaderiv(vertextShader,GL_COMPILE_STATUS,&success);
    if(!success) {
        glGetShaderInfoLog(vertextShader,512,NULL,infoLog);
        std::cout << "error: shader::vertext::compilation_failed\n" << infoLog << std::endl;
    }
    
    GLuint fragmentShader;
   fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
   glShaderSource(fragmentShader,1,&fShaderCode,NULL);
   glCompileShader(fragmentShader);
   
//   GLint success;
//   GLchar infoLog[512];
   glGetShaderiv(fragmentShader,GL_COMPILE_STATUS,&success);
   if(!success) {
       glGetShaderInfoLog(fragmentShader,512,NULL,infoLog);
       std::cout << "error: shader::fragment::compilation_failed\n" << infoLog << std::endl;
   }
    
    //MARK: attach && link
    
    GLuint shaderPrograme;
    shaderPrograme = glCreateProgram();
    Program = shaderPrograme;
    glAttachShader(shaderPrograme,vertextShader);
    glAttachShader(shaderPrograme,fragmentShader);
    glLinkProgram(shaderPrograme);
     
    glGetProgramiv(shaderPrograme,GL_LINK_STATUS,&success);
    if(!success) {
        glGetProgramInfoLog(shaderPrograme,512,NULL,infoLog);
        std::cout << "error::progreame::linkerror:\n"<< infoLog << std::endl;
    }
    
    glDeleteShader(vertextShader);
    glDeleteShader(fragmentShader);
//    return shaderPrograme;
     
}

void Shader::Use()
{
    glUseProgram(this->Program);
}
