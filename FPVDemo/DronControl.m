//
//  dronControl.m
//  FPVDemo
//
//  Created by emre inal on 29.11.2018.
//  Copyright © 2018 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DronControl.h"
#import "DemoUtility.h"

@implementation DronControl
{
    float mXVelocity;
    float mYVelocity;
    float mYaw;
    float mThrottle;
}

-(void) setAircraftOrientation
{
    DJIFlightController* fc = [DemoUtility fetchFlightController];
    if (fc) {
        fc.rollPitchControlMode = DJIVirtualStickFlightCoordinateSystemBody;
    }
}

-(bool) onExitVirtualStickControlButtonClicked
{
    bool result = false;
    
    DJIFlightController* fc = [DemoUtility fetchFlightController];
    if (fc) {
        [fc setVirtualStickModeEnabled:NO withCompletion:^(NSError * _Nullable error) {
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


-(bool) onEnterVirtualStickControlButtonClicked
{
    bool result = false;
    
    DJIFlightController* fc = [DemoUtility fetchFlightController];
    if (fc) {
        fc.yawControlMode = DJIVirtualStickYawControlModeAngularVelocity;
        fc.rollPitchControlMode = DJIVirtualStickRollPitchControlModeVelocity;
        [fc setVirtualStickModeEnabled:YES withCompletion:^(NSError * _Nullable error) {
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

/*
-(void) setThrottle:(float)y andYaw:(float)x
{
    mThrottle = y * -2;
    mYaw = x * 30;
    
    [self updateJoystick];
}
*/

-(void) setThrottle:(float)y
{
    mThrottle = y * -2;
    [self updateJoystick];
}


-(void) setYaw:(float)x
{
    mYaw = x * 30;
    [self updateJoystick];
}

/*
-(void) setXVelocity:(float)x andYVelocity:(float)y
{
    mXVelocity = x * 5.0;
    mYVelocity = y * 5.0;
    [self updateJoystick];
}
*/

 -(void) setXVelocity:(float)x
 {
     mXVelocity = x * 5.0;
     [self updateJoystick];
 }


 -(void) setYVelocity:(float)y
 {
     mYVelocity = y * 5.0;
     [self updateJoystick];
 }



-(void) updateJoystick
{
    DJIVirtualStickFlightControlData ctrlData = {0};
    ctrlData.pitch = mYVelocity;
    ctrlData.roll = mXVelocity;
    ctrlData.yaw = mYaw;
    ctrlData.verticalThrottle = mThrottle;
    DJIFlightController* fc = [DemoUtility fetchFlightController];;
    if (fc && fc.isVirtualStickControlModeAvailable) {
        [fc sendVirtualStickFlightControlData:ctrlData withCompletion:nil];
    }
}
@end
