//
//  H264DecodeTool.h
//  FFmpegAndSDLDemo
//
//  Created by fy on 2016/10/20.
//
//

#import <Foundation/Foundation.h>

#import "DecodeH264Data_YUV.h"

@protocol updateDecodeH264FrameDelegate <NSObject>

@optional
//将YUV数据传递到Opengl(AVFrame*)pVideoFrame
//- (void)updateDecodedH264FrameData: (H264YUV_Frame*)yuvFrame;
- (void)updateDecodedH264FrameData: (H264YUV_Frame*)yuvFrame;
@end

@interface H264DecodeTool : NSObject

@property (nonatomic,assign)id<updateDecodeH264FrameDelegate> updateDelegate;
//接口
/**
 初始化
 @return <#return value description#>
 */
- (id)init;
/**
 初始化FFmpeg
 @param error 错误
 */
//- (void)initFFmpeg:(NSError**)error;
/**
 解码
 @param inputBuffer 数据
 @param aLength     长度
 @return <#return value description#>
 */
- (int)DecodeH264Frames: (unsigned char*)inputBuffer withLength:(int)aLength;

@end
