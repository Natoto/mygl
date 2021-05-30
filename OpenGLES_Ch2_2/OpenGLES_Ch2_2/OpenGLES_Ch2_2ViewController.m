//
//  OpenGLES_Ch2_2ViewController.m
//

#import "OpenGLES_Ch2_2ViewController.h"

@implementation OpenGLES_Ch2_2ViewController

@synthesize baseEffect;

///////////////////////////////////////////////////////////////
typedef struct {
   GLKVector3  positionCoords;
}
SceneVertex;

///////////////////////////////////////////////////////////////
static const SceneVertex vertices[] = 
{
   {{-0.5f, -0.5f, 0.0}},
   {{ 0.5f, -0.5f, 0.0}},
   {{-0.5f,  0.5f, 0.0}}
};


///////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
   [super viewDidLoad];
   GLKView *view = (GLKView *)self.view;
   NSAssert([view isKindOfClass:[GLKView class]],
      @"View controller's view is not a AGLKView");
    
   view.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
   [EAGLContext setCurrentContext:view.context];
   self.baseEffect = [[GLKBaseEffect alloc] init];
   self.baseEffect.useConstantColor = GL_TRUE;
   self.baseEffect.constantColor = GLKVector4Make(
      1.0f,
      1.0f,
      1.0f,
      1.0f);
   glClearColor(0.5f, 0.0f, 0.0f, 1.0f);
   glGenBuffers(1,  &vertexBufferID);
   glBindBuffer(GL_ARRAY_BUFFER,  vertexBufferID); 
   glBufferData( GL_ARRAY_BUFFER,  sizeof(vertices),  vertices,  GL_STATIC_DRAW);
}


///////////////////////////////////////////////////////////////
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
   [self.baseEffect prepareToDraw];
   glClear(GL_COLOR_BUFFER_BIT);
   glEnableVertexAttribArray(
      GLKVertexAttribPosition);
      
   glVertexAttribPointer(
      GLKVertexAttribPosition,
      3,
      GL_FLOAT,
      GL_FALSE,
      sizeof(SceneVertex),
      NULL);
   glDrawArrays(GL_TRIANGLES,
      0,
      3);
}


///////////////////////////////////////////////////////////////
// Perform clean-up that is possible when you know the view
- (void)viewDidUnload
{
   [super viewDidUnload];
   if (0 != vertexBufferID)
   {
      glDeleteBuffers (1,
                       &vertexBufferID);  
      vertexBufferID = 0;
   }
   
   // Stop using the context created in -viewDidLoad
   ((GLKView *)self.view).context = nil;
   [EAGLContext setCurrentContext:nil];
}

@end
