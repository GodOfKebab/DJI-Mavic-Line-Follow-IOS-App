//
//  FrameToBufferClass.m
//  FPVDemo
//
//  Created by Yaşar İdikut on 18.11.2018.
//  Copyright © 2018 DJI. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <DJIWidget/DJIVideoPreviewer.h>
#import <CoreImage/CoreImage.h>
#import <DJISDK/DJISDK.h>
#import "FrameToCIImageClass.h"


@interface FrameToCIImageClass ()

@end

@implementation FrameToCIImageClass : NSObject

+(CVPixelBufferRef) videoProcessFrameClassMethod:(VideoFrameYUV*)frame {
    
    CVPixelBufferRef pixelBuffer = frame->cv_pixelbuffer_fastupload;
    
    CIImage* sourceImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:nil];
    
    
    sourceImage = [sourceImage imageByApplyingFilter:@"CIColorControls" withInputParameters:@{kCIInputSaturationKey: @0.0}];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:sourceImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputRadius"];
    sourceImage = [filter valueForKey:kCIOutputImageKey];
    
    
    // Converting back to CVPixelBuffer
    [[[CIContext alloc] init] render:sourceImage toCVPixelBuffer:pixelBuffer bounds:[sourceImage extent] colorSpace:CGColorSpaceCreateDeviceRGB()];
    
    return pixelBuffer;
    
}


@end


