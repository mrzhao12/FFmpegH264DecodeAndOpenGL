//
//  H264DecodeTool.m
//  FFmpegAndSDLDemo
//
//  Created by fy on 2016/10/20.
#import "H264DecodeTool.h"
#import "avcodec.h"
#import "avformat.h"
#import "swscale.h"
@interface H264DecodeTool ()
{
    int             pictureWidth;
//    BOOL            isInit;
    AVCodec*        pCodec;
    // 上下文
    AVCodecContext* pCodecCtx;
    
    AVFrame*        pVideoFrame;
    AVPacket        pAvPackage;
    //解码状态
    int             setRecordResolveState;
}
@end
@implementation H264DecodeTool
- (id) init
{
    if(self=[super init])
    {
        pCodec      =NULL;
        pCodecCtx   =NULL;
        pVideoFrame =NULL;
        
        pictureWidth=0;
        
        setRecordResolveState=0;
        // 注册所有编码器，注册所支持的所有文件（容器）格式以及对应的codec
        av_register_all();
        avcodec_register_all();
        // 查找解码器 找到解码文件的解码器编号
        
        pCodec=avcodec_find_decoder(AV_CODEC_ID_H264);
        if(!pCodec){
            printf("------Codec not find没有找到解码器\n");
            
        }
        pCodecCtx=avcodec_alloc_context3(pCodec);
        if(!pCodecCtx){
            printf("------allocate codec context error\n");
        }
        // 打开解码器
        if ( avcodec_open2(pCodecCtx, pCodec, NULL)<0) {
            NSLog(@"打开编码器失败");
        }
//        avcodec_open2(pCodecCtx, pCodec, NULL);
        
        // 找一个地方保存帧，分配视频帧，为解码帧分配内存
        pVideoFrame=av_frame_alloc();
//        pVideoFrame=avcodec_alloc_frame();

        NSLog(@"来了init");
    }
    
    return self;
}
// 析构函数
- (void)dealloc
{
    NSLog(@"-----dealloc%s",__func__);
    if(!pCodecCtx){
        avcodec_close(pCodecCtx);
        pCodecCtx=NULL;
        NSLog(@"dealloc----pCodecCtx");
    }
    if(!pVideoFrame){
        av_frame_free(&pVideoFrame);
        pVideoFrame=NULL;
           NSLog(@"dealloc----pVideoFrame");
    }
    
//    [super dealloc];
}

- (int)DecodeH264Frames: (unsigned char*)inputBuffer withLength:(int)aLength
{
//    //没有初始化
//    if (!isInit) {
//        return -1;
//    }
    int gotPicPtr=0;
    int result=0;
    // 存储解码前数据的结构体 初始化packet
    av_init_packet(&pAvPackage);
    pAvPackage.data=(unsigned char*)inputBuffer;
    pAvPackage.size=aLength;
    //解码
    result=avcodec_decode_video2(pCodecCtx, pVideoFrame, &gotPicPtr, &pAvPackage);
    NSLog(@"result:%d",result);
    NSLog(@"gotPicPtr:%d",gotPicPtr);
    //如果视频尺寸更改，我们丢掉这个frame
       printf("--------pictureWidth:%d\n",pictureWidth);
    if((pictureWidth!=0)&&(pictureWidth!=pCodecCtx->width)){
        printf("pictureWidth:%d\n",pictureWidth);
        setRecordResolveState=0;
        pictureWidth=pCodecCtx->width;
        return -1;
    }
       printf("********pictureWidth:%d\n",pictureWidth);
    
    //YUV 420 Y U V  -> RGB
    if(gotPicPtr)
    {
        
        unsigned int lumaLength= (pCodecCtx->height)*(MIN(pVideoFrame->linesize[0], pCodecCtx->width));
        unsigned int chromBLength=((pCodecCtx->height)/2)*(MIN(pVideoFrame->linesize[1], (pCodecCtx->width)/2));
        unsigned int chromRLength=((pCodecCtx->height)/2)*(MIN(pVideoFrame->linesize[2], (pCodecCtx->width)/2));
        
        H264YUV_Frame    yuvFrame;
        memset(&yuvFrame, 0, sizeof(H264YUV_Frame));
        
        yuvFrame.luma.length = lumaLength;
        yuvFrame.chromaB.length = chromBLength;
        yuvFrame.chromaR.length =chromRLength;
        
        yuvFrame.luma.dataBuffer=(unsigned char*)malloc(lumaLength);
        yuvFrame.chromaB.dataBuffer=(unsigned char*)malloc(chromBLength);
        yuvFrame.chromaR.dataBuffer=(unsigned char*)malloc(chromRLength);
        printf("gotPicPtr里面\n");
        //复制
        //y
        copyDecodedFrame(pVideoFrame->data[0],yuvFrame.luma.dataBuffer,pVideoFrame->linesize[0],
                         pCodecCtx->width,pCodecCtx->height);
        // u
        copyDecodedFrame(pVideoFrame->data[1], yuvFrame.chromaB.dataBuffer,pVideoFrame->linesize[1],
                         pCodecCtx->width / 2,pCodecCtx->height / 2);
        // v
        copyDecodedFrame(pVideoFrame->data[2], yuvFrame.chromaR.dataBuffer,pVideoFrame->linesize[2],
                         pCodecCtx->width / 2,pCodecCtx->height / 2);
        
        yuvFrame.width=pCodecCtx->width;
        yuvFrame.height=pCodecCtx->height;
        
        if(setRecordResolveState==0){
//            [[Mp4VideoRecorder getInstance] setVideoWith:pCodecCtx->width withHeight:pCodecCtx->height];
            setRecordResolveState=1;
              printf("setRecordResolveState里面\n");
        }
//        [self updateYUVFrameOnMainThread:(H264YUV_Frame*)&yuvFrame];

//        主线程刷新界面
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            //这个时候回到主线程将yuv数据放到opengl中
//            [self updateYUVFrameOnMainThread:(H264YUV_Frame*)&yuvFrame];
//               printf("dispatch_get_main_queue里面\n");
//        });
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self updateYUVFrameOnMainThread:(H264YUV_Frame*)&yuvFrame];
                         printf("dispatch_get_main_queue里面\n");
   
        });
        free(yuvFrame.luma.dataBuffer);
        free(yuvFrame.chromaB.dataBuffer);
        free(yuvFrame.chromaR.dataBuffer);
        
    }
//    av_free_packet(&pAvPackage);
    
    av_free_packet(&pAvPackage);

    return 0;
}
void copyDecodedFrame(unsigned char *src, unsigned char *dist,int linesize, int width, int height)
{
    
    width = MIN(linesize, width);
    
    for (NSUInteger i = 0; i < height; ++i) {
        memcpy(dist, src, width);
        dist += width;
        src += linesize;
    }
    
}
- (void)updateYUVFrameOnMainThread:(H264YUV_Frame*)yuvFrame
{
//    NSLog(@"yuvFrame:%s",yuvFrame->chromaB.dataBuffer);
    if(yuvFrame!=NULL){
        NSLog(@"yuvFrame!=NULL来了");

        if([self.updateDelegate respondsToSelector:@selector(updateDecodedH264FrameData:)]){
            
            [self.updateDelegate updateDecodedH264FrameData:yuvFrame];
            NSLog(@"updateDelegate来了**********");
        }
    }
}

@end
