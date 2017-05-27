//
//  DecodeH264Data_YUV.h
//  FFmpegAndSDLDemo
//
//  Created by fy on 2016/10/20.
//
//

#ifndef DecodeH264Data_YUV_h
#define DecodeH264Data_YUV_h

#pragma pack(push, 1)

typedef struct H264FrameDef
{
    unsigned int    length;
    unsigned char*  dataBuffer;
    
}H264Frame;

typedef struct  H264YUVDef
{
    unsigned int    width;
    unsigned int    height;
    H264Frame       luma;    // 亮度
    H264Frame       chromaB;   // 浓度
    H264Frame       chromaR;
    
}H264YUV_Frame;


#pragma pack(pop)

#endif /* DecodeH264Data_YUV_h */
