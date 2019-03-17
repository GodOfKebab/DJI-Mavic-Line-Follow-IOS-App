//
//  FrameToBufferClass.h
//  FPVDemo
//
//  Created by Yaşar İdikut on 18.11.2018.
//  Copyright © 2018 DJI. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJISDK/DJISDK.h>


@interface FrameToCIImageClass : NSObject

+(CVPixelBufferRef) videoProcessFrameClassMethod:(VideoFrameYUV*)frame;

@end
