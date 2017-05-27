//
//  H264DecodeVC.m
//  524MyFFmpegOpenGL
//
//  Created by sjhz on 2017/5/24.
//  Copyright © 2017年 sjhz. All rights reserved.
//
#warning 调用h264解码的类H264DecodeTool 进行mtv.h264格式视频解码，解码为yuv，然后通过openGLES渲染显示解码后yuv。目前还不能显示视频（不会动），只能显示视频的第一帧，后期再修改，
#import "H264DecodeVC.h"
#import "H264DecodeTool.h"
//#import "H264DecodePlayerVC.h"
#import "OpenGLFrameView.h"
#import "OpenglView.h"
#define RECV_VIDEO_BUFFER_SIZE 1280 * 720 * 3
#define screenSize [UIScreen mainScreen].bounds.size
//#define filePathName @"shiping848*480.h264"
#define filePathName @"mtv.h264"
//#define filePathName @"680x232_pic.yuv"
#define videoW 960
//yuv数据高度
#define videoH 544
//#define videoW 680
////yuv数据高度
//#define videoH 232
@interface H264DecodeVC ()<updateDecodeH264FrameDelegate>
@property (nonatomic, strong) UIButton *btn;
@end

@implementation H264DecodeVC

#pragma mark - lifeCycle
- (void)dealloc {
    printf("%s\n",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"H264DecodeVC";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self decode];
    [self.view addSubview:self.btn];

}

#pragma mark - privateMethod
- (void)decode {

    H264DecodeTool * tool = [[H264DecodeTool alloc]init];

//    NSString *res = [[NSBundle mainBundle] pathForResource:@"shiping848*480" ofType:@"h264"];
    
//    NSString *res = [[NSBundle mainBundle] pathForResource:@"525_480*272" ofType:@"h264"];
      NSString *res = [[NSBundle mainBundle] pathForResource:@"mtv.h264" ofType:nil];
//      NSString *res = [[NSBundle mainBundle] pathForResource:@"521.flv" ofType:nil];
    
    
    NSData *data = [NSData dataWithContentsOfFile:res];
    NSUInteger len = [data length];
    NSLog(@"len:%ld",len);
    uint8_t *byteData = (uint8_t *)malloc(data.length);
    memcpy(byteData, [data bytes], len);

//    NSString * path = [[NSBundle mainBundle]pathForResource:filePathName
//                                                     ofType:nil];
//    
//    NSData * data = [NSData dataWithContentsOfFile:path];
//     NSUInteger len = [data length];
//    
//    UInt32 * pFrameRGB = (UInt32*)[data bytes];
    
//    [tool DecodeH264Frames:(unsigned char*)byteData withLength:0x7fef];
      [tool DecodeH264Frames:(unsigned char*)byteData withLength:0x7fef];
//     [tool DecodeH264Frames:(unsigned char*)pFrameRGB withLength:0x7fef];

      tool.updateDelegate = self;
}

- (void)updateDecodedH264FrameData:(H264YUV_Frame *)yuvFrame{
    NSLog(@"H264DecodeVC---updateDecodedH264FrameData");
    OpenGLFrameView *open = [[OpenGLFrameView alloc] initWithFrame:CGRectMake(0, 100, screenSize.width, 300)];
    [self.view addSubview:open];
    NSString *str = [NSString stringWithFormat:@"%d---%d",yuvFrame->width,yuvFrame->height];
    NSLog(@"str:%@",str);
    [open render:yuvFrame];


    //设置大小
//    - (id) initWithFrame:(CGRect)frame;
//    //渲染
//    - (void) render: (H264YUV_Frame *) frame;
    ////
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//        //这里必须加这个,或者延时,否则显示不出来
//        
//        sleep(1);
//        [open render:yuvFrame];
//        //        [openglview displayYUV420pData:pFrameRGB width:640 height:480];
//        //        [openglview displayYUV420pData:pFrameRGB width:848 height:480];
////        [openglview displayYUV420pData:yuvFrame  width:960 height:544];
//    });
//

}
#pragma mark - getter lazyLoading
- (UIButton *)btn {
    if (!_btn) {
        _btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 64, 200, 20)];
        [_btn setTitle:@"点击我显示frame" forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
        [_btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btn;
}

- (void)btnAction:(UIButton *)btn{
    NSLog(@"点击了按钮");
}







@end
