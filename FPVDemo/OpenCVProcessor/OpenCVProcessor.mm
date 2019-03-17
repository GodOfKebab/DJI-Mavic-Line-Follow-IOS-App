//
//  OpenCVProcessor.m
//  FPVDemo
//
//  Created by Yaşar İdikut on 29.11.2018.
//  Copyright © 2018 DJI. All rights reserved.
//

#import "OpenCVProcessor.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <CoreImage/CoreImage.h>
#import <opencv2/imgproc.hpp>
#import <CoreVideo/CoreVideo.h>
#import <DJIWidget/DJIVideoPreviewer.h>
#import <UIKit/UIKit.h>
#import <DJISDK/DJISDK.h>
#import "FrameToCIImageClass.h"
#import <Foundation/Foundation.h>

int errorX;

@interface OpenCVProcessor ()



@end

@implementation OpenCVProcessor : NSObject



-(UIImage *) Process:(VideoFrameYUV*)frame videoShowType: (int)videoShowType{

    printf("OpenCV processor function is called");
    
    /////////////////////////////////////////////////////////////////////////////////////////////////
    
    CVPixelBufferRef buffer = [FrameToCIImageClass videoProcessFrameClassMethod:frame ];
    
    cv::Mat grayScale;
    CVPixelBufferLockBaseAddress(buffer, 0);
    //Get only the data from the plane we're interested in
    void *address =  CVPixelBufferGetBaseAddressOfPlane(buffer, 0);
    int bufferWidth = (int)CVPixelBufferGetWidthOfPlane(buffer,0);
    int bufferHeight = (int)CVPixelBufferGetHeightOfPlane(buffer, 0);
    int bytePerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(buffer, 0);
    grayScale = cv::Mat(bufferHeight, bufferWidth, CV_8UC1, address, bytePerRow).clone();
    ////////////////////////////////////// ENTER THE MAIN CODE FOR VISION/////////////////////////////////////////////////////////////q
    
    cv::Mat Thresholded;
    cv::threshold(grayScale, Thresholded, 200, 255, cv::THRESH_BINARY );
    //cv::adaptiveThreshold(grayScale, Thresholded, 255, cv::ADAPTIVE_THRESH_MEAN_C, cv::THRESH_BINARY_INV, 25, 2);
    
    
    
    cv::resize(Thresholded, Thresholded, cv::Size(320, 240));
    
    
    cv::Mat mask = cv::Mat::zeros(Thresholded.rows, Thresholded.cols, CV_8UC3);
    
    std::vector<std::vector<cv::Point> > contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::Rect br;
    cv::Point contourBottom;
    cv::Point contourTop;
    cv::Point closestPoint = cv::Point(0, 0);
    
    
    cv::findContours(Thresholded, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    
    //float tried [contours.size()* contours[0].size()] = {};

        
    for(int i =0; i< contours.size(); i++){
        if(cv::contourArea(contours[i]) > 300){
            drawContours( mask, contours, i, cv::Scalar(255,255,255), CV_FILLED, 8, hierarchy );
            
            br = cv::boundingRect(contours[i]);
            
//            cx = br.x+br.width/2;
//            cy = br.y+br.height/2;
            
            contourTop = cv::Point((br.x+br.width/2), (br.y));
            contourBottom = cv::Point((br.x+br.width/2), (br.y + br.width));
                    
            
            
            if(((br.y+br.height/2) < 120) && (closestPoint.y < (br.y+br.height/2))){
                closestPoint = contourBottom;
                cv::circle(mask, contourBottom, 2, cv::Scalar(0,0,255), -1);
                errorX = closestPoint.x;
            }
            
        }
    }
    
    ///////////////////////////////// ABOUT TO RETURN ////////// END THE MAIN CODE FOR VISION///////////////////////////////////////
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    switch (videoShowType) {
        case 0:
            return MatToUIImage(grayScale);
        case 1:
            return MatToUIImage(Thresholded);
        case 2:
            return MatToUIImage(mask);
        default:
            return MatToUIImage(grayScale);
    }
}


-(int) errorXupdated{
    return errorX;
}





@end
