//
//  Shader.h
//  OpenGLES_Ch2_2
//
//  Created by boob on 2021/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Shader : NSObject

- (BOOL)loadShaders:(NSString *)shadervshstr shaderfshstr:(NSString *)shaderfshstr;

- (void)use;

- (void)setBool:(NSString *)name value:(BOOL)value;

- (void)setInt:(NSString *)name value:(int)value;

- (void)setFloat:(NSString *)name value:(float)value; 

- (BOOL)getValue:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
