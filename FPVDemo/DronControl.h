//
//  DronControl.h
//  FPVDemo
//
//  Created by emre inal on 29.11.2018.
//  Copyright © 2018 DJI. All rights reserved.
//

#ifndef DronControl_h
#define DronControl_h

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <DJISDK/DJISDK.h>

@interface DronControl : NSObject

-(void) updateJoystick;
-(void) setAircraftOrientation;
//-(void) setXVelocity:(float)x andYVelocity:(float)y;
//-(void) setThrottle:(float)y andYaw:(float)x;
-(void) setXVelocity:(float)x;
-(void) setYVelocity:(float)y;
-(void) setThrottle:(float)y;
-(void) setYaw:(float)x;
-(bool) onEnterVirtualStickControlButtonClicked;
-(bool) onExitVirtualStickControlButtonClicked;


@end

#endif /* DronControl_h */
