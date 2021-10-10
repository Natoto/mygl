//
//  HBFlipTextureViewController.m
//  HBOPENGLES
//
//  Created by boob on 2021/10/10.
//  Copyright © 2021 Baidu.Inc. All rights reserved.
//

#import "HBFlipTextureViewController.h"
#import "HBGLKTextureLoader.h"

@interface HBFlipTextureViewController ()<GLKViewDelegate>
{
   GLuint vertexBufferID;
}
@property (strong, nonatomic) GLKBaseEffect *baseEffect;

@property (weak, nonatomic) IBOutlet GLKView *glkView;
@property (weak, nonatomic) IBOutlet UIStackView *toolsview;
@property (nonatomic) BOOL    shouldUseLinearFilter;
@property (nonatomic) BOOL    shouldAnimate;
@property (nonatomic) BOOL    shouldRepeatTexture;
@property (nonatomic) GLfloat sCoordinateOffset;
@property (nonatomic, strong)  AGLKTextureInfo * textureInfo;
@property (nonatomic, strong)  CADisplayLink *displayLink;
@end

@implementation HBFlipTextureViewController
@synthesize  baseEffect;

typedef struct {
   GLKVector3  positionCoords;
   GLKVector2  textureCoords;
} SceneVertex;

static SceneVertex vertices[] = 
{
   {{-0.5f, -0.5f, 0.0}, {0.0f,0.0f}}, // lower left corner
   {{ 0.5f, -0.5f, 0.0}, {1.0f,0.0f}}, // lower right corner
   {{-0.5f,  0.5f, 0.0}, {0.0f,1.0f}}  // upper left corner
};


static const SceneVertex defaultVertices[] = 
{
   {{-0.5f, -0.5f, 0.0f}, {0.0f, 0.0f}},
   {{ 0.5f, -0.5f, 0.0f}, {1.0f, 0.0f}},
   {{-0.5f,  0.5f, 0.0f}, {0.0f, 1.0f}},
};

static GLKVector3 movementVectors[3] = {
   {-0.02f,  -0.01f, 0.0f},
   {0.01f,  -0.005f, 0.0f},
   {-0.01f,   0.01f, 0.0f},
};


- (void)viewDidLoad
{
    [super viewDidLoad];
    GLKView * view = (GLKView *)self.glkView;
    view.delegate = self;
    view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:view.context];
      
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)]; 
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode]; 
    self.displayLink = displayLink; 
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0); 
    
    CGImageRef imageRef = [[UIImage imageNamed:@"grid.png"] CGImage];
    AGLKTextureInfo * textureInfo = [HBGLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];
    self.baseEffect.texture2d0.target = textureInfo.target;
    self.baseEffect.texture2d0.name = textureInfo.name;
    
    glClearColor(0.0,0.0,0.0,1.0f);
    glGenBuffers(1, &vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
    self.textureInfo = textureInfo;
    [textureInfo setParameter:GL_TEXTURE_MAG_FILTER value:GL_NEAREST];
}

- (void)handleDisplayLink:(id)sender 
{
    [self.glkView display];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.view bringSubviewToFront:self.toolsview];
}
- (void)update
{
   [self updateAnimatedVertexPositions];
   [self updateTextureParameters];
   
   glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
   glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_DYNAMIC_DRAW);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{ 
    [self.baseEffect prepareToDraw];
    [self update]; 
    glClear(GL_COLOR_BUFFER_BIT);
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    //设置索引值为index的顶点属性数组的位置，步长，指针，格式
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), (GLvoid *)offsetof(SceneVertex, positionCoords));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    GLvoid * offset = (GLvoid * )offsetof(SceneVertex, textureCoords);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_TRUE, sizeof(SceneVertex), offset);
    glDrawArrays(GL_TRIANGLES, 0, 3); 
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.displayLink invalidate];
}
- (void)dealloc
{
    NSLog(@"%s",__func__);
    GLKView * view = (GLKView *)self.glkView;
    [EAGLContext setCurrentContext:view.context];
    if (0 != vertexBufferID) {
        glDeleteBuffers(1, &vertexBufferID);
        vertexBufferID = 0;
    }
    ((GLKView *)self.glkView).context = nil;
    [EAGLContext setCurrentContext:nil];
}
 
 
#pragma mark - animations 


- (void)updateTextureParameters
{
    [self.textureInfo setParameter:GL_TEXTURE_WRAP_S value:(self.shouldRepeatTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE)];
    [self.textureInfo setParameter:GL_TEXTURE_WRAP_T value:(self.shouldRepeatTexture ? GL_REPEAT : GL_CLAMP_TO_EDGE)];
   
    [self.textureInfo setParameter:GL_TEXTURE_MAG_FILTER value:(self.shouldUseLinearFilter ? GL_LINEAR : GL_NEAREST)];
}

- (void)updateAnimatedVertexPositions
{
   if(self.shouldAnimate) 
   {  // Animate the triangles vertex positions
      int    i;  // by convention, 'i' is current vertex index
      
      for(i = 0; i < 3; i++)
      {
         vertices[i].positionCoords.x += movementVectors[i].x;
         if(vertices[i].positionCoords.x >= 1.0f || 
            vertices[i].positionCoords.x <= -1.0f)
         {
            movementVectors[i].x = -movementVectors[i].x;
         }
         vertices[i].positionCoords.y += movementVectors[i].y;
         if(vertices[i].positionCoords.y >= 1.0f || 
            vertices[i].positionCoords.y <= -1.0f)
         {
            movementVectors[i].y = -movementVectors[i].y;
         }
         vertices[i].positionCoords.z += movementVectors[i].z;
         if(vertices[i].positionCoords.z >= 1.0f || 
            vertices[i].positionCoords.z <= -1.0f)
         {
            movementVectors[i].z = -movementVectors[i].z;
         }
      }
   }
   else 
   {  // Restore the triangle vertex positions to defaults
      int    i;  // by convention, 'i' is current vertex index
      
      for(i = 0; i < 3; i++)
      {
         vertices[i].positionCoords.x =  defaultVertices[i].positionCoords.x;
         vertices[i].positionCoords.y =  defaultVertices[i].positionCoords.y;
         vertices[i].positionCoords.z =  defaultVertices[i].positionCoords.z;
      }
   }
   
   
   {  // Adjust the S texture coordinates to slide texture and
      // reveal effect of texture repeat vs. clamp behavior
      int    i;  // 'i' is current vertex index 
      for(i = 0; i < 3; i++)
      {
         vertices[i].textureCoords.s = (defaultVertices[i].textureCoords.s +  self.sCoordinateOffset);
      }
   }
}
 
 
 
#pragma mark - ibactions 

- (IBAction)takeSCoordinateOffsetFrom:(UISlider *)sender
{
   self.sCoordinateOffset = [sender value];
}
 
- (IBAction)takeShouldRepeatTextureFrom:(UISwitch *)sender
{
   self.shouldRepeatTexture = [sender isOn];
}
 
- (IBAction)takeShouldAnimateFrom:(UISwitch *)sender
{
   self.shouldAnimate = [sender isOn];
}
 
- (IBAction)takeShouldUseLinearFilterFrom:(UISwitch *)sender
{
   self.shouldUseLinearFilter = [sender isOn];
}
@end
