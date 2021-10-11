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
@property (weak, nonatomic) IBOutlet UIStackView *scrstack;
@property (weak, nonatomic) IBOutlet UIStackView *dststack;
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


#define BLENDMODE_COORD1 1
#define BLENDMODE_COORD2 2
#define BLENDMODE BLENDMODE_COORD2
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
    
    CGImageRef imageRef1 = [[UIImage imageNamed:@"beetle.png"] CGImage];
    self.textureInfo1 = [GLKTextureLoader textureWithCGImage:imageRef1 options:nil error:NULL];
    self.baseEffect.texture2d0.target = self.textureInfo0.target;
    self.baseEffect.texture2d0.name = self.textureInfo0.name;
    #if BLENDMODE == BLENDMODE_COORD2
        self.baseEffect.texture2d1.target = self.textureInfo1.target;
        self.baseEffect.texture2d1.name = self.textureInfo1.name;
        self.baseEffect.texture2d1.envMode = GLKTextureEnvModeDecal;
    #endif
    
    glClearColor(0.0,0.0,0.0,1.0f);
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    self.scrstack.hidden = !(BLENDMODE == BLENDMODE_COORD1);
    self.dststack.hidden = !(BLENDMODE == BLENDMODE_COORD1);   
     
    #if BLENDMODE == BLENDMODE_COORD1     
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
    #endif
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
    
    #if BLENDMODE == BLENDMODE_COORD1
    glBlendFunc(self.blendSrcfactor, self.blendDstfactor); 
    #endif
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //设置索引值为index的顶点属性数组的位置，步长，指针，格式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid *)offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0); 
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid * )offsetof(SceneVertex, textureCoords));
    
    #if BLENDMODE == BLENDMODE_COORD2
    glEnableVertexAttribArray(GLKVertexAttribTexCoord1); 
    glVertexAttribPointer(GLKVertexAttribTexCoord1, 2, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid * )offsetof(SceneVertex, textureCoords));
    
    [self.baseEffect prepareToDraw]; 
    glDrawArrays(GL_TRIANGLES, 0, POINTCOUNT); 
    #endif
    
    #if BLENDMODE == BLENDMODE_COORD1
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
    #endif
    

}
//https://blog.51cto.com/zgame/1259518 
//假设源颜色的四个分量（指红色，绿色，蓝色，alpha值）是(Rs, Gs, Bs, As)，目标颜色的四个分量是(Rd, Gd, Bd, Ad)，又设源因子为(Sr, Sg, Sb, Sa)，目标因子为(Dr, Dg, Db, Da)。
//则混合产生的新颜色可以表示为： (Rs*Sr+Rd*Dr, Gs*Sg+Gd*Dg, Bs*Sb+Bd*Db, As*Sa+Ad*Da) 
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
