//
//  TrangleViewController.m
//  OpenGLES_Ch2_2
//
//  Created by boob on 2021/5/30.
//

#import "HelloWorldViewController.h"

@interface HelloWorldViewController ()
{
    EAGLContext *context; //EAGLContent是苹果在ios平台下实现的opengles渲染层，用于渲染结果在目标surface上的更新。
}
@end

@implementation HelloWorldViewController

- (void)viewDidLoad {
    [super viewDidLoad]; 
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"fail to create eagl context!!"); 
    }
    GLKView * view = (GLKView *)self.view;
    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    [EAGLContext setCurrentContext:context];
    
    glEnable(GL_DEPTH_TEST);//开启深度测试，就是让离你近的物体可以遮挡离你远的物体。
    glClearColor(0.1, 0.2, 0.3, 1);
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
}


 
@end
