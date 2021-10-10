//
//  HBGLKTextureLoader.h
//  HBOPENGLES
//
//  Created by boob on 2021/10/10.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AGLKTextureInfo : NSObject
{
@private
   GLuint name;
   GLenum target;
   GLuint width;
   GLuint height;
}

@property (readonly) GLuint name;
@property (readonly) GLenum target;
@property (readonly) GLuint width;
@property (readonly) GLuint height;

- (void)setParameter:(GLenum)parameterID value:(GLint)value;

@end


@interface HBGLKTextureLoader : NSObject

+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError **)outError; 

@end

NS_ASSUME_NONNULL_END
