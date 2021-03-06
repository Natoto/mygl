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

static GLuint g_shaderProgram = 0;

///  画旋转立方体
#define DRAW_CUBE_3D  1

#define ROOTBUNDLE_PATH(FILE) "/Users/boob/Documents/demos/mygl/learnopengl/glfw-camera/shader.bundle/"#FILE
#define GET_ROOTBUNDLE_PATH(FILE)  ROOTBUNDLE_PATH(FILE)
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
     
#if  DRAW_CUBE_3D
    const char * fspath = GET_ROOTBUNDLE_PATH(shader.fs);
    const char * vspath = GET_ROOTBUNDLE_PATH(shadercube.vs);
#else  //DRAW_CUBE_3D
    const char * fspath = GET_ROOTBUNDLE_PATH(shader.fs);
    const char * vspath = GET_ROOTBUNDLE_PATH(shader.vs);
#endif  // if DRAW_CUBE_3D

    // "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/shader.vs";
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

void createTextureIfNeed(GLuint *texture, const char * boxpath)
{
    if (*texture == 0) {
        int width,height;
//        const char * boxpath = "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/box.jpeg";
        unsigned char * image = SOIL_load_image(boxpath, &width, &height, 0, SOIL_LOAD_RGB);
        glGenTextures(1,texture);
        glBindTexture(GL_TEXTURE_2D,*texture);
        glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,width,height,0,GL_RGB,GL_UNSIGNED_BYTE,image);
        glGenerateMipmap(GL_TEXTURE_2D);
//        g_texture = texture;

        //环绕模式
        if (*texture == 1) {
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);
        }else {
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_MIRRORED_REPEAT);
            glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_MIRRORED_REPEAT);
        }

        //设置边框
        float boarderColor[] = {1.0f,1.0f,0.0f,1.0f};
        glTexParameterfv(GL_TEXTURE_2D,GL_TEXTURE_BORDER_COLOR,boarderColor);
        //纹理过滤
//        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
//        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        //多级渐远纹理
//        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_LINEAR);
//        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
      
       glGenerateMipmap(GL_TEXTURE_2D);
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
         
        
#if  DRAW_CUBE_3D
        
        int rowsize = 5; //8;
     
        //设置顶点属性指针
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,rowsize*sizeof(float),(GLvoid *)0);
        //启用vao
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1,2,GL_FLOAT,GL_FALSE,rowsize*sizeof(float),(GLvoid *)(3*sizeof(GLfloat)));
        glEnableVertexAttribArray(1);
#else //DRAW_CUBE_3D
         
        int rowsize = 8; 
        //设置顶点属性指针
        glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,rowsize*sizeof(float),(GLvoid *)0);
        //启用vao
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(1,3,GL_FLOAT,GL_FALSE,rowsize*sizeof(float),(GLvoid *)(3*sizeof(GLfloat)));
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(2,2,GL_FLOAT,GL_FALSE,rowsize*sizeof(float),(GLvoid *)(6*sizeof(GLfloat)));
        glEnableVertexAttribArray(2); 
#endif //if DRAW_CUBE_3D
         
    }
    
#if !DRAW_CUBE_3D
  if (g_ebo == 0) {
      glGenBuffers(1,&g_ebo);//索引缓存对象
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,g_ebo);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices),indices, GL_STATIC_DRAW);

      glBindBuffer(GL_ARRAY_BUFFER,0);
      glBindVertexArray(0);
        
  }
#endif

  glEnable(GL_DEPTH_TEST);
  
    const char * boxpath = GET_ROOTBUNDLE_PATH(box.jpeg);
    // "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/box.jpeg";
    createTextureIfNeed(&g_texture, boxpath);
    
    const char * facepath = GET_ROOTBUNDLE_PATH(awesomeface.png);
    // "/Users/boob/Documents/demos/mygl/learnopengl/glfw-texture/shader.bundle/awesomeface.png";
    createTextureIfNeed(&g_texture1, facepath);
    
    /*
    offset
    GLfloat offset = glGetUniformLocation(g_shaderProgram,"offset");
    glUniform1f(offset,0.5f);
    */
    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glPolygonMode(GL_FRONT_AND_BACK,GL_LINES);
    glUseProgram(g_shaderProgram);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D,g_texture);
    glUniform1i(glGetUniformLocation(g_shaderProgram,"ourTexture1"),0 );
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D,g_texture1);
    glUniform1i(glGetUniformLocation(g_shaderProgram,"ourTexture2"),1);
     
    glUniform1f(glGetUniformLocation(g_shaderProgram,"mixvalue"),mixTextureValue);
    
    float PI = 3.14159265;
    glm::mat4 trans(1.0f);//`glm::mat4 trans` may outputs wrong values https://stackoverflow.com/questions/47178228/glmtranslate-outputs-a-matrix-with-incorrect-values/47178441
//    trans = glm::rotate(trans, 90.0f, glm::vec3(0.0f,0.0f,1.0f));
//    std::cout << (GLfloat)glfwGetTime()  << std::endl;
//    trans = glm::rotate(trans, (GLfloat)glfwGetTime() , glm::vec3(0.0f,0.0f,1.0f));
    /*
    float angle = (90.0/360.0) * PI * 2;
    trans = glm::rotate(trans,  angle, glm::vec3(0.0f,0.0f,1.0f));
    trans = glm::scale(trans, glm::vec3(0.5f,0.5f,0.5f));
    GLuint transformLoc = glGetUniformLocation(g_shaderProgram,"transform");
    glUniformMatrix4fv(transformLoc,1,GL_FALSE,glm::value_ptr(trans));
     */
    
    
    glm::mat4 view(1.0f);
    GLfloat radius = 10.0f;//MY_GLANGLE(10.0f);
//    GLfloat camx = sin(glfwGetTime()) * radius;
//    GLfloat camz = cos(glfwGetTime()) * radius;
    GLfloat camx = camxValue;
    GLfloat camz = camzValue;
    //R右向量， U上向量 D方向向量 P摄像机位置向量 -
//    view = glm::lookAt(glm::vec3(camx,0.0f,camz), glm::vec3(0.0f,0.0f,0.0f), glm::vec3(0.0f,1.0f,0.0f));
 
    view = glm::lookAt(cameraPos,cameraPos+cameraFront,cameraUp);
    glm::mat4 projection(1.0f);
    float rate = (float)(SCR_WIDTH / SCR_HEIGHT );
    float angle2 = MY_GLANGLE(45.0f);// (45.0f/360.0f) * PI * 2;
    //视野大小  宽高比  近平面 原屏幕
    projection = glm::perspective(angle2, rate, 0.1f, 100.0f);
    
    GLint viewLoc = glGetUniformLocation(g_shaderProgram,"view");
    glUniformMatrix4fv(viewLoc,1,GL_FALSE,glm::value_ptr(view));
    
    GLint projectionLoc = glGetUniformLocation(g_shaderProgram,"projection");
    glUniformMatrix4fv(projectionLoc,1,GL_FALSE,glm::value_ptr(projection));
    
    glBindVertexArray(g_vao);
    for(int idx=0;idx<10;idx++)
    {
        glm::mat4 model(1.0f);
    #if !DRAW_CUBE_3D
        float angle1 = i * (GLfloat)glfwGetTime() ;// (-55.0f/360.0f) * PI * 2;
        model = glm::rotate(model,  angle1, glm::vec3(1.0f, 0.0f, 0.0f));
    #else //DRAW_CUBE_3D
         GLfloat angle = idx  * MY_GLANGLE(20.0f);;//* (GLfloat)glfwGetTime();
         model = glm::translate(model, cubePositions[idx]);
         model  = glm::rotate(model, angle , glm::vec3(1.0f,0.3f,0.5f));
//         model  = glm::scale(model, glm::vec3(0.5f,0.5f,0.5f));
    #endif //DRAW_CUBE_3D
       
        GLint modelLoc = glGetUniformLocation(g_shaderProgram,"model");
        glUniformMatrix4fv(modelLoc,1,GL_FALSE,glm::value_ptr(model));
        

    #if DRAW_CUBE_3D
        glDrawArrays(GL_TRIANGLES,0,36);
    #else
        glDrawElements(GL_TRIANGLES,6,GL_UNSIGNED_INT,0);
    #endif
    }
    
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D,0);
    glBindTexture(GL_TEXTURE_2D,1);
}
  
