//
//  TextureViewController.m
//  OpenGLES_Ch2_2
//
//  Created by boob on 2021/5/30.
//

#import "TextureViewController.h"
#import <OpenGLES/ES3/glext.h>
#import "Shader.h"

#define STB_IMAGE_IMPLEMENTATION

float texCoords[] = {
    0.0f, 0.0f, // 左下角
    1.0f, 0.0f, // 右下角
    0.5f, 1.0f // 上中
};
typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SenceVertex;

@interface TextureViewController ()
{
    EAGLContext *context;
}
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) Shader *shader;
@property (nonatomic, assign) SenceVertex *vertices;
@property (nonatomic, weak) GLKView *glkView;
@end

@implementation TextureViewController

- (void)dealloc {
    if (_vertices) {
        free(_vertices);
        _vertices = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];

    [EAGLContext setCurrentContext:context];
    GLKView *view = (GLKView *)self.view;
    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    self.glkView = view;
    self.shader = [[Shader alloc] init];

    self.vertices = malloc(sizeof(SenceVertex) * 4);  // 4 个顶点

    self.vertices[0] = (SenceVertex) { { -1, 1, 0 }, { 0, 1 } }; // 左上角
    self.vertices[1] = (SenceVertex) { { -1, -1, 0 }, { 0, 0 } }; // 左下角
    self.vertices[2] = (SenceVertex) { { 1, 1, 0 }, { 1, 1 } }; // 右上角
    self.vertices[3] = (SenceVertex) { { 1, -1, 0 }, { 1, 0 } }; // 右下角

    [self loadtexture];
}

- (void)loadtexture
{
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"duck_sample.jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSDictionary *options = @{ GLKTextureLoaderOriginBottomLeft: @(YES) };
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.baseEffect prepareToDraw];

    // 创建顶点缓存
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);  // 步骤一：生成
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);  // 步骤二：绑定
    GLsizeiptr bufferSizeBytes = sizeof(SenceVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);  // 步骤三：缓存数据

    // 设置顶点位置
    glEnableVertexAttribArray(GLKVertexAttribPosition);  // 步骤四：启用或禁用
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, positionCoord));  // 步骤五：设置指针

    // 设置纹理坐标
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);  // 步骤四：启用或禁用
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(SenceVertex), NULL + offsetof(SenceVertex, textureCoord));  // 步骤五：设置指针

    // 开始绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);  // 步骤六：绘图

    // 删除顶点缓存
    glDeleteBuffers(1, &vertexBuffer);  // 步骤七：删除
    vertexBuffer = 0;
}

@end
