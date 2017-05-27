//
//  OpenGLVC.m
//  524MyFFmpegOpenGL
//
//  Created by sjhz on 2017/5/24.
//  Copyright © 2017年 sjhz. All rights reserved.
//
#warning 这里先渲染的是一张yuv图片,如果想渲染一段yuv视频,需要对yuv视频进行分割并循环,若屏幕出现绿色或打印说参数错误,一般是视频/图片的宽高不对引起的,请仔细查看资源宽高属性,视频目前需要一些特别的参数,我目前是写死的,这样很不好,后面有空了我会将他们进行合理的优化
#import "OpenGLVC.h"
#import <GLKit/GLKit.h>

#import "OpenglView.h"
#define filePathName @"680x232_pic.yuv"
#define screenSize [UIScreen mainScreen].bounds.size

#warning 这里参数一定要正确!
////yuv数据宽度
//#define videoW 848
////yuv数据高度
//#define videoH 480
#define videoW 680
//yuv数据高度
#define videoH 232
@interface OpenGLVC ()

@end

@implementation OpenGLVC

#pragma mark - lifeCycle
- (void)dealloc {
    printf("%s\n",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"OpenGLVC";
    self.view.backgroundColor = [UIColor whiteColor];
    [self play];
}

#pragma mark - privateMethod
/**
 开始渲染
 */
-(void)play{
    OpenglView * openglview = [[OpenglView alloc]initWithFrame:CGRectMake(0, 64, screenSize.width, 300)];
    [self.view addSubview:openglview];
    
    [openglview setVideoSize:videoW height:videoH];
    NSString * path = [[NSBundle mainBundle]pathForResource:filePathName
                                                     ofType:nil];
    
    NSData * data = [NSData dataWithContentsOfFile:path];
    
    UInt32 * pFrameRGB = (UInt32*)[data bytes];
    
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        //这里必须加这个,或者延时,否则显示不出来
        
        sleep(1);
        
        //        [openglview displayYUV420pData:pFrameRGB width:640 height:480];
        //        [openglview displayYUV420pData:pFrameRGB width:848 height:480];
        [openglview displayYUV420pData:pFrameRGB width:680 height:232];
        
        
        
        
    });
    //
    //这里的page循环数以及9.75设置的比较玄学,这里只是为了先出一个效果
    //实际上是没必要把yuv先分开的,直接在解码里做就可以
    //    float result =data.length/9.75f;
    //
    //    for (int page = 0 ; page<10; page ++) {
    //
    //        NSRange rang=NSMakeRange(page*result+1, page*result+result+1);
    //
    //        if (rang.location>=data.length||rang.location+rang.length>=data.length) {
    //            return;
    //        }
    //        NSData * dataNew=[data subdataWithRange:rang];
    //        UInt32 * pFrameRGB = (UInt32*)[dataNew bytes];
    //
    //        dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //
    //            //这里必须加这个,或者延时,否则显示不出来
    //            sleep(1);
    //
    ////            [openglview displayYUV420pData:pFrameRGB width:848 height:480];
    //            [openglview displayYUV420pData:pFrameRGB width:480 height:272];
    //
    //
    //        });
    //        
    //        if (page == 4) {
    //            break;
    //        }
    //    }
    //    
    //    
    //    NSLog(@"结束");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
