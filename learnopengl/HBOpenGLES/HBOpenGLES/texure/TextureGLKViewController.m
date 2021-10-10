//
//  HelloGLKViewController.m
//  HBOPENGLES
//
//  Created by boob on 2021/10/10.
//

#import "TextureGLKViewController.h" 
#import "HBGLKTextureLoader.h"
@interface TextureGLKViewController()
{
   GLuint vertexBufferID;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@end

@implementation TextureGLKViewController
@synthesize  baseEffect;

typedef struct {
   GLKVector3  positionCoords;
   GLKVector2  textureCoords;
} SceneVertex;

static const SceneVertex vertices[] = 
{
   {{-0.5f, -0.5f, 0.0}, {0.0f,0.0f}}, // lower left corner
   {{ 0.5f, -0.5f, 0.0}, {1.0f,0.0f}}, // lower right corner
   {{-0.5f,  0.5f, 0.0}, {0.0f,1.0f}}  // upper left corner
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    GLKView * view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0); 
    
    CGImageRef imageRef = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    AGLKTextureInfo * textureInfo = [HBGLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.baseEffect.texture2d0.target = textureInfo.target;
    self.baseEffect.texture2d0.name = textureInfo.name;
    
    glClearColor(0.0,0.0,0.0,1.0f);
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{ 
    [self.baseEffect prepareToDraw]; 
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //设置索引值为index的顶点属性数组的位置，步长，指针，格式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid *)offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    GLvoid * offset = (GLvoid * )offsetof(SceneVertex, textureCoords);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), offset);
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
