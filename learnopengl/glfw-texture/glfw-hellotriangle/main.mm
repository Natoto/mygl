// System Headers
#include "glad.h"
#include "glfw3.h"

// Standard Headers
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include "Shader.hpp"
#include "SOIL.h"
void framebuffer_size_callback(GLFWwindow* window, int width, int height);//回调函数原型声明
void processInput(GLFWwindow *window);
void hbdraw();
// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

static GLuint g_shaderProgram = 0;

int main(int argc, char * argv[]) {

    //初始化GLFW
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE); // uncomment this statement to fix compilation on OS X
#endif
    //创建一个窗口对象
    GLFWwindow* window = glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "HBGL", NULL, NULL);
    if (window == NULL)
    {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    //通知GLFW将我们窗口的上下文设置为当前线程的主上下文
    glfwMakeContextCurrent(window);
    //对窗口注册一个回调函数,每当窗口改变大小，GLFW会调用这个函数并填充相应的参数供你处理
    glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);
    //初始化GLAD用来管理OpenGL的函数指针
    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress))
    {
        std::cout << "Failed to initialize GLAD" << std::endl;
        return -1;
    }
    
    const char * fspath = "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/shader.fs";
    const char * vspath = "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/shader.vs";
    Shader ourShader(vspath , fspath);
    g_shaderProgram = ourShader.Program;
    
    //渲染循环
    while(!glfwWindowShouldClose(window))
    {
        glfwPollEvents();//检查触发事件
        // 输入
        processInput(window);

        // 渲染指令
        hbdraw();

        // 检查并调用事件，交换缓冲
        glfwSwapBuffers(window);// 交换颜色缓冲
    }

    //释放/删除之前的分配的所有资源
    glfwTerminate();
    return EXIT_SUCCESS;
}
//输入控制，检查用户是否按下了返回键(Esc)
void processInput(GLFWwindow *window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS || glfwGetKey(window, GLFW_KEY_ENTER) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
}

// 当用户改变窗口的大小的时候，视口也应该被调整
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    // 注意：对于视网膜(Retina)显示屏，width和height都会明显比原输入值更高一点。
    glViewport(0, 0, width, height);
}

#pragma mark - 绘制程序开始
GLfloat vertices[] = {
//     ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
     0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   1.0f, 1.0f,   // 右上
     0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   1.0f, 0.0f,   // 右下
    -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,   // 左下
    -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, 1.0f    // 左上
};

GLuint indices[] = {
  0,1,3, //第一个三角形
  1,2,3  //第二个三角形
};
GLuint g_vao;
GLuint g_vbo;

static GLuint g_ebo;
static unsigned char * g_image = nullptr;
static GLuint g_texture;
static GLuint g_texture1;

void createTextureIfNeed(GLuint *texture, const char * boxpath)
{
    if (*texture == 0) {
        int width,height;
//        const char * boxpath = "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/box.jpeg";
        unsigned char * image = SOIL_load_image(boxpath, &width, &height, 0, SOIL_LOAD_RGB);
//        g_image = image;
        
//        GLuint texture;
        glGenTextures(1,texture);
        glBindTexture(GL_TEXTURE_2D,*texture);
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,width,height,0,GL_RGB,GL_UNSIGNED_BYTE,image);
        glGenerateMipmap(GL_TEXTURE_2D);
//        g_texture = texture;

        //环绕模式
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
        //设置边框
        float boarderColor[] = {1.0f,1.0f,0.0f,1.0f};
        glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_BORDER_COLOR,boarderColor);
        //纹理过滤
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        //多级渐远纹理
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        
        SOIL_free_image_data(image);
        glBindTexture(GL_TEXTURE_2D,0);
    }
}
void hbdraw()
{
    if (g_vao ==0) {
        glGenVertexArrays(1, &g_vao);
        glBindVertexArray(g_vao);
    }
    
    if (g_vbo == 0) {
        glGenBuffers(1,&g_vbo);
        glBindBuffer(GL_ARRAY_BUFFER,g_vbo);
        glBufferData(GL_ARRAY_BUFFER,sizeof(vertices),vertices,GL_STATIC_DRAW);
        
        //设置顶点属性指针
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,8*sizeof(float),(GLvoid *)0);
        //启用vao
        glEnableVertexAttribArray(0);
        
        glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,8*sizeof(float),(GLvoid *)(3*sizeof(GLfloat)));
        glEnableVertexAttribArray(1);
        
        glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,8*sizeof(float),(GLvoid *)(6*sizeof(GLfloat)));
        glEnableVertexAttribArray(2);
        
    }
    
   
   
  if (g_ebo == 0) {
      glGenBuffers(1,&g_ebo);//索引缓存对象
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,g_ebo);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices),indices, GL_STATIC_DRAW);

      glBindBuffer(GL_ARRAY_BUFFER,0);
      glBindVertexArray(0);
  }
    const char * boxpath = "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/box.jpeg";
    createTextureIfNeed(&g_texture, boxpath);
    
    const char * facepath = "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/awesomeface.png";
    createTextureIfNeed(&g_texture1, facepath);
    
    /*
    offset
    GLfloat offset = glGetUniformLocation(g_shaderProgram,"offset");
    glUniform1f(offset,0.5f);
    */
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
//    glPolygonMode(GL_FRONT_AND_BACK,GL_LINES);
    glUseProgram(g_shaderProgram);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,g_texture);
    glUniform1i(glGetUniformLocation(g_shaderProgram,"ourTexture1"),0 );
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,g_texture1);
    glUniform1i(glGetUniformLocation(g_shaderProgram,"ourTexture2"),1);
     
    glBindVertexArray(g_vao);
    glDrawElements(GL_TRIANGLES,6,GL_UNSIGNED_INT,0);
     
    
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D,0);
    glBindTexture(GL_TEXTURE_2D,1);
}
  
