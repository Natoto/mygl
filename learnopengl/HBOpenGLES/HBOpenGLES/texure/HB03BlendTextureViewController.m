//
//  HB03BlendTextureViewController.m
//  HBOPENGLES
//
//  Created by boob on 2021/10/10.
//  Copyright © 2021 Baidu.Inc. All rights reserved.
//

#import "HB03BlendTextureViewController.h"
#import <GLKit/GLKit.h>

@interface HB03BlendTextureViewController ()<GLKViewDelegate>
{
   GLuint vertexBufferID;
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKTextureInfo * textureInfo0;
@property (nonatomic, strong) GLKTextureInfo * textureInfo1;
@property (weak, nonatomic) IBOutlet GLKView *glkview;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (weak, nonatomic) IBOutlet UILabel *lblsrcfactor;
@property (weak, nonatomic) IBOutlet UILabel *lbldstfactor;
@property (nonatomic, assign) GLenum blendSrcfactor;
@property (nonatomic, assign) GLenum blendDstfactor;
@end

@implementation HB03BlendTextureViewController
@synthesize  baseEffect;

typedef struct {
   GLKVector3  positionCoords;
   GLKVector2  textureCoords;
} SceneVertex;

static const SceneVertex vertices[] = 
{
   {{-1.0f, -0.67f, 0.0f}, {0.0f, 0.0f}},  // first triangle
   {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},
   {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
   {{ 1.0f, -0.67f, 0.0f}, {1.0f, 0.0f}},  // second triangle
   {{-1.0f,  0.67f, 0.0f}, {0.0f, 1.0f}},
   {{ 1.0f,  0.67f, 0.0f}, {1.0f, 1.0f}},
};

static const int POINTCOUNT = 6;

- (void)viewDidLoad
{
    [super viewDidLoad];
    GLKView * view = (GLKView *)self.glkview;
    view.delegate = self;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
    
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)]; 
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode]; 
    self.displayLink = displayLink; 
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0); 
    
    CGImageRef imageRef = [[UIImage imageNamed:@"leaves.gif"] CGImage];
    GLKTextureInfo * textureInfo = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.textureInfo0 = textureInfo;
    
    imageRef = [[UIImage imageNamed:@"beetle.png"] CGImage];
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    
    self.baseEffect.texture2d0.target = textureInfo.target;
    self.baseEffect.texture2d0.name = textureInfo.name;
    
    glClearColor(0.0,0.0,0.0,1.0f);
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
    
    self.blendSrcfactor = GL_SRC_ALPHA;
    self.blendDstfactor = GL_ONE_MINUS_SRC_ALPHA;
}


- (void)handleDisplayLink:(id)sender 
{
    [self.glkview display];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{     
    glClear(GL_COLOR_BUFFER_BIT);    
    glBlendFunc(self.blendSrcfactor, self.blendDstfactor); 
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //设置索引值为index的顶点属性数组的位置，步长，指针，格式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid *)offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); 
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid * )offsetof(SceneVertex, textureCoords));
    
    //绘制叶子🍃
    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    self.baseEffect.texture2d0.name =  self.textureInfo0.name;
    [self.baseEffect prepareToDraw]; 
    glDrawArrays(GL_TRIANGLES, 0, POINTCOUNT); 
         
    //绘制昆虫
    self.baseEffect.texture2d0.target = self.textureInfo1.target;
    self.baseEffect.texture2d0.name =  self.textureInfo1.name;
    [self.baseEffect prepareToDraw];  
    glDrawArrays(GL_TRIANGLES, 0, POINTCOUNT); 
    

}
- (IBAction)btnfactorTap:(UIButton *)sender {
    
    if (sender.superview.tag == 100) { //src
        self.blendSrcfactor = (GLenum)sender.tag;
        self.lblsrcfactor.text = sender.currentTitle;
    }
    else {
        self.blendDstfactor =  (GLenum)sender.tag;
        self.lbldstfactor.text = sender.currentTitle;
    }    
    NSLog(@"blendSrcfactor:%@(%d)  blendDstfactor:%@(%d)",self.lblsrcfactor.text,self.blendSrcfactor,self.lbldstfactor.text, self.blendDstfactor);
}

- (void)dealloc
{
    GLKView * view = (GLKView *)self.glkview;
    [EAGLContext setCurrentContext:view.context];
    if (0 != vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    ((GLKView *)self.glkview).context = nil;
    [EAGLContext setCurrentContext:nil];
}
@end
