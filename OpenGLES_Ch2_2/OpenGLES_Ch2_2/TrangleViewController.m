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

NSString * shadervshstr = MYSHADER
(
    attribute vec3 position;   //入参，主程序会将数值传入
    void main()
    {
        gl_Position = vec4(position,1);  //顶点经过投影变换变换后的位置
    }
);

NSString * shaderfshstr = MYSHADER
(
    void main()
    {
        gl_FragColor = vec4(0.5,0.5,0.5,1);   //顶点的颜色
    }
);

GLKVector3 vec[3]={
    {0.5,0.5,0.5},
    {-0.5,-0.5,0.5},
    {0.5,-0.5,-0.5}
};

#pragma mark - ctr

@interface TrangleViewController ()
{
    EAGLContext * context;
    GLuint program;
    GLuint vertexID;
}
@end

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

    [self loadShaders];
    glEnable(GL_DEPTH_TEST);
    glClearColor(0.1, 0.2, 0.3, 1); 
    glGenVertexArrays(1, &vertexID);//生成一个vao对象
    glBindVertexArray(vertexID); //绑定vao 
    GLuint bufferID;
    glGenBuffers(1, &bufferID);  //生成vbo
    
    glBindBuffer(GL_ARRAY_BUFFER, bufferID);  //绑定
    glBufferData(GL_ARRAY_BUFFER, sizeof(vec), vec, GL_STATIC_DRAW); //填充缓冲对象
    GLuint loc=glGetAttribLocation(program, "position");   //获得shader里position变量的索引
    glEnableVertexAttribArray(loc);     //启用这个索引
    glVertexAttribPointer(loc, 3, GL_FLOAT, GL_FALSE, sizeof(GLKVector3), 0);  //设置这个索引需要填充的内容
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
    glBindVertexArray(vertexID);    
    glUseProgram(program);      //使用shader
    glDrawArrays(GL_TRIANGLES, 0, 3);     //绘制三角形
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}
 
- (BOOL)loadShaders
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
