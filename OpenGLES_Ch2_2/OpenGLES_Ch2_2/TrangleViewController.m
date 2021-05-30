//
//  TrangleViewController.m
//  OpenGLES_Ch2_2
//
//  Created by boob on 2021/5/30.
//

#import "TrangleViewController.h"
#import <GLKit/GLKit.h> 
#import <OpenGLES/ES3/glext.h>
 
#define STRINGIZE(x) @#x
#define SHADER_STRING(text) STRINGIZE(text)

#define MYSHADER(STR) @#STR ;

NSString * shader_vstr = MYSHADER
(
    attribute vec3 position;   //入参，主程序会将数值传入
    void main()
    {
        gl_Position = vec4(position,1);  //顶点经过投影变换变换后的位置
    }
);

NSString * shader_fstr = MYSHADER
(
    void main()
    {
        gl_FragColor = vec4(0.5,0.5,0.5,1);   //顶点的颜色
    }
);

#pragma mark - shader 2

NSString * shader_vstr2 = MYSHADER
(   //layout (location = 0)  
    attribute vec3 position;//指定变量属性位置为0
    varying vec4 vectexColor;// 为片段着色器指定一个颜色
    void main()
    {
        gl_Position = vec4(position,1.0);  //顶点经过投影变换变换后的位置
        vectexColor = vec4(0.3, 0.0, 0.0, 1.0); //把输出变量设置为暗红色
    }
);

NSString * shader_fstr2 = MYSHADER( 
    precision highp float;
    varying vec4 vectexColor; //接受来自顶点着色器传参
    void main()
    {
       gl_FragColor = vectexColor;    
    }
);  

#pragma mark - shader 3

NSString * shader_vstr3 = MYSHADER
(   //layout (location = 0)  
    attribute vec3 position;//指定变量属性位置为0
    varying vec4 vectexColor;// 为片段着色器指定一个颜色
    void main()
    {
        gl_Position = vec4(position,1.0);  //顶点经过投影变换变换后的位置
        vectexColor = vec4(0.3, 0.0, 0.0, 1.0); //把输出变量设置为暗红色
    }
);


NSString * shader_fstr3 = MYSHADER( 
    precision highp float;
    uniform vec4 ourColor; //接受来自顶点着色器传参
    void main()
    {
       gl_FragColor = ourColor;    
    }
);  

#pragma mark - shader 4 

NSString * shader_vstr4 = MYSHADER(
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

NSString * shader_fstr4 = MYSHADER( 
    precision highp float;
    varying vec3 ourColor;
    void main() 
    {
        gl_FragColor = vec4(ourColor, 1.0);   
//        gl_FragColor = vec4(0.1,0.2,0.5, 1.0);    
    }
);

#pragma mark - ctr

GLKVector3 vec[3]={
    {0.5,-0.5,0.5},
    {-0.5,-0.5,0.5},
    {0,0.5,-0.5}
};
float vertices_for_shader4[] = {
    // 位置              // 颜色
     0.5f, -0.5f, 0.5f,  1.0f, 0.0f, 0.0f,   // 右下
    -0.5f, -0.5f, 0.5f,  0.0f, 1.0f, 0.0f,   // 左下
     0.0f,  0.5f, 0.5f,  0.0f, 0.0f, 1.0f    // 顶部
};

@interface TrangleViewController ()
{
    EAGLContext * context;
    GLuint program;
    GLuint VAO;
}
@end

#define USER_SHADER_IDX 4

@implementation TrangleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [EAGLContext setCurrentContext:context];
    GLKView * view = (GLKView *)self.view;
    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
//    glEnable(GL_DEPTH_TEST);
//    glClearColor(0.1, 0.2, 0.3, 1);


#if USER_SHADER_IDX == 1
    [self loadShaders:shader_vstr1 shaderfshstr:shader_fstr1];
#endif

#if USER_SHADER_IDX == 2
    [self loadShaders:shader_vstr2 shaderfshstr:shader_fstr2];
#endif

#if USER_SHADER_IDX == 3
    [self loadShaders:shader_vstr3 shaderfshstr:shader_fstr3];
#endif 


#if USER_SHADER_IDX == 4
    [self loadShaders:shader_vstr4 shaderfshstr:shader_fstr4];
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
    
    
    GLuint loc=glGetAttribLocation(program, "position");  //获得shader里position变量的索引
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
    glUseProgram(program);      //使用shader 

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
 
- (BOOL)loadShaders:(NSString *)shadervshstr shaderfshstr:(NSString *)shaderfshstr
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname shaderstr:shadervshstr]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname shaderstr:shaderfshstr]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Link program.
    if (![self linkProgram:program]) {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(program);
            program = 0;
        }
        
        return NO;
    }
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}
 
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file shaderstr:(NSString *)shaderstr
{
    GLint status;
    const GLchar *source;
    
    if (shaderstr) {
        source = [shaderstr cStringUsingEncoding:NSUTF8StringEncoding];  
    }else {
        source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];    
    }

    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}
 
- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}
 
- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}
@end
