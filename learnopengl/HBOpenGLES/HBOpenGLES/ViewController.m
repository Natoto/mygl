//
//  ViewController.m
//  HBOPENGLES
//
//  Created by boob on 2021/10/10.
//

#import "ViewController.h"
#import "HelloGLKViewController.h"
#import "TextureGLKViewController.h"
#import "HBFlipTextureViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad]; 
     
}

- (IBAction)btnhello:(id)sender {
    
    HelloGLKViewController * ctr = [HelloGLKViewController new];
    [self.navigationController pushViewController:ctr animated:YES];
}
- (IBAction)btntexture:(id)sender {
 
    TextureGLKViewController * ctr = [TextureGLKViewController new];
    [self.navigationController pushViewController:ctr animated:YES];
}
- (IBAction)btn02fliptexture:(id)sender {
    HBFlipTextureViewController * ctr = [HBFlipTextureViewController new];
    [self.navigationController pushViewController:ctr animated:YES];
}



@end
