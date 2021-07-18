// System Headers
#include "glad.h"
#include "glfw3.h"

// Standard Headers
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include "Shader.hpp"
#include "SOIL.h"
#include "glm.hpp"
#include "glm/gtc/matrix_transform.hpp"
#include "glm/gtc/type_ptr.hpp"

void framebuffer_size_callback(GLFWwindow* window, int width, int height);//回调函数原型声明
void processInput(GLFWwindow *window);
void hbdraw();
// settings
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

static GLuint g_shaderObjectProgram = 0;
//static GLuint g_shaderLightProgram = 0;

///  画旋转立方体
#define DRAW_CUBE_3D  1

#define ROOTBUNDLE_PATH(FILE) "/Users/boob/Documents/demos/mygl/learnopengl/glfw-light/shader.bundle/"#FILE
#define GET_ROOTBUNDLE_PATH(FILE)  ROOTBUNDLE_PATH(FILE)

float PI = 3.14159265;
#define MY_GLANGLE(ANGLE)  ((ANGLE/360.0f) * PI * 2)
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
    
    // "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/shader.fs";
      
//    const char * fspath = GET_ROOTBUNDLE_PATH(shaderobject.fs);
//    const char * vspath = GET_ROOTBUNDLE_PATH(shaderobject.vs);
//    Shader ourShader(vspath , fspath);
//    g_shaderObjectProgram = ourShader.Program;
    
   const char * lightfspath = GET_ROOTBUNDLE_PATH(shaderlight.fs);
   const char * lightvspath = GET_ROOTBUNDLE_PATH(shaderlight.vs);
    
    Shader lightShader(lightvspath , lightfspath);
    g_shaderObjectProgram = lightShader.Program;
    
    
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
static GLfloat mixTextureValue = 0.2;
static GLfloat camxValue = 10.0;
static GLfloat camzValue = 10.0;

glm::vec3 cameraPos   = glm::vec3(0.0f, 0.0f,  3.0f);
glm::vec3 cameraFront = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp    = glm::vec3(0.0f, 1.0f,  0.0f);
  
bool keys[1024];
#define IS_PRESSKEY(PRESSKEY) (glfwGetKey(window, PRESSKEY) == GLFW_PRESS)
#define IS_RLEASEKEY(PRESSKEY) (glfwGetKey(window, PRESSKEY) == GLFW_RELEASE)
//输入控制，检查用户是否按下了返回键(Esc)
void processInput(GLFWwindow *window)
{
    if(glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS || glfwGetKey(window, GLFW_KEY_ENTER) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);
    
   /* if(glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS ) {
        if (mixTextureValue<=0) {
            mixTextureValue = 1.0;
        }
        mixTextureValue -=0.1;
    }
    if(glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS) {
        if (mixTextureValue>=1) {
            mixTextureValue = 0;
        }
        mixTextureValue +=0.1;
    }*/
    
//    
//     if(glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS) { 
//        camzValue +=1.0;
//        printf("camzValue:%f\n",camzValue);
//    }
//     if(glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS) { 
//        camzValue -=1.0;
//        printf("camzValue:%f\n",camzValue);
//    } 
//    if(glfwGetKey(window, GLFW_KEY_LEFT) == GLFW_PRESS) { 
//        camxValue +=1.0;
//        printf("camxValue:%f\n",camxValue);
//    }
//    if(glfwGetKey(window, GLFW_KEY_RIGHT) == GLFW_PRESS) { 
//        camxValue -=1.0;
//        printf("camxValue:%f\n",camxValue);
//    }
    
    GLfloat cameraSpeed = 0.05f;
    //调前后
    if(IS_PRESSKEY(GLFW_KEY_W)) 
        keys[GLFW_KEY_W] = true;
    else if (IS_RLEASEKEY(GLFW_KEY_W)) 
        keys[GLFW_KEY_W] = false;
        
    if(IS_PRESSKEY(GLFW_KEY_S)) 
        keys[GLFW_KEY_S] = true;
    else if (IS_RLEASEKEY(GLFW_KEY_S)) 
        keys[GLFW_KEY_S] = false;
    
    if(IS_PRESSKEY(GLFW_KEY_A) || IS_PRESSKEY(GLFW_KEY_LEFT)) 
        keys[GLFW_KEY_A] = true;
    else if (IS_RLEASEKEY(GLFW_KEY_A) || IS_RLEASEKEY(GLFW_KEY_LEFT)) 
        keys[GLFW_KEY_A] = false;
        
    if(IS_PRESSKEY(GLFW_KEY_D) || IS_PRESSKEY(GLFW_KEY_RIGHT)) 
        keys[GLFW_KEY_D] = true;
    else if (IS_RLEASEKEY(GLFW_KEY_D) || IS_RLEASEKEY(GLFW_KEY_RIGHT)) 
        keys[GLFW_KEY_D] = false;    
     
    if(keys[GLFW_KEY_W])
        cameraPos += cameraSpeed * cameraFront;
    if(keys[GLFW_KEY_S])
        cameraPos -= cameraSpeed * cameraFront;
    
    //调左右,根据左右向量的叉乘得到的左右向量 
    //或者使用左右键调整摄像头左右位置
    if(keys[GLFW_KEY_A])
        cameraPos += glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed;
    if(keys[GLFW_KEY_D])
        cameraPos -= glm::normalize(glm::cross(cameraFront, cameraUp)) * cameraSpeed; 
     
        
    //调上下
    if (glfwGetKey(window, GLFW_KEY_UP) == GLFW_PRESS) {
         cameraPos += cameraSpeed * cameraUp;
    }
    if (glfwGetKey(window, GLFW_KEY_DOWN) == GLFW_PRESS) {
        cameraPos -= cameraSpeed * cameraUp;
    }
    
    printf("cameraPos:x:%f y:%f z:%f\n",cameraPos.x,cameraPos.y,cameraPos.z);
}

// 当用户改变窗口的大小的时候，视口也应该被调整
void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
    // 注意：对于视网膜(Retina)显示屏，width和height都会明显比原输入值更高一点。
    glViewport(0, 0, width, height);
}

#pragma mark - 绘制程序开始
const float texMaxCoor = 1.0f;

#if !DRAW_CUBE_3D
GLfloat vertices[] = {
//     ---- 位置 ----       ---- 颜色 ----     - 纹理坐标 -
     0.5f,  0.5f, 0.0f,   1.0f, 0.0f, 0.0f,   texMaxCoor, texMaxCoor,   // 右上
     0.5f, -0.5f, 0.0f,   0.0f, 1.0f, 0.0f,   texMaxCoor, 0.0f,         // 右下
    -0.5f, -0.5f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f,               // 左下
    -0.5f,  0.5f, 0.0f,   1.0f, 1.0f, 0.0f,   0.0f, texMaxCoor          // 左上
};
#else 
float vertices[] = {
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
     0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
     0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
     0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
     0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
    -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
    -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
};

glm::vec3 cubePositions[] = {
    glm::vec3( 0.0f,  0.0f,  0.0f),
    glm::vec3( 2.0f,  5.0f, -15.0f),
    glm::vec3(-1.5f, -2.2f, -2.5f),
    glm::vec3(-3.8f, -2.0f, -12.3f),
    glm::vec3( 2.4f, -0.4f, -3.5f),
    glm::vec3(-1.7f,  3.0f, -7.5f),
    glm::vec3( 1.3f, -2.0f, -2.5f),
    glm::vec3( 1.5f,  2.0f, -2.5f),
    glm::vec3( 1.5f,  0.2f, -1.5f),
    glm::vec3(-1.3f,  1.0f, -1.5f)
};
#endif 

//
//GLuint indices0[] = {
//  0,1,3, //第一个三角形
//  1,2,3  //第二个三角形
//};

//6个面 x 每个面2个 = 12 三角形
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
static GLuint g_lightVAO;


void hbdraw()
{
    //只要绑定vbo不用再次设置vbo数据，因为容器的vbo数据以及包含正确的立方体顶点数据
    
    if (!g_vao) {
        glGenVertexArrays(1,&g_vao);
        glBindVertexArray(g_vao);
    }
    
//    if (!g_lightVAO) {
//        glGenBuffers(1, &g_lightVAO);
//        glBindVertexArray(g_lightVAO);
//    }
    
    if (!g_vbo) {
        glGenBuffers(1, &g_vbo);
        glBindBuffer(GL_ARRAY_BUFFER,g_vbo);
        glBufferData(GL_ARRAY_BUFFER,sizeof(vertices),vertices,GL_STATIC_DRAW);
        
        int rowsize = 5; //8;
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE, rowsize * sizeof(float), (GLvoid *)0);
        glEnableVertexAttribArray(0);
        
        glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,rowsize * sizeof(float),(GLvoid *)(3*sizeof(GLfloat)));
        glEnableVertexAttribArray(1);
         
    }
     
    
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(g_shaderObjectProgram);
    
    GLint objectColorLoc = glGetUniformLocation(g_shaderObjectProgram, "objectColor");
    GLint lightColorLoC = glGetUniformLocation(g_shaderObjectProgram,"lightColor");
    glUniform3f(objectColorLoc,1.0f,0.5f,0.31f);//珊瑚红
    glUniform3f(lightColorLoC,1.0f,1.0f,1.0f);//把光源设为白色
    
//    glm::vec3 lightPos(1.2f,1.0f,2.0f);
//    glm::mat4 model = glm::mat4(1.0);
//    model = glm::translate(model,lightPos);
//    model = glm::scale(model, glm::vec3(0.2f));
    
    glm::mat4 view(1.0f);
//    //R右向量， U上向量 D方向向量 P摄像机位置向量 -
//    view = glm::lookAt(glm::vec3(1.0f,0.0f,2.0f), glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
    view = glm::lookAt(cameraPos,cameraPos+cameraFront,cameraUp);
    GLint viewLoc = glGetUniformLocation(g_shaderObjectProgram,"view");
    glUniformMatrix4fv(viewLoc,1,GL_FALSE,glm::value_ptr(view));
    
    glm::mat4 projection(1.0f);
    float rate = (float)(SCR_WIDTH / SCR_HEIGHT );
    float angle2 = MY_GLANGLE(45.0f);
    //视野大小  宽高比  近平面 原屏幕
    projection = glm::perspective(angle2, rate, 0.1f, 100.0f);
    GLint projectionLoc = glGetUniformLocation(g_shaderObjectProgram,"projection");
    glUniformMatrix4fv(projectionLoc,1,GL_FALSE,glm::value_ptr(projection));
    
    glm::mat4 model(1.0f);
    GLfloat angle = MY_GLANGLE(20.0f);
//    model = glm::translate(model, 0);
    model  = glm::rotate(model, angle , glm::vec3(1.0f,0.3f,0.5f));
    GLint modelLoc = glGetUniformLocation(g_shaderObjectProgram,"model");
    glUniformMatrix4fv(modelLoc,1,GL_FALSE,glm::value_ptr(model));
    
    glBindVertexArray(g_vao);
    glDrawArrays(GL_TRIANGLES,0,36);
    
    glBindVertexArray(0);
}
