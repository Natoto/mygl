//
//  TrangleViewController.m
//  OpenGLES_Ch2_2
//
//  Created by boob on 2021/5/30.
//

#import "TrangleSimpleViewController.h"
#import <GLKit/GLKit.h> 
#import <OpenGLES/ES3/glext.h>
#import "Shader.h"

#define STRINGIZE(x) @#x
#define SHADER_STRING(text) STRINGIZE(text)

#define MYSHADER(STR) @#STR ;

static NSString * shader_vstr = MYSHADER
(
    attribute vec3 position;   //入参，主程序会将数值传入
    void main()
    {
        gl_Position = vec4(position,1);  //顶点经过投影变换变换后的位置
    }
);

static NSString * shader_fstr = MYSHADER
(
    void main()
    {
        gl_FragColor = vec4(0.5,0.5,0.5,1);   //顶点的颜色
    }
);

#pragma mark - shader 2

static NSString * shader_vstr2 = MYSHADER
(   //layout (location = 0)  
    attribute vec3 position;//指定变量属性位置为0
    varying vec4 vectexColor;// 为片段着色器指定一个颜色
    void main()
    {
        gl_Position = vec4(position,1.0);  //顶点经过投影变换变换后的位置
        vectexColor = vec4(0.3, 0.0, 0.0, 1.0); //把输出变量设置为暗红色
    }
);

static NSString * shader_fstr2 = MYSHADER( 
    precision highp float;
    varying vec4 vectexColor; //接受来自顶点着色器传参
    void main()
    {
       gl_FragColor = vectexColor;    
    }
);  

#pragma mark - shader 3

static NSString * shader_vstr3 = MYSHADER
(   //layout (location = 0)  
    attribute vec3 position;//指定变量属性位置为0
    varying vec4 vectexColor;// 为片段着色器指定一个颜色
    void main()
    {
        gl_Position = vec4(position,1.0);  //顶点经过投影变换变换后的位置
        vectexColor = vec4(0.3, 0.0, 0.0, 1.0); //把输出变量设置为暗红色
    }
);


static NSString * shader_fstr3 = MYSHADER( 
    precision highp float;
    uniform vec4 ourColor; //接受来自顶点着色器传参
    void main()
    {
       gl_FragColor = ourColor;    
    }
);  

#pragma mark - shader 4 

static NSString * shader_vstr4 = MYSHADER(
    attribute vec3 position; 
    attribute vec3 aColor;
    varying vec3 ourColor;
    void main()
    {
       gl_Position = vec4(position, 1.0);
       ourColor = aColor;       
//       ourColor = vec3(0.1,0.2,0.3); //aColor;    
    }
);

static NSString * shader_fstr4 = MYSHADER( 
    precision highp float;
    varying vec3 ourColor;
    void main() 
    {
        gl_FragColor = vec4(ourColor, 1.0);   
//        gl_FragColor = vec4(0.1,0.2,0.5, 1.0);    
    }
);

#pragma mark - ctr

static GLKVector3 vec[3]={
    {0.5,-0.5,0.5},
    {-0.5,-0.5,0.5},
    {0,0.5,-0.5}
};
static float vertices_for_shader4[] = {
    // 位置              // 颜色
     0.5f, -0.5f, 0.5f,  1.0f, 0.0f, 0.0f,   // 右下
    -0.5f, -0.5f, 0.5f,  0.0f, 1.0f, 0.0f,   // 左下
     0.0f,  0.5f, 0.5f,  0.0f, 0.0f, 1.0f    // 顶部
};

@interface TrangleSimpleViewController ()
{
    EAGLContext * context;
//    GLuint program;
    GLuint VAO;
}
@property (nonatomic, strong) Shader * shader;
@end

#define USER_SHADER_IDX 4

@implementation TrangleSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [EAGLContext setCurrentContext:context];
    GLKView * view = (GLKView *)self.view;
    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    self.shader = [[Shader alloc] init];
    
//    glEnable(GL_DEPTH_TEST);
//    glClearColor(0.1, 0.2, 0.3, 1);


#if USER_SHADER_IDX == 1
    [self.shader loadShaders:shader_vstr1 shaderfshstr:shader_fstr1];
#endif

#if USER_SHADER_IDX == 2
    [self.shader loadShaders:shader_vstr2 shaderfshstr:shader_fstr2];
#endif

#if USER_SHADER_IDX == 3
    [self.shader loadShaders:shader_vstr3 shaderfshstr:shader_fstr3];
#endif 


#if USER_SHADER_IDX == 4
    [self.shader loadShaders:shader_vstr4 shaderfshstr:shader_fstr4];
#endif 


    glEnable(GL_DEPTH_TEST);
//    glClearColor(0.1, 0.2, 0.3, 1); 
    glGenVertexArrays(1, &VAO);//生成一个vao对象
    glBindVertexArray(VAO); //绑定vao 
    
    GLuint VBO;
    glGenBuffers(1, &VBO);  //生成vbo 
    glBindBuffer(GL_ARRAY_BUFFER, VBO);  //绑定 
#if USER_SHADER_IDX != 4
    glBufferData(GL_ARRAY_BUFFER, sizeof(vec), vec, GL_STATIC_DRAW); //填充缓冲对象
#else 
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices_for_shader4), vertices_for_shader4, GL_STATIC_DRAW);
//glBufferData(GL_ARRAY_BUFFER, sizeof(vec), vec, GL_STATIC_DRAW); 
#endif
    
    
    GLuint loc= [self.shader getValue:@"position"];
    glEnableVertexAttribArray(loc);     //启用这个索引
     
#if USER_SHADER_IDX != 4
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3), 0);  //设置这个索引需要填充的内容
#else 
// glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3), 0); 

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
     
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void *)(6*sizeof(float)));
    glEnableVertexAttribArray(1); 
    
#endif //USER_SHADER_IDX != 4
      
    glBindVertexArray(0);   //释放vao
    glBindBuffer(GL_ARRAY_BUFFER, 0);  //释放vbo
    
}

//- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
//{
//    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
//    glClearColor(0.1, 0.2, 0.3, 1);
//}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);   //清除颜色缓冲和深度缓冲
    glBindVertexArray(VAO);    
//    glUseProgram(program);      //使用shader 
    [self.shader use];
#if USER_SHADER_IDX == 3
    NSTimeInterval timeValue = [[NSDate date] timeIntervalSince1970];
    float greenValue = sin(timeValue)/2.0f + 0.5f;
    float redValue = sin(timeValue)/2.0f + 0.5f;
    int vertextColorLocation = glGetUniformLocation(program, "ourColor");
    glUseProgram(program);
    glUniform4f(vertextColorLocation, redValue, greenValue, 0.0, 1.0f); 
#endif // #if USER_SHADER_IDX == 3
    
#if USER_SHADER_IDX == 4 
    
#endif // USER_SHADER_IDX == 4
   
    glDrawArrays(GL_TRIANGLES, 0, 3);     //绘制三角形 
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}
  
@end
