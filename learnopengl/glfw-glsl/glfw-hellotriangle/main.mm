// System Headers
#include "glad.h"
#include "glfw3.h"

// Standard Headers
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include "Shader.hpp"

void framebuffer_size_callback(GLFWwindow* window, int width, int height);//回调函数原型声明
void processInput(GLFWwindow *window);
void hbdraw();
// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

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
   -0.5f  , -0.5f , 0.0f,
    0.5f  , -0.5f , 0.0f,
    0.0f  ,  0.5f , 0.0f
};

GLfloat vertices3[] = {
   -0.5f  , -0.5f , 0.0f, 0.0f, 1.0f, 0.0f, //左下
    0.5f  , -0.5f , 0.0f, 1.0f, 0.0f, 0.0f, //右下
    0.0f  ,  0.5f , 0.0f, 0.0f, 0.0f, 1.0f, //顶部
};

GLfloat vertices1[] = {
    0.5f  ,  0.5f , 0.0f, //第一个三角形
    -0.5f  , 0.5f , 0.0f,
    -0.5f , -0.5f , 0.0f,
    
    0.5  ,  0.5f , 0.0f,
    -0.5f , -0.5f , 0.0f,  //第二个三角形
     0.5f , -0.5f , 0.0f,
};

GLfloat vertices2[] = {
    0.6f, 0.5f, 0.0f,   // 右上角
    0.5f, -0.5f, 0.0f,  // 右下角
    -0.5f, -0.5f, 0.0f, // 左下角
    -0.5f, 0.5f, 0.0f   // 左上角
};
  
GLuint indices[] = {
    0,1,3, //第一个三角形
    1,2,3  //第二个三角形
};

#define HBSHADER(STR) #STR

// 顶点片段着色器
GLuint createVerTextShader()
{
    const char * vs=
      "#version 330 core \
        layout (location = 0) in vec3 position;\
        layout (location = 1) in vec3 color; \
        out vec3 vertexColor;\
        void main()\
        {\
            gl_Position = vec4(position.x, position.y, position.z, 1.0);\
            vertexColor = color;  \
        }";
     
    GLuint vertextShader;
    vertextShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertextShader,1,&vs, NULL);
    glCompileShader(vertextShader);
    
    GLint success;
    GLchar infoLog[512];
    glGetShaderiv(vertextShader,GL_COMPILE_STATUS,&success);
    if(!success) {
        glGetShaderInfoLog(vertextShader,512,NULL,infoLog);
        std::cout << "error: shader::vertext::compilation_failed\n" << infoLog << std::endl;
    }
    return vertextShader;
}
// 创建片段着色器
GLuint createFragmentShader()
{
    const GLchar *fs=
        "#version 330 core \
        in vec4 vertexColor; \
        out vec4 color;\
        void main(){\
           color = vertexColor; \
        }";
    
    const GLchar *fs2=
        "#version 330 core \
        uniform vec4 ourColor; \
        out vec4 color;\
        void main(){\
           color = ourColor; \
        }";
    
    
    const GLchar *fs3=
        "#version 330 core \
        in vec3 vertexColor; \
        out vec4 color;\
        void main(){\
           color = vec4(vertexColor,1.0f); \
        }";
 
    
    GLuint fragmentShader;
    fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragmentShader,1,&fs3,NULL);
    glCompileShader(fragmentShader);
    
    GLint success;
    GLchar infoLog[512];
    glGetShaderiv(fragmentShader,GL_COMPILE_STATUS,&success);
    if(!success) {
        glGetShaderInfoLog(fragmentShader,512,NULL,infoLog);
        std::cout << "error: shader::fragment::compilation_failed\n" << infoLog << std::endl;
    }
    return fragmentShader;
}

GLuint createShaderProgram(GLuint vertexShader,GLuint fragmentShader)
{
    GLuint shaderPrograme;
    shaderPrograme = glCreateProgram();
    glAttachShader(shaderPrograme,vertexShader);
    glAttachShader(shaderPrograme,fragmentShader);
    glLinkProgram(shaderPrograme);
    
    GLint success;
    GLchar infoLog[512];
    glGetProgramiv(shaderPrograme,GL_LINK_STATUS,&success);
    if(!success) {
        glGetProgramInfoLog(shaderPrograme,512,NULL,infoLog);
        std::cout << "error::progreame::linkerror:\n"<< infoLog << std::endl;
    }
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    return shaderPrograme;
}

static GLuint g_shaderProgram = 0;
static GLuint g_vao;
static GLuint g_vbo;
static GLuint g_ebo;

void hbprepareDraw()
{
    if(g_shaderProgram == 0)
    {
        GLuint vertexShader = createVerTextShader();
        GLuint fragmentShader = createFragmentShader();
        g_shaderProgram = createShaderProgram(vertexShader,fragmentShader);
    }
   
}

void _useEBODraw()
{
    if (g_vao ==0) {
        glGenVertexArrays(1, &g_vao);
        glBindVertexArray(g_vao);
    }
    
    if (g_vbo == 0) {
        glGenBuffers(1,&g_vbo);
        glBindBuffer(GL_ARRAY_BUFFER,g_vbo);
        glBufferData(GL_ARRAY_BUFFER,sizeof(vertices3),vertices3,GL_STATIC_DRAW);
        
        //设置顶点属性指针
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,6*sizeof(float),(GLvoid *)0);
        //启用vao
        glEnableVertexAttribArray(0);
        
        glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,6*sizeof(float),(GLvoid *)(3*sizeof(GLfloat)));
        glEnableVertexAttribArray(1);
        
        
        glBindBuffer(GL_ARRAY_BUFFER,0);
        glBindVertexArray(0);
    }
     
//    if (g_ebo == 0) {
//        glGenBuffers(1,&g_ebo);//索引缓存对象
//        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,g_ebo);
//        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices),indices, GL_STATIC_DRAW);
//
//        glBindBuffer(GL_ARRAY_BUFFER,0);
//        glBindVertexArray(0);
//    }
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
//    glPolygonMode(GL_FRONT_AND_BACK,GL_LINES);
    glUseProgram(g_shaderProgram);
    glBindVertexArray(g_vao);
    
//    GLfloat timeValue = glfwGetTime();
//    GLfloat greenValue = (sin(timeValue)) + 0.5;
//    GLint vertexColorLocation = glGetUniformLocation(g_shaderProgram,"ourColor");
//    glUniform4f(vertexColorLocation,0.0f,greenValue,0.0,1.0f);
    
    //绘制类型，顶点个数，顶点数据类型，偏移量
//    glDrawElements(GL_TRIANGLES,6,GL_UNSIGNED_INT,0);
    glDrawArrays(GL_TRIANGLES,0,3);
    glBindVertexArray(0);
}

void someOpenGLFunctionThatDrawsOurTriangle()
{
   
}
void hbdraw()
{
    hbprepareDraw();
    _useEBODraw();
}
