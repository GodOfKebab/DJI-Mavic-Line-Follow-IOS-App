//
//  TakeOffAndLandClass.m
//  FPVDemo
//
//  Created by Yaşar İdikut on 20.11.2018.
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TakeOffAndLandClass.h"
#import <DJISDK/DJISDK.h>

@interface TakeOffAndLandClass ()

@end

@implementation TakeOffAndLandClass : NSObject

-(bool) TakeOffWithCompletion{
    
    bool result = false;
    
    DJIFlightController* fc = ((DJIAircraft *)[DJISDKManager product]).flightController;
    
    if (fc) {
        [fc startTakeoffWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                bool result = false;
            }
            else
            {
                bool result = true;
            }
        }];
    }
    else
    {
        bool result = false;
    }
    
    return result;
}


-(bool) LandWithCompletion{
    
    bool result = false;
    
    DJIFlightController* fc = ((DJIAircraft *)[DJISDKManager product]).flightController;
    if (fc) {
        [fc startLandingWithCompletion:^(NSError * _Nullable error) {
            if (error) {
                bool result = false;
            }
            else
            {
                bool result = false;
            }
        }];
    }
    else
    {
        bool result = false;
    }
    
    return result;
}



@end
