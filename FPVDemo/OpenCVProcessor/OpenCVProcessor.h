//
//  OpenCVProcessor.h
//  FPVDemo
//
//  Created by Yaşar İdikut on 29.11.2018.
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DJIWidget/DJIVideoPreviewer.h>
#import <DJISDK/DJISDK.h>



@interface OpenCVProcessor : NSObject

-(UIImage *) Process:(VideoFrameYUV*)frame videoShowType: (int)videoShowType;

-(int) errorXupdated;
    
    
@end


