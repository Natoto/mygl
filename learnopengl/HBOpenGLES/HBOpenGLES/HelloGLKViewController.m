//
//  HelloGLKViewController.m
//  HBOPENGLES
//
//  Created by boob on 2021/10/10.
//

#import "HelloGLKViewController.h" 
@interface HelloGLKViewController()
{
   GLuint vertexBufferID;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@end

@implementation HelloGLKViewController
@synthesize  baseEffect;

typedef struct {
   GLKVector3  positionCoords;
} SceneVertex;

static const SceneVertex vertices[] = 
{
   {{-0.5f, -0.5f, 0.0}}, // lower left corner
   {{ 0.5f, -0.5f, 0.0}}, // lower right corner
   {{-0.5f,  0.5f, 0.0}}  // upper left corner
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    GLKView * view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 0.5, 1.0, 1.0);
     
    glClearColor(0.0,0.0,0.0,1.0f);
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{ 
    [self.baseEffect prepareToDraw]; 
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(0);
    //设置索引值为index的顶点属性数组的位置，步长，指针，格式
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid *)0);
    glDrawArrays(GL_TRIANGLES, 0, 3); 
}

- (void)dealloc
{
    GLKView * view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    if (0 != vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}


@end
